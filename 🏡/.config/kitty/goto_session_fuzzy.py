# Custom kitten: fuzzy-pick a session file and switch to it.
#
# Replaces `goto_session <dir>`, whose picker is a static list where every entry
# gets a hint letter you press: goto_session hands the directory listing to
# Boss.choose_entry, which runs the hints kitten with
# --customize-processing=::import::kitty.choose_entry. Nothing there filters as
# you type, and no goto_session option adds it -- the action takes only
# --sort-by and --active-only. So the filtering has to live outside kitty.
#
# fzf is a good fit because it puts its UI on /dev/tty and only the selection on
# STDOUT, so capturing STDOUT inside the overlay yields the answer and nothing
# else. Piping it also keeps it off this process's own STDOUT, which the kitten
# framework needs: it returns main()'s value to kitty by writing a
# \x1bP@kitty-kitten-result| escape sequence there (kittens/runner.py).
#
# Wired up by `map cmd+shift+w kitten goto_session_fuzzy.py ~/.local/share/kitty/sessions`.

import os
import shlex
import shutil
import subprocess
from typing import Callable, Optional

from kitty.boss import Boss
from kitty.fast_data_types import add_timer

DEFAULT_SESSION_DIR = '~/.local/share/kitty/sessions'

# The same set kitty itself accepts -- SESSION_FILE_EXTENSIONS in kitty/session.py.
# Mirrored rather than hardcoded to .kitty-session so a file named the other two
# ways stays reachable, exactly as it would be through the built-in action.
EXTENSIONS = ('.kitty-session', '.kitty_session', '.session')

# kitty.app started by AeroSpace (or Finder) does not inherit the login shell's
# PATH, so which() alone can come up empty even though fzf is installed.
# macOS Homebrew (arm64, then Intel), then openSUSE's zypper-installed fzf.
FZF_FALLBACKS = ('/opt/homebrew/bin/fzf', '/usr/local/bin/fzf', '/usr/bin/fzf')

# See handle_result: the deferred callbacks are closures, so they are kept alive here
# rather than relying on add_timer's own reference to them.
_pending: list[Callable[[Optional[int]], None]] = []


def sessions(directory: str) -> list[tuple[str, str]]:
    ans: list[tuple[str, str]] = []
    with os.scandir(directory) as entries:
        for entry in entries:
            if not entry.is_file():
                continue
            for ext in EXTENSIONS:
                if entry.name.endswith(ext) and len(entry.name) > len(ext):
                    ans.append((entry.name[:-len(ext)], entry.path))
                    break
    # Alphabetical, not most-recent: goto_session's recency list lives in the
    # kitty process and a kitten is a separate one, so it cannot be read here.
    return sorted(ans, key=lambda pair: pair[0].lower())


def find_fzf() -> str:
    return shutil.which('fzf') or next((p for p in FZF_FALLBACKS if os.access(p, os.X_OK)), '')


def fail(message: str) -> str:
    """Hold the overlay open long enough for the message to be read."""
    print(message)
    try:
        input('Press Enter to close. ')
    except (KeyboardInterrupt, EOFError):
        pass
    return ''


def main(args: list[str]) -> str:
    """Runs in an overlay over the active window; the return value -- the path of
    the chosen session file, or '' for a no-op -- goes to handle_result()."""
    # A kitten's cwd is the cwd of the active window, so a relative directory
    # would resolve somewhere unpredictable.
    directory = os.path.expanduser(args[1] if len(args) > 1 else DEFAULT_SESSION_DIR)

    try:
        entries = sessions(directory)
    except OSError as e:
        return fail(f'Could not list session files in {directory}: {e}')
    if not entries:
        return fail(f'No session files found in {directory}')

    fzf = find_fzf()
    if not fzf:
        return fail('fzf not found on PATH or in ' + ', '.join(FZF_FALLBACKS))

    # The name is column 1 and all that is displayed or matched against (--with-nth
    # transforms both); the path rides along in column 2 for the preview and, since
    # fzf still prints the untransformed line, for the return value.
    stdin = ''.join(f'{name}\t{path}\n' for name, path in entries)
    result = subprocess.run(
        [
            fzf,
            '--delimiter=\t',
            '--with-nth=1',
            '--prompt=session> ',
            '--layout=reverse',
            '--no-multi',
            '--preview=cat {2}',
            '--preview-window=right,60%',
        ],
        input=stdin,
        text=True,
        stdout=subprocess.PIPE,
    )
    # esc gives 130 and no-match-plus-enter gives 1; both mean "do nothing".
    if result.returncode != 0:
        return ''

    line = result.stdout.strip()
    _, _, path = line.partition('\t')
    return path


def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    path = (answer or '').strip()
    if not path:
        return

    # Deferred by a tick, and dispatched through remote control rather than
    # boss.goto_session() directly -- both for the same reasons as new_session.py, which
    # documents them at length. In short: picking a session with no live windows makes
    # kitty create tabs for it, and tab creation from inside the overlay's
    # actions_on_close raises KeyError while `tab_bar_filter` is set, because the dying
    # overlay is out of window_id_map but still listed in its tab. Going via the `action`
    # command additionally keeps this overlay's teardown from racing the set_active_window
    # that goto_session ends in.
    #
    # Semantics are otherwise the built-in action's own -- a live session is focused, an
    # unloaded one is created from its file.
    #
    # `action` re-parses its argument with kitty.conf's own action-argument rules
    # (rc/action.py hands the string to boss.combine), so a session file whose name
    # contains a space needs the quoting kitty.conf would need.
    def goto(timer_id: Optional[int] = None) -> None:
        _pending.clear()
        w = boss.window_id_map.get(target_window_id)
        if w is None:
            return
        boss.call_remote_control(w, ('action', f'goto_session {shlex.quote(path)}'))

    _pending.append(goto)
    add_timer(goto, 0, False)
