import platform

# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html
#   qute://help/settings.html#bindings.commands (brief mode explanation)
#   qute://help/commands.html

# pylint: disable=C0111
c = c  # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

config.load_autoconfig(False)
config.source("theme.py")

c.completion.open_categories = [
    "searchengines",
    "quickmarks",
    "bookmarks",
    "history",
    "filesystem",
]

c.statusbar.widgets = [
    "keypress",
    "search_match",
    "history",
    "url",
    "progress",
    "tabs",
    "scroll",
]

c.window.hide_decoration = True
c.auto_save.session = True
c.tabs.last_close = "close"
c.content.pdfjs = True
c.content.notifications.enabled = False
c.content.blocking.method = "both"

# qutebrowser UI
c.fonts.default_family = "JetBrains Mono"
c.fonts.default_size = "11pt"

# Command line / prompts
c.fonts.statusbar = "11pt JetBrains Mono"
c.fonts.prompts = "11pt JetBrains Mono"
c.fonts.completion.category = "10.5pt JetBrains Mono"
c.fonts.completion.entry = "10.5pt JetBrains Mono"

# HiDPI: if you have a 4K/Retina screen and the UI text (not web page content)
# appears blurry, uncomment the line below. It is equivalent to
# QT_AUTO_SCREEN_SCALE_FACTOR=1. It may cause issues with bitmap fonts,
# which is why it is not enabled by default.
# c.qt.highdpi = True

# Web pages
c.fonts.web.family.standard = "Inter"
c.fonts.web.family.sans_serif = "Inter"
c.fonts.web.family.fixed = "JetBrains Mono"
c.fonts.web.size.default = 16
c.fonts.web.size.default_fixed = 13

c.scrolling.bar = "never"
c.completion.scrollbar.width = 0

c.statusbar.show = "never"
c.tabs.show = "never"

# Tab appearance
# Only visible when toggled via ,tH (tabs.show multiple/never) or toggle-tabbar.
c.tabs.padding = {"top": 5, "bottom": 5, "left": 10, "right": 10}
c.tabs.indicator.width = 0
c.tabs.width = "18%"
c.tabs.min_width = -1
c.tabs.title.format = "{index}: {current_title}"
c.tabs.title.format_pinned = "{index}"
c.tabs.favicons.scale = 0.85
c.fonts.tabs.selected = "10pt JetBrains Mono"
c.fonts.tabs.unselected = "10pt JetBrains Mono"

# c.colors.tabs.bar.bg = "#000000"
# c.colors.tabs.odd.bg = "#0a0a0a"
# c.colors.tabs.even.bg = "#0a0a0a"
# c.colors.tabs.odd.fg = "#7a7a7a"
# c.colors.tabs.even.fg = "#7a7a7a"
# c.colors.tabs.selected.odd.bg = "#1c1c1c"
# c.colors.tabs.selected.even.bg = "#1c1c1c"
# c.colors.tabs.selected.odd.fg = "#f2f2f2"
# c.colors.tabs.selected.even.fg = "#f2f2f2"
# c.colors.tabs.pinned.odd.bg = "#0a0a0a"
# c.colors.tabs.pinned.even.bg = "#0a0a0a"
# c.colors.tabs.pinned.selected.odd.bg = "#1c1c1c"
# c.colors.tabs.pinned.selected.even.bg = "#1c1c1c"

c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "gg": "https://www.google.com/search?q={}",
    "br": "https://search.brave.com/search?q={}",
    "gh": "https://github.com/{}",
    "ghs": "https://github.com/search?q={}&type=repositories",
    "yt": "https://www.youtube.com/results?search_query={}",
    "aw": "https://wiki.archlinux.org/index.php?search={}&title=Special%3ASearch&fulltext=1",
}

c.aliases["toggle-statusbar"] = "config-cycle statusbar.show always never"
c.aliases["toggle-tabbar"] = "config-cycle tabs.show always never"

config.bind("<F2>", "config-cycle statusbar.show always never")
config.bind("<F3>", "config-cycle tabs.show always never")

config.bind("<Ctrl-d>", "scroll-page 0 0.5")
config.bind("<Ctrl-u>", "scroll-page 0 -0.5")
config.bind("<Ctrl-f>", "scroll-page 0 1")
config.bind("<Ctrl-b>", "scroll-page 0 -1")

