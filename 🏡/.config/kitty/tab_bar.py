# Custom tab bar. kitty has no shader hook of any kind -- not for the tab bar,
# not for anything else -- so this is Python, not GLSL: kitty calls draw_tab()
# once per tab and we write cells into a Screen. Everything below is colour and
# text attributes, which is why it needs no Nerd Font.
#
# Look: no fills. The active tab gets a #ff6ec7 underline and lavender text,
# everything else dims back to #8a7a9b. The bar sits at the top edge, so this
# reads like a browser tab strip.
#
# Enabled by `tab_bar_style custom` in kitty.conf; kitty loads this file by
# name from the config directory.

import os

from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, get_boss, wcswidth
from kitty.utils import color_as_int

# U+2581..U+258F are Block Elements, which kitty renders internally rather than
# asking the font for, so this is safe on plain JetBrains Mono. The chosen
# preview used a diamond (U+25C6); that lives in Geometric Shapes, which the
# font may or may not carry, and a miss shows as tofu. Swap it here if you
# install a Nerd Font and would rather have the diamond.
SESSION_MARK = '▌'  # left half block

# straight underline; 2=double, 3=curly, 4=dotted, 5=dashed
UNDERLINE_STRAIGHT = 1

# cells of padding either side of a tab label. the underline spans these too,
# so the accent bar is wider than the text -- that is what makes it read as a
# bar rather than a spelling error.
PAD = 2

# The mark is drawn once, after the last tab, but the session it should name
# belongs to the *active* tab -- and draw_tab() only ever sees one tab at a
# time. So the active tab's session is remembered as the pass goes by and read
# back when the last tab is reached. kitty guarantees the active tab is always
# drawn even when tab_bar_filter excludes it, so this is always populated.
#
# Keyed by OS window: with one session per OS window, a single shared string
# would let whichever bar drew last name the session in all the others.
_active_session: dict[int, str] = {}


def _accent() -> int:
    # active_border_color (#ff6ec7) is the theme's one hot colour, shared with
    # ghostty and wezterm's `split`. Read it rather than hardcoding so the tab
    # bar follows the theme if that value ever changes.
    return as_rgb(color_as_int(get_options().active_border_color))


def _cwd_basename(tab: TabBarData) -> str:
    """Basename of the tab's active window's working directory, or ''.

    Preferred over the title: a tab sitting at a plain shell prompt reports its
    title as 'zsh', which says nothing about where it is. The cwd always does.
    Wrapped broadly because this reaches into live objects during a draw, and a
    tab bar that raises stops drawing entirely.
    """
    try:
        t = get_boss().tab_for_id(tab.tab_id)
        if t is None:
            return ''
        w = t.active_window
        if w is None:
            return ''
        cwd = (w.cwd_of_child or '').rstrip('/')
        if not cwd:
            return ''
        if cwd == os.path.expanduser('~'):
            return '~'
        return os.path.basename(cwd) or '/'
    except Exception:
        return ''


def _explicit_name(tab: TabBarData) -> str:
    """The name given by set_tab_title (cmd+shift+r), or ''.

    tab.title cannot answer this: kitty hands the bar `name or window title`
    collapsed into one string, so a tab named "logs" is indistinguishable from a
    window that happens to report that title. The live Tab object still has the
    two apart -- kitty's own Tab.effective_title is `self.name or self.title` --
    so the name is read from there.

    An explicit name outranks the cwd on purpose: renaming is how you say the
    directory is not the useful thing about this tab. Clearing the prompt sets
    the name back to '' and the cwd label returns.
    """
    try:
        t = get_boss().tab_for_id(tab.tab_id)
        if t is None:
            return ''
        return (getattr(t, 'name', '') or '').strip()
    except Exception:
        return ''


def _label(tab: TabBarData) -> str:
    """Explicit name, else directory basename, else the window title."""
    name = _explicit_name(tab)
    if name:
        return name
    base = _cwd_basename(tab)
    if base:
        return base
    t = (tab.title or '').strip()
    if not t:
        return 'kitty'
    # kitty abbreviates long paths with a leading ellipsis, e.g. …/gitlab/awq
    t = t.lstrip('…')
    if '/' in t:
        t = t.rstrip('/')
        # '~' keeps its own name; only the filesystem root has an empty basename
        return os.path.basename(t) or '/'
    return t


def _draw_session_mark(screen: Screen, draw_data: DrawData, name: str) -> None:
    """Right-aligned session name, recovering wezterm's update-right-status.

    kitty has no right status area, so this is drawn after the last tab by
    jumping the cursor to the far edge.
    """
    if not name:
        return
    text = f' {SESSION_MARK} {name} '
    width = wcswidth(text)
    # never overwrite a tab: if the tabs already reach the status area, drop it
    if screen.columns - screen.cursor.x < width:
        return
    screen.cursor.decoration = 0
    screen.cursor.bold = False
    screen.cursor.italic = False
    screen.cursor.bg = as_rgb(color_as_int(draw_data.default_bg))
    screen.cursor.fg = _accent()
    screen.cursor.x = screen.columns - width
    screen.draw(text)


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    accent = _accent()
    bg = as_rgb(color_as_int(draw_data.default_bg))

    if tab.is_active:
        _active_session[tab.os_window_id] = tab.active_session_name or ''

    if tab.needs_attention:
        # a bell takes the accent colour rather than a separate symbol
        fg = accent
    elif tab.is_active:
        fg = as_rgb(color_as_int(draw_data.active_fg))
    else:
        fg = as_rgb(color_as_int(draw_data.inactive_fg))

    label = _label(tab)
    room = max_title_length - (PAD * 2)
    if room > 1 and wcswidth(label) > room:
        label = label[: room - 1] + '…'

    screen.cursor.bg = bg
    screen.cursor.fg = fg
    screen.cursor.bold = tab.is_active
    screen.cursor.italic = False
    if tab.is_active:
        screen.cursor.decoration = UNDERLINE_STRAIGHT
        screen.cursor.decoration_fg = accent
    else:
        screen.cursor.decoration = 0

    screen.draw(f'{" " * PAD}{label}{" " * PAD}')

    # reset so nothing bleeds into the gap after the last tab
    screen.cursor.decoration = 0
    screen.cursor.bold = False

    if is_last:
        _draw_session_mark(screen, draw_data, _active_session.get(tab.os_window_id, ''))

    return screen.cursor.x
