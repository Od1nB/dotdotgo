// VALE -- farewell. The laurel that turns the machine off: one click arms it, a
// second within three seconds powers off. Leaving it, or waiting, disarms.
import QtQuick
import Quickshell.Io

Item {
	id: root

	property bool armed: false

	implicitWidth: wreath.implicitWidth + Theme.gap * 2
	implicitHeight: Theme.barHeight

	Rectangle {
		anchors.fill: parent
		radius: Theme.radius
		color: root.armed ? Theme.crit : Theme.accent
		opacity: Theme.stateLayers && (pointer.containsMouse || root.armed) ? 0.10 : 0
		visible: opacity > 0

		Behavior on opacity {
			NumberAnimation {
				duration: 120
			}
		}
	}

	Icona {
		id: wreath
		anchors.centerIn: parent
		name: "laurel"
		thickness: 0.4
		scale: 1.15 // a touch larger than its 16px neighbours: it is the one emblem on the right
		color: root.armed ? Theme.crit : pointer.containsMouse ? Theme.accentBright : Theme.accent

		Behavior on color {
			ColorAnimation {
				duration: 120
			}
		}

		SequentialAnimation on opacity {
			running: root.armed
			loops: Animation.Infinite
			onStopped: wreath.opacity = 1

			NumberAnimation {
				to: 0.55
				duration: 450
				easing.type: Easing.InOutSine
			}
			NumberAnimation {
				to: 1
				duration: 450
				easing.type: Easing.InOutSine
			}
		}
	}

	Timer {
		id: fuse
		interval: 3000 // 3s
		onTriggered: root.armed = false
	}

	Process {
		id: poweroff
		command: ["systemctl", "poweroff"]
	}

	MouseArea {
		id: pointer
		anchors.fill: parent
		hoverEnabled: true

		onEntered: Monitum.show(root, Lexicon.motto("vale"))
		onExited: {
			Monitum.hide(root)
			root.armed = false
			fuse.stop()
		}
		onClicked: {
			if (root.armed) {
				poweroff.running = true
				return
			}
			root.armed = true
			fuse.restart()
			Monitum.hide(root)
			Monitum.show(root, Lexicon.motto("valeArmed"))
		}
	}
}