config.unbind(";r")
config.unbind(";y")
config.unbind(";i")
config.unbind(";o")
config.unbind(";d")
config.unbind(";f")
config.unbind(";h")
config.unbind(";b")
config.unbind(";R")
config.unbind(";Y")
config.unbind(";I")
config.unbind(";O")
config.bind(";", "cmd-set-text :")

# Bindings for normal mode
config.bind(":", "cmd-set-text :")
config.bind(".", "cmd-repeat-last")
config.bind("/", "cmd-set-text /")
config.bind("?", "cmd-set-text ?")
config.bind(
    ",j",
    "config-cycle -u *://*.{url:host}/* colors.webpage.darkmode.enabled True False ;; reload",
)
config.bind(",k", "config-cycle colors.webpage.bg white black")
config.bind(",w", "open -w {url}")
config.bind(",c", "hint links spawn -d google-chrome-stable --incognito {hint-url}")
config.bind(",C", "spawn -d google-chrome-stable --incognito {url}")
config.bind(",g", "cmd-set-text -s :open -t gg ")
config.bind(",b", "cmd-set-text -s :open -t br ")
config.bind(",h", "cmd-set-text -s :open -t gh ")
config.bind(",y", "cmd-set-text -s :open -t yt ")

# Arch Wiki
config.bind(",a", "cmd-set-text -s :open -t aw ")
config.bind("<Ctrl-N>", "open -w")
config.bind("<Ctrl-Shift-N>", "open -p")
config.bind("<Escape>", "clear-keychain ;; search ;; stop")
config.bind("<F11>", "fullscreen")
config.bind("<F12>", "devtools bottom")
config.bind("<F5>", "reload")
config.bind("<Space>", "nop")
config.bind("<Return>", "selection-follow")
config.bind("F", "hint all tab")
config.bind("G", "scroll-to-perc")
config.bind("I", "mode-enter passthrough")
config.bind("P", "open -t -- {clipboard}")
config.bind("Q", "cmd-set-text -s :session-load")
config.bind("R", "reload -f")
config.bind("X", "undo")
config.bind("ZX", "cmd-set-text -s :session-save --only-active-window")

# Note: the downside of this approach is that, we can only save and close one
# one session. if we have two session opened, this mapping will screw up our session.
# Ref: https://github.com/qutebrowser/qutebrowser/issues/572
# config.bind('ZZ', 'cmd-set-text session-save --only-active-window;; cmd-set-text --append close')
config.bind("[[", "navigate prev")
config.bind("]]", "navigate next")
config.bind("ad", "download-cancel")
config.bind("cd", "download-clear")
config.bind("cn", "hint inputs")
config.bind("cw", "cmd-set-text :open {url:pretty}")
config.bind("cW", "cmd-set-text :open -t -r {url:pretty}")
config.bind("cb", "cmd-set-text -s :open -b")
config.bind("cB", "cmd-set-text :open -b -r {url:pretty}")
config.bind("d", "scroll-page 0 0.5")
config.bind("gh", "navigate strip")
config.bind("gi", "hint inputs --first")
config.bind("gt", "cmd-set-text -s :tab-give")
config.bind("gu", "navigate up")
config.bind("gf", "hint all tab-fg")
config.bind("h", "scroll left")
config.bind("i", "mode-enter insert")
config.bind("j", "scroll down")
config.bind("k", "scroll up")
config.bind("l", "scroll right")
config.bind("n", "search-next")
config.bind("t", "cmd-set-text -sr :tab-focus --no-last")
config.bind("u", "undo")
config.bind("v", "mode-enter caret")
config.bind("x", "tab-close")

# Bindings for insert mode
config.bind("<Escape>", "mode-leave", mode="insert")
config.bind("<Shift-Escape>", "mode-enter passthrough", mode="insert")
config.bind("<Ctrl-H>", "fake-key <Backspace>", mode="insert")
config.bind("<Ctrl-M>", "fake-key <Enter>", mode="insert")
config.bind("<Ctrl-I>", "fake-key <Tab>", mode="insert")
config.bind("<Ctrl-A>", "fake-key <Home>", mode="insert")
config.bind("<Ctrl-E>", "fake-key <End>", mode="insert")
config.bind("<Ctrl-B>", "fake-key <Left>", mode="insert")
config.bind("<Ctrl-F>", "fake-key <Right>", mode="insert")
config.bind("<Ctrl-P>", "fake-key <Up>", mode="insert")
config.bind("<Ctrl-N>", "fake-key <Down>", mode="insert")
config.bind("<Ctrl-D>", "fake-key <Delete>", mode="insert")
config.bind("<Ctrl-W>", "fake-key <Ctrl-Backspace>", mode="insert")
config.bind("<Ctrl-U>", "fake-key <Shift-Home><Delete>", mode="insert")
config.bind("<Ctrl-K>", "fake-key <Shift-End><Delete>", mode="insert")

