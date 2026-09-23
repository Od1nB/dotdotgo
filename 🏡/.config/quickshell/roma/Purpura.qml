pragma Singleton

// PURPURA -- the imperial scheme. Porphyry and gold, for night.
import QtQuick
import Quickshell

Singleton {
	id: root

	readonly property string title: "purpura"
	readonly property bool dark: true
	readonly property real groundAlpha: 0.85

	readonly property color nox: "#160D1F"
	readonly property color porphyrus: "#221630"

	readonly property color murex: "#33203F" // ≈ cygnus `surface` #3a2450
	readonly property color vinum: "#4A2F5C" // wine; hairlines and column flutes
	readonly property color cinis: "#8A7A9B" // ash; cygnus `muted`, untouched

	readonly property color marmor: "#EDE3D4" // marble gold

	readonly property color aurum: "#E8B23C" // gold. sits in #ff6ec7's old seat
	readonly property color aurumClarum: "#F7D678" // hover, focus, sheen
	readonly property color aes: "#A9762F" // bronze; second-tier, separators
	readonly property color lavendula: "#E0B0FF" // kept from cygnus: kitty's cursor

	readonly property color laurus: "#8FBF5A" // laurel
	readonly property color aqua: "#7FC7D9" // the aqueducts
	readonly property color terracotta: "#E0913C"
	readonly property color sanguis: "#D2402F"

	readonly property color ground: nox
	readonly property color surface: porphyrus
	readonly property color raised: murex
	readonly property color rule: vinum

	readonly property color text: marmor
	readonly property color textAlt: lavendula
	readonly property color muted: cinis

	readonly property color accent: aurum
	readonly property color accentBright: aurumClarum
	readonly property color accentDim: aes

	readonly property color ok: laurus
	readonly property color info: aqua
	readonly property color warn: terracotta
	readonly property color crit: sanguis
}
