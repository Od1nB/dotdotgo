// HORA -- the clock, and DIES, the date.
import QtQuick
import Quickshell

Item {
	id: root

	implicitWidth: row.implicitWidth
	implicitHeight: Theme.barHeight

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}

	Row {
		id: row
		anchors.verticalCenter: parent.verticalCenter
		spacing: Theme.gap

		Modulus {
			showLabel: false
			value: Qt.formatDateTime(clock.date, "HH:mm")
			valueColor: Theme.text
			motto: Lexicon.motto("hora")
			anchors.verticalCenter: parent.verticalCenter
		}

		Item {
			id: dies

			implicitWidth: stamp.implicitWidth + Theme.gap * 2
			implicitHeight: Theme.barHeight
			anchors.verticalCenter: parent.verticalCenter
			Rectangle {
				anchors.fill: parent
				radius: Theme.radius
				color: Theme.accent
				opacity: Theme.stateLayers && (pointer.containsMouse || Kalendarium.open) ? 0.10 : 0
				visible: opacity > 0

				Behavior on opacity {
					NumberAnimation {
						duration: 120
					}
				}
			}

			Fastigium {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: 3
				color: Theme.accent
				visible: Kalendarium.open
			}

			Inscriptio {
				id: stamp
				anchors.centerIn: parent
				text: Lexicon.romanDate(clock.date)
				color: Kalendarium.open ? Theme.accentBright : pointer.containsMouse ? Theme.accent : Theme.accentDim
				Behavior on color {
					ColorAnimation {
						duration: 120
					}
				}
			}

			MouseArea {
				id: pointer
				anchors.fill: parent
				hoverEnabled: true
				onClicked: Kalendarium.toggle()
			}
		}
	}
}
