pragma Singleton

// MARMOR -- the marble scheme. Lime plaster and legion red, for day.
import QtQuick
import Quickshell

Singleton {
	id: root

	readonly property string title: "marmor"
	readonly property bool dark: false

	// Solid, deliberately. Translucency is a dark-mode effect: a light ground bled
	readonly property real groundAlpha: 1.0

	readonly property color calx: "#F5F0E6" // lime plaster. warm, not blue-white
	readonly property color marmor: "#E8E1D3"
	readonly property color tufa: "#D8CFBD"
	readonly property color harena: "#BCB09A" // sand; hairlines and flutes

	readonly property color cinis: "#6E6357"
	readonly property color basaltes: "#241D19"

	readonly property color minium: "#B03224" // red lead, the inscription pigment
	readonly property color miniumObscurum: "#8A2318" // pressed / emphasised
	readonly property color aurum: "#8F6417" // gold, darkened to survive on marble

	readonly property color laurus: "#5E7F31"
	readonly property color aqua: "#2F6F80"
	readonly property color terracotta: "#A9611C"

	readonly property color ground: calx
	readonly property color surface: marmor
	readonly property color raised: tufa
	readonly property color rule: harena

	readonly property color text: basaltes
	readonly property color textAlt: miniumObscurum
	readonly property color muted: cinis

	readonly property color accent: minium
	readonly property color accentBright: miniumObscurum
	readonly property color accentDim: aurum

	readonly property color ok: laurus
	readonly property color info: aqua
	readonly property color warn: terracotta
	readonly property color crit: minium
}
