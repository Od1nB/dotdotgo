// LARARIUM -- the tray shrine.
// Not all features enabled yet, context menu, etc
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
	id: root

	implicitWidth: row.implicitWidth
	implicitHeight: Theme.barHeight
	visible: SystemTray.items.values.length > 0

	Row {
		id: row
		anchors.verticalCenter: parent.verticalCenter
		spacing: Theme.gap

		Repeater {
			model: SystemTray.items

			delegate: Item {
				id: figura

				required property var modelData

				implicitWidth: 24
				implicitHeight: 24
				anchors.verticalCenter: parent.verticalCenter
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

				IconImage {
					anchors.centerIn: parent
					implicitSize: 16
					source: figura.modelData.icon
					opacity: pointer.containsMouse ? 1.0 : 0.75
				}

				MouseArea {
					id: pointer
					anchors.fill: parent
					hoverEnabled: true
					acceptedButtons: Qt.LeftButton | Qt.MiddleButton

					onEntered: Monitum.show(figura, figura.modelData.tooltipTitle || figura.modelData.title || "")
					onExited: Monitum.hide(figura)

					onClicked: mouse => {
						if (mouse.button === Qt.LeftButton)
							figura.modelData.activate()
						else
							figura.modelData.secondaryActivate()
					}
				}
			}
		}
	}
}
