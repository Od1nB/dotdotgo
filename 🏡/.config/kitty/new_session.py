# Custom kitten: prompt for a session name, open a tab belonging to it.
#
# kitty has no new_session action -- a session is not a container, it is a name
# stamped on tabs and windows, so a new session is made simply by naming one
# that does not exist yet. `launch --add-to-session` takes an unconstrained
# string, which is the hook this uses.
#
# The new tab goes in the *current* OS window rather than one of its own, which
# with `tab_bar_filter session:.` reads as switching the window to the new
# session: the tab is focused, so it becomes the active session, so the filter
# drops every tab of the old one from the bar. Those tabs are hidden, not gone
# -- cmd+shift+w or `goto_session -1` brings them back.
#
# The session is live-only: per the launch docs, adding a window to a session
# "is purely temporary, it does not change the actual session file". So the new
# name will NOT appear in the cmd+shift+w picker (which lists files on disk)
# until cmd+shift+s saves it. `goto_session -1` is the way back to it in the
# meantime, which is why the name is put into kitty's session history below.
#
# Wired up by `map cmd+shift+n kitten new_session.py` in kitty.conf.

import os
import time
import traceback
from typing import Callable, Optional

from kitty.boss import Boss
from kitty.fast_data_types import add_timer
from kitty.session import append_to_session_history

# --add-to-session reserves these: '.' means the source window's session and '!'
# means no session. Typing either would silently do something other than create.
RESERVED = {'.', '!'}

# kitty is started by AeroSpace, so its stderr is /dev/null: Boss.call_remote_control
# log_error()s and then re-raises, and handle_result runs inside the overlay window's
# actions_on_close, so a failure here leaves no trace anywhere -- no kitty log file, and
# nothing in the unified log either. Hence reporting it by hand, to two sinks: a window,
# which is what actually gets noticed, and a file, for when opening that window is
# itself what failed.
LOG_PATH = os.path.expanduser('~/.local/state/kitty/new_session.log')

# add_timer's C side does hold a reference to the callback while the timer is armed, but
# the callbacks below are closures with nothing else keeping them alive, so they are
# parked here explicitly rather than resting on that implementation detail.
_pending: list[Callable[[Optional[int]], None]] = []


def main(args: list[str]) -> str:
    """Runs in an overlay over the active window; the return value goes to
    handle_result(). Cancelling with ctrl+c or ctrl+d yields '', a no-op."""
    try:
        return input('New session name: ').strip()
    except (KeyboardInterrupt, EOFError):
        return ''


def report(boss: Boss, message: str) -> None:
    try:
        os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
        with open(LOG_PATH, 'a') as f:
            f.write(f'{time.strftime("%Y-%m-%d %H:%M:%S")}\n{message}\n')
    except OSError:
        pass
    # show_error opens a special window over the active one, so it can plausibly fail
    # for the same reason the thing being reported did.
    try:
        boss.show_error('new_session failed', message)
    except Exception:
        pass


def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss) -> None:
    name = (answer or '').strip()
    if not name or name in RESERVED:
        return

    # Deferred by a tick rather than run inline, because tab creation is not safe from
    # here. handle_result runs from the overlay's actions_on_close, at which point
    # on_window_close has already popped the overlay out of window_id_map -- a
    # WeakValueDictionary -- while its tab still lists it. Creating a tab makes kitty
    # recompute tab bar visibility, and a `tab_bar_filter` sends that through
    # Boss.match_tabs -> match_windows -> get_matches, which resolves every candidate id
    # as window_id_map[wid] and so raises KeyError on the dying overlay's own id
    # (boss.py:584). launch dies *after* create_tab succeeds, leaving a tab with no shell
    # in it. Nothing about the arguments avoids this: the filter is kitty's, not ours. One
    # event loop iteration later the overlay is out of the tab too and the tree is
    # consistent again.
    def launch(timer_id: Optional[int] = None) -> None:
        _pending.clear()

        # No --source-window, and no --match or --next-to either: not needed, since
        # _launch falls back to boss.active_window_for_cwd, which is
        # Tab.windows.active_group_main -- with the overlay gone, exactly the window this
        # kitten was run over. `w` is still passed to call_remote_control as the
        # originating window, but with no match expression to resolve it only reaches
        # _launch's rc_from_window, which nothing else here reads.
        w = boss.window_id_map.get(target_window_id)
        if w is None:
            return

        try:
            response = boss.call_remote_control(w, (
                'launch',
                # A tab in this OS window, focused (no --keep-focus), which is what flips
                # the active session and so the tab bar.
                '--type=tab',
                # --cwd=current is what would normally *infer* session inheritance from
                # the source window; the explicit --add-to-session below overrides that
                # inference, so this only carries the directory across.
                '--cwd=current',
                f'--add-to-session={name}',
            ))
        except Exception:
            report(boss, traceback.format_exc())
            return

        # launch answers with the new window's id, or '0' when it made nothing -- the one
        # failure mode that does not raise, so it needs checking by hand.
        if str(response) in ('0', 'None', ''):
            report(boss, f'launch created no window for session {name!r}; response={response!r}')
            return

        # goto_session_history is what `goto_session -1` walks and what the picker sorts
        # by, and only goto_session and loading a session file append to it -- creating a
        # window in a session does not. Without this the new session is unreachable the
        # moment focus leaves it: its tabs are filtered out of every other session's bar
        # and it has no file for the cmd+shift+w picker to list.
        append_to_session_history(name)

    _pending.append(launch)
    add_timer(launch, 0, False)

