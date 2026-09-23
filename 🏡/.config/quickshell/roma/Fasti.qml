// FASTI -- the calendar, hanging from the date.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: root

	readonly property int weekStart: 1 // Monday

	readonly property int cellW: 32
	readonly property int cellH: 26
	readonly property int pad: 12
	readonly property int gridW: cellW * 7

	readonly property var days: {
		const first = Kalendarium.shown
		const lead = (first.getDay() - root.weekStart + 7) % 7

		const out = []
		for (let i = 0; i < 42; i++)
			out.push(new Date(first.getFullYear(), first.getMonth(), 1 - lead + i))
		return out
	}

	anchors.top: true
	anchors.left: true
	anchors.right: true
	anchors.bottom: true

	color: "transparent"
	visible: Kalendarium.open

	WlrLayershell.namespace: "roma-fasti"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	MouseArea {
		anchors.fill: parent
		onClicked: Kalendarium.close()
	}

	Rectangle {
		id: tablet

		anchors.top: parent.top
		anchors.right: parent.right
		anchors.topMargin: Theme.barHeight + Theme.corniceHeight + 5
		anchors.rightMargin: Theme.padH

		width: root.gridW + root.pad * 2
		height: body.implicitHeight + root.pad * 2

		color: Theme.popupColor
		border.width: 1
		border.color: Theme.rule

		Rectangle {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.margins: 1
			height: 2
			color: Theme.accent
		}

		MouseArea {
			anchors.fill: parent
			onWheel: wheel => {
				if (wheel.angleDelta.y > 0)
					Kalendarium.prevMonth()
				else if (wheel.angleDelta.y < 0)
					Kalendarium.nextMonth()
			}
		}

		Column {
			id: body

			anchors.top: parent.top
			anchors.left: parent.left
			anchors.margins: root.pad

			width: root.gridW
			spacing: 5

			Item {
				width: parent.width
				height: 24

				Icona {
					id: back
					name: "chevronLeft"
					color: backHit.containsMouse ? Theme.accentBright : Theme.accentDim
					anchors.left: parent.left
					anchors.verticalCenter: parent.verticalCenter
				}

				MouseArea {
					id: backHit
					anchors.fill: back
					anchors.margins: -4 // 16px square is under a comfortable target size
					hoverEnabled: true
					onClicked: Kalendarium.prevMonth()
				}

				Inscriptio {
					anchors.left: back.right
					anchors.right: fwd.left
					anchors.leftMargin: 4
					anchors.rightMargin: 4
					anchors.verticalCenter: parent.verticalCenter
					horizontalAlignment: Text.AlignHCenter

					text: {
						const when = Kalendarium.shown
						const m = Lexicon.month(when.getMonth() + 1)
						const y = Lexicon.numeral(when.getFullYear())
						return m + (Theme.orthographia ? Lexicon.interpunct : " ") + y
					}
					color: Theme.accent
				}

				Icona {
					id: fwd
					name: "chevronRight"
					color: fwdHit.containsMouse ? Theme.accentBright : Theme.accentDim
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
				}

				MouseArea {
					id: fwdHit
					anchors.fill: fwd
					anchors.margins: -4
					hoverEnabled: true
					onClicked: Kalendarium.nextMonth()
				}
			}

			Rectangle {
				width: parent.width
				height: 1
				color: Theme.rule
			}

			Row {
				width: parent.width

				Repeater {
					model: 7

					delegate: Inscriptio {
						required property int index
						text: Lexicon.weekday((index + root.weekStart) % 7, true)
						color: Theme.accentDim
						width: root.cellW
						horizontalAlignment: Text.AlignHCenter
					}
				}
			}

			Grid {
				columns: 7

				Repeater {
					model: root.days

					delegate: Item {
						id: dies

						required property var modelData
						readonly property bool inMonth: modelData.getMonth() === Kalendarium.shown.getMonth()
						readonly property bool hodie: modelData.getFullYear() === Kalendarium.today.getFullYear()
							&& modelData.getMonth() === Kalendarium.today.getMonth()
							&& modelData.getDate() === Kalendarium.today.getDate()

						implicitWidth: root.cellW
						implicitHeight: root.cellH

						Fastigium {
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.top: parent.top
							color: Theme.accent
							visible: dies.hodie
						}

						Inscriptio {
							anchors.centerIn: parent
							text: String(dies.modelData.getDate())
							inscriptional: false
							color: dies.hodie ? Theme.accentBright : dies.inMonth ? Theme.text : Theme.muted
							horizontalAlignment: Text.AlignHCenter
						}

						Rectangle {
							anchors.bottom: parent.bottom
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.leftMargin: 6
							anchors.rightMargin: 6
							height: 1
							color: Theme.accent
							visible: dies.hodie
						}
					}
				}
			}

			Item {
				width: parent.width
				height: 16

				Inscriptio {
					id: hodieLink
					anchors.centerIn: parent
					text: Lexicon.label("hodie")
					color: hodieHit.containsMouse ? Theme.accentBright : Theme.accentDim
					visible: Kalendarium.monthOffset !== 0
				}

				MouseArea {
					id: hodieHit
					anchors.fill: hodieLink
					anchors.margins: -4
					hoverEnabled: true
					enabled: hodieLink.visible
					onClicked: Kalendarium.hodie()
				}
			}
		}
	}
}