# Bindings for command mode
config.bind("<Ctrl-Alt-H>", "rl-backward-kill-word", mode="command")
config.bind("<Alt-Backspace>", "rl-backward-kill-word", mode="command")
config.bind("<Alt-D>", "rl-kill-word", mode="command")
config.bind("<Ctrl-A>", "rl-beginning-of-line", mode="command")
config.bind("<Ctrl-B>", "rl-backward-char", mode="command")
config.bind("<Alt-B>", "rl-backward-word", mode="command")
config.bind("<Ctrl-E>", "rl-end-of-line", mode="command")
config.bind("<Ctrl-F>", "rl-forward-char", mode="command")
config.bind("<Alt-F>", "rl-forward-word", mode="command")
config.bind("<Ctrl-H>", "rl-backward-delete-char", mode="command")
config.bind("<Ctrl-K>", "rl-kill-line", mode="command")
config.bind("<Ctrl-L>", "clear-messages", mode="command")
config.bind("<Ctrl-N>", "completion-item-focus next", mode="command")
config.bind("<Ctrl-P>", "completion-item-focus prev", mode="command")
config.bind("<Ctrl-U>", "rl-unix-line-discard", mode="command")
config.bind("<Ctrl-W>", 'rl-rubout " "', mode="command")
config.bind("<Return>", "command-accept", mode="command")
config.bind("<Escape>", "mode-leave", mode="command")
config.bind("<Ctrl-C>", "mode-leave", mode="command")
config.bind("<Down>", "completion-item-focus --history next", mode="command")
config.bind("<Up>", "completion-item-focus --history prev", mode="command")

## Bindings for caret mode
config.bind("$", "move-to-end-of-line", mode="caret")
config.bind("0", "move-to-start-of-line", mode="caret")
config.bind("<Escape>", "mode-leave", mode="caret")
config.bind("<Ctrl-C>", "mode-leave", mode="caret")
config.bind("<Return>", "yank selection", mode="caret")
config.bind("<Space>", "selection-toggle", mode="caret")
config.bind("<Ctrl-L>", "clear-messages", mode="caret")
config.bind("G", "move-to-end-of-document", mode="caret")
config.bind("H", "scroll left", mode="caret")
config.bind("J", "scroll down", mode="caret")
config.bind("K", "scroll up", mode="caret")
config.bind("L", "scroll right", mode="caret")
config.bind("V", "selection-toggle --line", mode="caret")
config.bind("[", "move-to-start-of-prev-block", mode="caret")
config.bind("]", "move-to-start-of-next-block", mode="caret")
config.bind("b", "move-to-prev-word", mode="caret")
config.bind("c", "mode-enter normal", mode="caret")
config.bind("e", "move-to-end-of-word", mode="caret")
config.bind("g_", "move-to-end-of-line", mode="caret")
config.bind("gg", "move-to-start-of-document", mode="caret")
config.bind("h", "move-to-prev-char", mode="caret")
config.bind("j", "move-to-next-line", mode="caret")
config.bind("k", "move-to-prev-line", mode="caret")
config.bind("l", "move-to-next-char", mode="caret")
config.bind("o", "selection-reverse", mode="caret")
config.bind("w", "move-to-next-word", mode="caret")
config.bind("y", "yank selection", mode="caret")
config.bind("{", "move-to-end-of-prev-block", mode="caret")
config.bind("}", "move-to-end-of-next-block", mode="caret")

## Bindings for hint mode
config.bind("<Escape>", "mode-leave", mode="hint")
config.bind("<Ctrl-C>", "mode-leave", mode="hint")

## Bindings for passthrough mode
config.bind("<Shift-Escape>", "mode-leave", mode="passthrough")

