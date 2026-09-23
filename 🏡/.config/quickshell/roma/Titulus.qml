// TITULUS -- an inscription, a label. The focused window.
import QtQuick
import Quickshell.Wayland

Item {
	id: root

	readonly property Toplevel fenestra: ToplevelManager.activeToplevel
	implicitHeight: Theme.barHeight

	Row {
		anchors.verticalCenter: parent.verticalCenter
		spacing: 6

		Inscriptio {
			text: root.fenestra?.appId ?? ""
			visible: text !== ""
			color: Theme.accentDim
			anchors.verticalCenter: parent.verticalCenter
			capitalise: true
		}

		Inscriptio {
			width: Math.min(implicitWidth, root.width - x)
			text: root.fenestra?.title ?? ""
			inscriptional: false
			color: Theme.muted
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
