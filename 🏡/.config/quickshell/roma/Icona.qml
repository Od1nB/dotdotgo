// ICONA -- the drawn icons.
import QtQuick
import QtQuick.Shapes

Shape {
	id: root

	property string name: "" // Which icon; unkown => nothing drawn
	property color color: Theme.muted
	property real thickness: 1.5
	readonly property int grid: 16

	implicitWidth: grid
	implicitHeight: grid
	preferredRendererType: Shape.CurveRenderer

	readonly property var paths: ({
		// A chip
		"chip": "M4.5 4.5 h7 v7 h-7 z"
			+ " M6.75 6.75 h2.5 v2.5 h-2.5 z"
			+ " M6.5 2.5 v2 M9.5 2.5 v2 M6.5 11.5 v2 M9.5 11.5 v2"
			+ " M2.5 6.5 h2 M2.5 9.5 h2 M11.5 6.5 h2 M11.5 9.5 h2",

		// A thermometer
		"thermostat": "M8 3.5 v5.5"
			+ " M6 11 a2 2 0 1 0 4 0 a2 2 0 1 0 -4 0",

		// Speaker cone plus two sound arcs.
		"volume": "M3 6.5 h2 l3 -2.5 v8 l-3 -2.5 h-2 z"
			+ " M10.5 6.25 a3.2 3.2 0 0 1 0 3.5"
			+ " M12.5 4.5 a5.6 5.6 0 0 1 0 7",
		"volumeMute": "M3 6.5 h2 l3 -2.5 v8 l-3 -2.5 h-2 z"
			+ " M10.5 6.5 l3.5 3 M14 6.5 l-3.5 3",

		// Ascending bars
		"network": "M3 12.5 v-1.5 M6.5 12.5 v-4 M10 12.5 v-6.5 M13.5 12.5 v-9",
		"networkOff": "M3 12.5 v-1.5 M6.5 12.5 v-4 M10 12.5 v-6.5 M13.5 12.5 v-9"
			+ " M2.5 13.5 l11 -11",

		// Media transport
		"play": "M5.5 3.5 l7 4.5 l-7 4.5 z",
		"pause": "M6 4 v8 M10 4 v8",

		// A bell
		"bell": "M8 2.5 a4 4 0 0 1 4 4 v2.75 l1.25 1.75 h-10.5 l1.25 -1.75 v-2.75 a4 4 0 0 1 4 -4 z"
			+ " M6.5 11 a1.5 1.5 0 0 0 3 0",

		// Month steppers for the fasti. Two lines and no arrowhead <>
		"chevronLeft": "M10 3.5 L5.5 8 L10 12.5",
		"chevronRight": "M6 3.5 L10.5 8 L6 12.5"
	})

	readonly property string pathData: paths[name] ?? ""
	visible: pathData !== ""

	ShapePath {
		strokeColor: root.color
		strokeWidth: root.thickness
		fillColor: root.name === "play" ? root.color : "transparent"
		capStyle: ShapePath.RoundCap
		joinStyle: ShapePath.RoundJoin

		PathSvg {
			path: root.pathData
		}
	}
}
