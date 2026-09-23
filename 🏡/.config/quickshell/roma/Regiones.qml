// REGIONES -- the workspaces, as Augustus's numbered districts of Rome.
import QtQuick
import Quickshell.Hyprland

Item {
	id: root

	implicitWidth: row.implicitWidth
	implicitHeight: Theme.barHeight

	Row {
		id: row
		anchors.verticalCenter: parent.verticalCenter
		spacing: 2

		Repeater {
			model: Hyprland.workspaces.values.filter(w => w.id > 0).slice().sort((a, b) => a.id - b.id)
			delegate: Item {
				id: regio

				required property var modelData
				readonly property bool focused: Hyprland.focusedWorkspace
					&& Hyprland.focusedWorkspace.id === modelData.id

				readonly property int windows: modelData.lastIpcObject?.windows ?? 0
				readonly property bool occupied: windows > 0

				implicitWidth: numeral.implicitWidth + 12
				implicitHeight: Theme.barHeight

				Fastigium {
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: parent.top
					anchors.topMargin: 3
					color: Theme.accent
					visible: regio.focused
				}

				Inscriptio {
					id: numeral
					anchors.centerIn: parent
					text: Lexicon.numeral(regio.modelData.id)
					font.pixelSize: Theme.fontSizeNumeral
					color: regio.focused ? Theme.accentBright : hover.containsMouse ? Theme.accentDim : regio.occupied ? Theme.text : Theme.muted
					Behavior on color {ColorAnimation {duration: 120}}
				}

				Rectangle {
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 4
					anchors.left: parent.left
					anchors.right: parent.right
					height: 1
					color: Theme.accent
					visible: regio.focused
				}

				MouseArea {
					id: hover
					anchors.fill: parent
					hoverEnabled: true
					onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${regio.modelData.id} })`)
				}
			}
		}
	}
}
