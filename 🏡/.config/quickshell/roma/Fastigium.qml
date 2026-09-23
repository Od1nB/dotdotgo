// The pediment over the focused region
import QtQuick
import QtQuick.Shapes

Shape {
	id: root

	property color color: Theme.accent

	implicitWidth: 9
	implicitHeight: 4
	preferredRendererType: Shape.CurveRenderer

	ShapePath {
		strokeWidth: 0
		strokeColor: "transparent"
		fillColor: root.color

		startX: 0
		startY: root.implicitHeight

		PathLine {
			x: root.implicitWidth / 2
			y: 0
		}
		PathLine {
			x: root.implicitWidth
			y: root.implicitHeight
		}
		PathLine {
			x: 0
			y: root.implicitHeight
		}
	}
}
