# Custom kitten: save the active session -- and only it -- then flash
# "✓ saved" next to the session name in the tab bar for a couple of seconds.
#
# Equivalent to
#   save_as_session --save-only --match=session:. --use-foreground-process \
#       --base-dir ~/.local/share/kitty/sessions .
# which is what cmd+shift+s used to be bound to. Why those options:
#   --match=session:.  without it kitty saves every window in the instance, so
#                      each save copied other sessions' tabs into this file and
#                      loading it tagged them all with this session's name. Files
#                      grew to 100+ tabs that way.
#   `.` path           the file the active session was loaded from, so no prompt.
#                      Only a live-only session (cmd+shift+n) has none and is asked.
#   --base-dir         a bare name typed at that prompt lands in the sessions dir.
#   --save-only        do not open the written file in an editor afterwards.
#
# The action itself gives no feedback, and it never tells anyone where it wrote, so
# this calls the pieces under it directly. kitty internals relied on (0.50):
#   kitty.session.save_as_session_part2(boss, opts, path, path_input_by_user=False)
#       -- writes synchronously via atomic_save; shows its own error on failure.
#   kitty.session.seen_session_paths -- {session name: file it was loaded from};
#       what `.` resolves through. part2 never adds to it, so with the plain action
#       a cmd+shift+n session is prompted for a path on *every* save until it is
#       reloaded from the picker. This kitten records the path after the first save.
#   Boss.get_save_filepath(msg, callback) -- the path prompt the action uses.
#
# The flash is shared with tab_bar.py through an attribute on the boss
# (`dotfiles_session_flash`), since the two are loaded as unrelated modules.
#
# Wired up by `map cmd+shift+s kitten save_session.py ~/.local/share/kitty/sessions`.

import os
import time
from collections.abc import Callable

from kittens.tui.handler import result_handler
from kitty.boss import Boss
from kitty.fast_data_types import add_timer
from kitty.session import (
    parse_save_as_options_spec_args,
    save_as_session_part2,
    seen_session_paths,
)

DEFAULT_SESSION_DIR = '~/.local/share/kitty/sessions'
EXTENSIONS = ('.kitty-session', '.kitty_session', '.session')
FLASH_SECONDS = 2.0
PROMPT = 'Enter the path at which to save the session, usually session files are given the .kitty-session file extension'

# Timer callbacks are closures; keep them alive explicitly, as the other kittens do.
_pending: list[Callable[[int | None], None]] = []


def main(args: list[str]) -> str:
    return ''


def _mtime(path: str) -> float | None:
    try:
        return os.stat(path).st_mtime
    except OSError:
        return None


def _redraw(boss: Boss) -> None:
    for tm in boss.all_tab_managers:
        tm.mark_tab_bar_dirty()


def _flash(boss: Boss, session: str) -> None:
    boss.dotfiles_session_flash = session, time.monotonic() + FLASH_SECONDS
    _redraw(boss)

    def clear(timer_id: int | None = None) -> None:
        if clear in _pending:
            _pending.remove(clear)
        current = getattr(boss, 'dotfiles_session_flash', None)
        # A later save may have restarted the flash; leave that one alone.
        if current and current[1] <= time.monotonic() + 0.05:
            boss.dotfiles_session_flash = None
        _redraw(boss)

    _pending.append(clear)
    add_timer(clear, FLASH_SECONDS, False)


def _written_path(answer: str, base_dir: str, since: float) -> str:
    """Where part2 put a user-typed path. It resolves it against --base-dir and may
    append .kitty-session; rather than mirror that exactly, check the likely
    candidates and fall back to the newest session file written since `since`."""
    p = os.path.expanduser(answer)
    if not os.path.isabs(p):
        p = os.path.join(base_dir, p)
    p = os.path.abspath(p)
    for candidate in (p, p + '.kitty-session'):
        m = _mtime(candidate)
        if m is not None and m >= since and os.path.isfile(candidate):
            return candidate
    best, best_m = '', since
    try:
        with os.scandir(base_dir) as entries:
            for e in entries:
                if e.is_file() and e.name.endswith(EXTENSIONS):
                    m = _mtime(e.path)
                    if m is not None and m >= best_m:
                        best, best_m = e.path, m
    except OSError:
        pass
    return best


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    base_dir = os.path.expanduser(args[1] if len(args) > 1 else DEFAULT_SESSION_DIR)
    opts, _ = parse_save_as_options_spec_args([
        '--save-only', '--match=session:.', '--use-foreground-process', '--base-dir', base_dir,
    ])
    session = boss.active_session
    path = seen_session_paths.get(session) if session else None

    if path:
        before = _mtime(path)
        save_as_session_part2(boss, opts, path)
        after = _mtime(path)
        # Only claim success when the file demonstrably changed; on failure part2 has
        # already shown kitty's own error.
        if after is not None and after != before:
            _flash(boss, session)
        return

    def on_path(answer: str) -> None:
        answer = (answer or '').strip()
        if not answer:
            return
        # Coarse filesystems can round mtimes down; allow a little slack.
        since = time.time() - 1.0
        save_as_session_part2(boss, opts, answer, path_input_by_user=True)
        written = _written_path(answer, base_dir, since)
        if not written:
            return
        if session:
            # So the next save goes straight to this file instead of prompting again.
            seen_session_paths[session] = written
            _flash(boss, session)

    w = boss.window_id_map.get(target_window_id)
    boss.get_save_filepath(PROMPT, on_path, w)
