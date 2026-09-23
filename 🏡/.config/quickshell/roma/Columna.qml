// A column, standing between groups of modules.
import QtQuick

Item {
	id: root
	implicitWidth: 7
	implicitHeight: Theme.barHeight - 10
	Row {
		anchors.centerIn: parent
		spacing: 2

		Repeater {
			model: 3

			Rectangle {
				width: 1
				height: root.height
				readonly property bool lit: index === 1
				readonly property color flute: lit ? Theme.accentDim : Theme.rule
				readonly property color fade: Qt.rgba(flute.r, flute.g, flute.b, 0)

				gradient: Gradient {
					GradientStop {
						position: 0.0
						color: fade
					}
					GradientStop {
						position: 0.35
						color: flute
					}
					GradientStop {
						position: 0.65
						color: flute
					}
					GradientStop {
						position: 1.0
						color: fade
					}
				}
			}
		}
	}
}
