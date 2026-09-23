// S·P·Q·R -- Senatus Populusque Romanus. The far-left mark.
import QtQuick

Item {
	id: root

	implicitWidth: mark.implicitWidth
	implicitHeight: Theme.barHeight

	Inscriptio {
		id: mark
		anchors.verticalCenter: parent.verticalCenter
		text: Lexicon.sigil
		color: pointer.containsMouse ? Theme.accentBright : Theme.accent

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

		onEntered: Monitum.show(root, Lexicon.motto("sigil"))
		onExited: Monitum.hide(root)
		onClicked: Theme.setScheme(Theme.nextScheme())
	}
}