## Bindings for prompt mode
config.bind("<Ctrl-Alt-H>", "rl-backward-kill-word", mode="prompt")
config.bind("<Ctrl-Shift-Y>", "prompt-yank --sel", mode="prompt")
config.bind("<Ctrl-Y>", "prompt-yank", mode="prompt")
config.bind("<Ctrl-A>", "rl-beginning-of-line", mode="prompt")
config.bind("<Ctrl-B>", "rl-backward-char", mode="prompt")
config.bind("<Ctrl-E>", "rl-end-of-line", mode="prompt")
config.bind("<Ctrl-F>", "rl-forward-char", mode="prompt")
config.bind("<Ctrl-H>", "rl-backward-delete-char", mode="prompt")
config.bind("<Ctrl-K>", "rl-kill-line", mode="prompt")
config.bind("<Ctrl-Shift-W>", "rl-filename-rubout", mode="prompt")
config.bind("<Ctrl-U>", "rl-unix-line-discard", mode="prompt")
config.bind("<Ctrl-W>", 'rl-rubout " "', mode="prompt")
config.bind("<Ctrl-X>", "prompt-open-download", mode="prompt")
config.bind("<Down>", "prompt-item-focus next", mode="prompt")
config.bind("<Escape>", "mode-leave", mode="prompt")
config.bind("<Ctrl-C>", "mode-leave", mode="prompt")
config.bind("<Return>", "prompt-accept", mode="prompt")
config.bind("<Ctrl-P>", "prompt-item-focus prev", mode="prompt")
config.bind("<Ctrl-N>", "prompt-item-focus next", mode="prompt")
config.bind("<Up>", "prompt-item-focus prev", mode="prompt")

## Bindings for register mode
config.bind("<Escape>", "mode-leave", mode="register")
config.bind("<Ctrl-C>", "mode-leave", mode="register")

## Bindings for yesno mode
config.bind("<Ctrl-Shift-Y>", "prompt-yank --sel", mode="yesno")
config.bind("<Ctrl-Y>", "prompt-yank", mode="yesno")
config.bind("<Escape>", "mode-leave", mode="yesno")
config.bind("<Ctrl-C>", "mode-leave", mode="yesno")
config.bind("<Return>", "prompt-accept", mode="yesno")
config.bind("N", "prompt-accept --save no", mode="yesno")
config.bind("Y", "prompt-accept --save yes", mode="yesno")
config.bind("n", "prompt-accept no", mode="yesno")
config.bind("y", "prompt-accept yes", mode="yesno")

# keybinding changes
config.bind("cc", 'hint images spawn sh -c "cliphist link {hint-url}"')
config.bind("cs", "cmd-set-text -s :config-source")
config.bind("tH", "config-cycle tabs.show multiple never")
config.bind("sH", "config-cycle statusbar.show always never")
config.bind("T", "hint links tab")
config.bind("pP", "open -- {primary}")
config.bind("pp", "open -- {clipboard}")
config.bind("pt", "open -t -- {clipboard}")
config.bind("pT", "open -t -- {primary}")
config.bind("qm", "macro-record")
config.bind("@", "macro-run")
config.bind("tT", "config-cycle tabs.position top left")
config.bind("gJ", "tab-move +")
config.bind("gK", "tab-move -")
config.bind("gm", "tab-move")

# Player: mpv on Linux, mpv.net on Windows.
# ,m = pick a link via hint and open it in the player (lowercase-hint
#      pattern, same as ,c / ,C above); ,M = open the current page in the player.
if platform.system() == "Windows":
    MPV_CMD = "C:/Users/USER/AppData/Local/Programs/mpv.net/mpvnet.exe"
else:
    MPV_CMD = "mpv"

config.bind(",m", f"hint links spawn --detach {MPV_CMD} {{hint-url}}")
config.bind(",M", f"spawn --detach {MPV_CMD} {{url}}")

config.bind(",ss", "cmd-set-text -s :session-save ")
config.bind(",sl", "cmd-set-text -s :session-load ")

# Config
config.bind(",e", "config-edit")
config.bind(",r", "restart")

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.bg = "black"
c.colors.webpage.preferred_color_scheme = "dark"

c.content.webgl = False
c.content.canvas_reading = False
c.content.geolocation = False
c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.content.cookies.accept = (
    "all"  # switch to "no-3rdparty" if you want to block third-party cookies
)
c.content.cookies.store = True
