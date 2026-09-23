// The bar. An entablature: the horizontal band a temple's columns hold up.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
	id: root

	anchors.top: true
	anchors.left: true
	anchors.right: true
	implicitHeight: Theme.barHeight + Theme.corniceHeight
	color: Theme.barColor
	WlrLayershell.namespace: "roma"
	visible: !retracted
	property bool retracted: false
	onRetractedChanged: if (retracted) Kalendarium.close()

	Connections {
		target: Hyprland

		function onRawEvent(event: HyprlandEvent): void {
			// Hyprland emits `fullscreen>>1` and `fullscreen>>0` for the focused
			// window entering and leaving fullscreen.
			if (event.name === "fullscreen") {
				root.retracted = event.data === "1"
				return
			}

			if (event.name === "workspacev2" || event.name === "focusedmon")
				root.retracted = false
		}
	}
	Item {
		id: frieze

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.leftMargin: Theme.padH
		anchors.rightMargin: Theme.padH
		height: Theme.barHeight

		Row {
			id: left
			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.groupGap

			Sigillum {anchors.verticalCenter: parent.verticalCenter}
			Columna {anchors.verticalCenter: parent.verticalCenter}
		}

		Row {
			id: centre
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.groupGap

			Columna {anchors.verticalCenter: parent.verticalCenter}
			Regiones {anchors.verticalCenter: parent.verticalCenter}
			Columna {anchors.verticalCenter: parent.verticalCenter}
		}

		Row {
			id: right
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.groupGap

			Carmen {anchors.verticalCenter: parent.verticalCenter}
			Columna {anchors.verticalCenter: parent.verticalCenter}

			Row {
				anchors.verticalCenter: parent.verticalCenter
				spacing: Theme.groupGap

				Sonus {}
				Via {}
				Calor {}
				Onus {}
			}

			Columna {anchors.verticalCenter: parent.verticalCenter}
			Lararium {anchors.verticalCenter: parent.verticalCenter}
			Nuntii {anchors.verticalCenter: parent.verticalCenter}
			Columna {anchors.verticalCenter: parent.verticalCenter}
			Hora {anchors.verticalCenter: parent.verticalCenter}
		}

		Titulus {
			anchors.left: left.right
			anchors.right: centre.left
			anchors.leftMargin: Theme.groupGap
			anchors.rightMargin: Theme.groupGap
			anchors.verticalCenter: parent.verticalCenter
			clip: true
		}
	}

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		height: Theme.corniceHeight
		color: Theme.accent
	}

	PopupWindow {
		id: tooltip

		readonly property bool mine: Monitum.active
			&& Monitum.anchorItem.Window.window === frieze.Window.window

		anchor.item: mine ? Monitum.anchorItem : null
		anchor.rect.y: Theme.barHeight + 6
		anchor.adjustment: PopupAdjustment.SlideX

		visible: mine

		implicitWidth: phrase.implicitWidth + 20
		implicitHeight: phrase.implicitHeight + 12
		color: "transparent"

		Rectangle {
			anchors.fill: parent
			color: Theme.popupColor
			border.width: 1
			border.color: Theme.rule

			Inscriptio {
				id: phrase
				anchors.centerIn: parent
				text: Monitum.text
				inscriptional: false
				color: Theme.text
			}
		}
	}
}
