pragma Singleton

// The bar's one source of colour, type and metrics.
//
// House rule: no other file in this config contains a hex literal. That is not
// tidiness, it is what makes `toga` work -- a leaked literal is a thing that
// silently keeps its old colour when the scheme changes, and you find it weeks
// later. Enforceable:
//
//     grep -rn '#[0-9a-fA-F]\{6\}' ~/.config/quickshell/roma --include='*.qml' \
//       | grep -v 'Purpura.qml\|Marmor.qml'
//
// Switching schemes, live:
//
//     qs ipc call theme toga marmor
//     qs ipc call theme toga            # no argument toggles
//
// QtQuick is needed for two things that look like they should be free: the `color`
// value type used by every role below, and Qt.fontFamilies() for the Cinzel probe.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property string scheme: "purpura"
	readonly property var schemes: ({
		"purpura": Purpura,
		"vexillum": Vexillum,
		"marmor": Marmor
	})

	readonly property var order: ["purpura", "vexillum", "marmor"]

	readonly property var palette: schemes[scheme] ?? Purpura
	readonly property bool dark: palette.dark

	readonly property color ground: palette.ground
	readonly property color surface: palette.surface
	readonly property color raised: palette.raised
	readonly property color rule: palette.rule

	readonly property color text: palette.text
	readonly property color textAlt: palette.textAlt
	readonly property color muted: palette.muted

	readonly property color accent: palette.accent
	readonly property color accentBright: palette.accentBright
	readonly property color accentDim: palette.accentDim

	readonly property color ok: palette.ok
	readonly property color info: palette.info
	readonly property color warn: palette.warn
	readonly property color crit: palette.crit

	readonly property string fontMono: "JetBrains Mono"

	readonly property bool hasCinzel: Qt.fontFamilies().indexOf("Cinzel") !== -1
	readonly property string fontInscription: hasCinzel ? "Cinzel" : fontMono

	readonly property int fontSize: 13 // under the terminals' 15: a bar is not prose
	readonly property int fontSizeNumeral: 14
	readonly property real letterSpacing: hasCinzel ? 0.8 : 1.5

	readonly property int barHeight: 28
	readonly property int corniceHeight: 1 // the gold drip edge along the bottom
	readonly property int padH: 10 // inside the bar's left and right ends
	readonly property int gap: 8 // between items within a group
	readonly property int groupGap: 12 // either side of a columna

	// Corner radius for hover state layers and tooltips. Small: Material's own scale
	// starts around 8 for a chip, and anything rounder than this on a 28px bar starts
	// looking like a lozenge.
	readonly property int radius: 6

	property bool stateLayers: true
	property bool showLabels: true
	property bool orthographia: true
	property bool translucent: true

	readonly property color barColor: Qt.rgba(
		ground.r, ground.g, ground.b,
		translucent ? palette.groundAlpha : 1.0)

	readonly property color popupColor: ground
	readonly property string statePath: (Quickshell.env("XDG_STATE_HOME") || `${Quickshell.env("HOME")}/.local/state`) + "/roma/toga"

	FileView {
		id: state
		path: root.statePath
		blockLoading: true
		printErrors: false

		onLoaded: {
			const saved = text().trim()
			if (saved in root.schemes)
				root.scheme = saved
		}
	}

	Process {
		id: persist
		command: ["sh", "-c", 'mkdir -p "$(dirname "$1")" && printf %s "$2" > "$1"', "sh", root.statePath, root.scheme]
	}

	function setScheme(name: string): void {
		if (!(name in root.schemes))
			return
		if (name === root.scheme)
			return
		root.scheme = name
		persist.running = true
	}

	function nextScheme(): string {
		const i = root.order.indexOf(root.scheme)
		return i === -1 ? root.order[0] : root.order[(i + 1) % root.order.length]
	}

	IpcHandler {
		target: "theme"

		function toga(name: string): string {
			if (name === "")
				root.setScheme(root.nextScheme())
			else
				root.setScheme(name)
			return root.scheme
		}

		function togae(): string {return root.order.join(" ")}
		function orthographia(on: bool): string {
			root.orthographia = on
			return root.orthographia ? "classical" : "modern"
		}
	}
}
