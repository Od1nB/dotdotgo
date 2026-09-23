// The common shape of a readout: an icon, a small-caps Latin label, then the number.
import QtQuick

Item {
	id: root

	property string label: ""
	property string value: ""
	property string motto: ""
	property color valueColor: Theme.text
	property string icon: "" // Empty draws no icon
	property color iconColor: valueColor
	property bool showLabel: Theme.showLabels

	signal activated(int button)
	signal scrolled(real delta)

	implicitWidth: row.implicitWidth + Theme.padH
	implicitHeight: Theme.barHeight

	Rectangle {
		anchors.fill: parent
		radius: Theme.radius
		color: Theme.accent
		opacity: Theme.stateLayers && pointer.containsMouse ? 0.10 : 0
		visible: opacity > 0

		Behavior on opacity {
			NumberAnimation {
				duration: 120
			}
		}
	}

	Row {
		id: row
		anchors.centerIn: parent
		spacing: 5

		Icona {
			name: root.icon
			color: root.iconColor
			anchors.verticalCenter: parent.verticalCenter
		}

		Inscriptio {
			text: root.label
			visible: root.showLabel && text !== ""
			color: Theme.muted
			anchors.verticalCenter: parent.verticalCenter
		}

		Inscriptio {
			text: root.value
			visible: text !== ""
			inscriptional: false
			color: root.valueColor
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	MouseArea {
		id: pointer
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

		onEntered: Monitum.show(root, root.motto)
		onExited: Monitum.hide(root)
		onClicked: mouse => root.activated(mouse.button)
		onWheel: wheel => root.scrolled(wheel.angleDelta.y)
	}
}
