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
		"chevronRight": "M6 3.5 L10.5 8 L6 12.5",

		// A laurel wreath, filled
		"laurel": "M7.6 14.7 C4.3 13.1 2.75 9.2 3.2 3.5 C2.2 9 4 12.5 7.6 14 Z"
			+ " M8.4 14 C12 12.5 13.8 9 12.8 3.5 C13.25 9.2 11.7 13.1 8.4 14.7 Z"
			+ " M6.2 13.25 Q5.6 15.03 3.52 14.69 Q4.38 12.77 6.2 13.25 Z"
			+ " M4.66 11.86 Q3.25 13.24 1.46 11.93 Q3.19 10.54 4.66 11.86 Z"
			+ " M4.66 11.86 Q3.32 11.03 3.99 9.39 Q5.4 10.47 4.66 11.86 Z"
			+ " M3.54 9.93 Q1.76 10.52 0.78 8.66 Q2.83 8.19 3.54 9.93 Z"
			+ " M3.54 9.93 Q2.69 8.69 3.91 7.53 Q4.72 9 3.54 9.93 Z"
			+ " M3 7.65 Q1.32 7.52 1.16 5.64 Q3.02 5.97 3 7.65 Z"
			+ " M3 7.65 Q2.64 6.36 4.01 5.72 Q4.26 7.21 3 7.65 Z"
			+ " M2.96 5.39 Q1.65 4.84 2.02 3.29 Q3.42 4.05 2.96 5.39 Z"
			+ " M3.2 3.5 Q2.4 2.26 3.63 1.14 Q4.39 2.62 3.2 3.5 Z"
			+ " M9.8 13.25 Q11.62 12.77 12.48 14.69 Q10.4 15.03 9.8 13.25 Z"
			+ " M11.34 11.86 Q12.81 10.54 14.54 11.93 Q12.75 13.24 11.34 11.86 Z"
			+ " M11.34 11.86 Q10.6 10.47 12.01 9.39 Q12.68 11.03 11.34 11.86 Z"
			+ " M12.46 9.93 Q13.17 8.19 15.22 8.66 Q14.24 10.52 12.46 9.93 Z"
			+ " M12.46 9.93 Q11.28 9 12.09 7.53 Q13.31 8.69 12.46 9.93 Z"
			+ " M13 7.65 Q12.98 5.97 14.84 5.64 Q14.68 7.52 13 7.65 Z"
			+ " M13 7.65 Q11.74 7.21 11.99 5.72 Q13.36 6.36 13 7.65 Z"
			+ " M13.04 5.39 Q12.58 4.05 13.98 3.29 Q14.35 4.84 13.04 5.39 Z"
			+ " M12.8 3.5 Q11.61 2.62 12.37 1.14 Q13.6 2.26 12.8 3.5 Z"
			+ " M8 13.6 Q7.6 14.8 7.4 15.9 Q6.9 15.7 6.2 15.9 Q7 14.6 8 13.6 Z"
			+ " M8 13.6 Q9 14.6 9.8 15.9 Q9.1 15.7 8.6 15.9 Q8.4 14.8 8 13.6 Z"
			+ " M7 13.8 A1 1 0 0 1 9 13.8 A1 1 0 0 1 7 13.8 Z"
	})

	// Icons drawn solid rather than as outlines.
	readonly property var filled: ["play", "laurel"]

	readonly property string pathData: paths[name] ?? ""
	visible: pathData !== ""

	ShapePath {
		strokeColor: root.color
		strokeWidth: root.thickness
		fillColor: root.filled.indexOf(root.name) !== -1 ? root.color : "transparent"
		fillRule: ShapePath.WindingFill
		capStyle: ShapePath.RoundCap
		joinStyle: ShapePath.RoundJoin

		PathSvg {
			path: root.pathData
		}
	}
}
