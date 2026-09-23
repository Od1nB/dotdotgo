// The notification popups.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
	id: root

	anchors.top: true
	anchors.right: true
	margins.top: Theme.barHeight + 8
	margins.right: 10

	implicitWidth: 340
	implicitHeight: Math.max(1, column.implicitHeight)

	color: "transparent"
	visible: Tabellarius.count > 0

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	Column {
		id: column
		width: parent.width
		spacing: 8

		Repeater {
			model: Tabellarius.live.slice().reverse().slice(0, 4)

			delegate: Rectangle {
				id: tabella

				required property var modelData
				readonly property bool urgent: modelData.urgency === NotificationUrgency.Critical

				width: column.width
				implicitHeight: body.implicitHeight + 16
				height: implicitHeight

				color: Theme.popupColor
				border.width: 1
				border.color: urgent ? Theme.crit : Theme.rule

				Rectangle {
					anchors.left: parent.left
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					anchors.margins: 1
					width: tabella.urgent ? 3 : 2
					color: tabella.urgent ? Theme.crit : Theme.accent
				}

				Column {
					id: body
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: 12
					anchors.rightMargin: 10
					spacing: 3

					Inscriptio {
						text: tabella.modelData.appName || ""
						visible: text !== ""
						capitalise: true
						color: tabella.urgent ? Theme.crit : Theme.accentDim
						width: parent.width
					}

					Inscriptio {
						text: tabella.modelData.summary || ""
						visible: text !== ""
						inscriptional: false
						color: Theme.text
						width: parent.width
					}

					Inscriptio {
						text: tabella.modelData.body || ""
						visible: text !== ""
						inscriptional: false
						color: Theme.muted
						width: parent.width
						wrapMode: Text.WordWrap
						maximumLineCount: 3
					}
				}

				Timer {
					running: !tabella.urgent
					interval: 6000
					onTriggered: tabella.modelData.dismiss()
				}

				MouseArea {
					anchors.fill: parent
					onClicked: tabella.modelData.dismiss()
				}
			}
		}
	}
}
