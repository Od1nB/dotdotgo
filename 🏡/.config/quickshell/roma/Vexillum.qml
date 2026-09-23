pragma Singleton

// VEXILLUM -- the legionary standard. Legion red on night, for dark.
import QtQuick
import Quickshell

Singleton {
	id: root

	readonly property string title: "vexillum"
	readonly property bool dark: true
	readonly property real groundAlpha: 0.82

	readonly property color tenebrae: "#150F0E"

	readonly property color corium: "#231917" // leather; the tier kitty's bg occupies
	readonly property color scutum: "#33221F" // the shield
	readonly property color lorica: "#4A2F2A" // armour; hairlines and column flutes
	readonly property color cinis: "#9A8A85" // ash, warmed to match. 5.7:1

	readonly property color ebur: "#F2E9E4" // ivory. 15.9:1
	readonly property color palla: "#E9B8A5" // the cloak; secondary lettering

	readonly property color coccum: "#EC4F41" // scarlet, the kermes dye. the standard
	readonly property color flamma: "#FF7A6B" // flame; hover, focus
	readonly property color argilla: "#C08A7C" // clay. see note 1 above

	readonly property color laurus: "#7FB05A" // laurel
	readonly property color aqua: "#6FB8C9" // the aqueducts
	readonly property color crocus: "#E39A46" // saffron
	readonly property color vulnus: "#FF4E63" // a wound. see note 2 above

	readonly property color ground: tenebrae
	readonly property color surface: corium
	readonly property color raised: scutum
	readonly property color rule: lorica

	readonly property color text: ebur
	readonly property color textAlt: palla
	readonly property color muted: cinis

	readonly property color accent: coccum
	readonly property color accentBright: flamma
	readonly property color accentDim: argilla

	readonly property color ok: laurus
	readonly property color info: aqua
	readonly property color warn: crocus
	readonly property color crit: vulnus
}
