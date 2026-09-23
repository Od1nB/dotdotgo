// roma -- entry point.
//
// Deliberately thin. Everything interesting is in the files beside it; this one only
// decides what gets instantiated how many times, which is the distinction that has
// bitten most in building this:
//
//   per screen  -- Entablature, because a bar belongs to a monitor
//   exactly one -- Toasts, and the singletons behind it (Tabellarius owns the
//                  org.freedesktop.Notifications DBus name, which admits one owner;
//                  N of them would race and lose notifications silently)
//               -- Fasti, for a different reason: it is one panel about one date, and
//                  its state lives in the Kalendarium singleton. Per-screen instances
//                  would all watch that one bool and all open at once.
//
// Every file in this directory is flat and imports nothing from its siblings.
// Same-directory QML resolves by capitalised filename, and Quickshell's own docs warn
// that `root:/` imports break the LSP and singletons -- so there is no import graph
// here to get wrong.

import Quickshell

ShellRoot {
	Variants {
		model: Quickshell.screens
		Entablature {
			required property var modelData
			screen: modelData
		}
	}
	Toasts {}
	Fasti {}
}
