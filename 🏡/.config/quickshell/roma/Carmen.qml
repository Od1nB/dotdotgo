// CARMEN -- a song. Whatever is playing, over MPRIS.
import QtQuick
import Quickshell.Services.Mpris

Item {
	id: root
	readonly property MprisPlayer player: {
		const all = Mpris.players.values
		if (all.length === 0)
			return null
		return all.find(p => p.isPlaying) ?? all[0]
	}

	readonly property bool has: player !== null

	visible: has
	implicitWidth: has ? row.implicitWidth : 0
	implicitHeight: Theme.barHeight

	Row {
		id: row
		anchors.verticalCenter: parent.verticalCenter
		spacing: 5

		Icona {
			name: root.player?.isPlaying ? "play" : "pause"
			color: root.player?.isPlaying ? Theme.accent : Theme.muted
			anchors.verticalCenter: parent.verticalCenter
		}

		Inscriptio {
			text: Lexicon.label("carmen")
			visible: Theme.showLabels
			color: root.player?.isPlaying ? Theme.accentDim : Theme.muted
			anchors.verticalCenter: parent.verticalCenter
		}

		Inscriptio {
			inscriptional: false
			color: Theme.text
			anchors.verticalCenter: parent.verticalCenter
			width: Math.min(implicitWidth, 220)
			text: {
				if (!root.has)
					return ""
				const title = root.player.trackTitle || ""
				const artist = root.player.trackArtist || ""
				return artist === "" ? title : `${artist} — ${title}`
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton

		onEntered: Monitum.show(root, root.player?.isPlaying ? Lexicon.motto("carmen") : "")
		onExited: Monitum.hide(root)

		onClicked: mouse => {
			if (!root.has)
				return
			if (mouse.button === Qt.LeftButton && root.player.canTogglePlaying)
				root.player.togglePlaying()
			else if (mouse.button === Qt.MiddleButton && root.player.canGoNext)
				root.player.next()
		}
	}
}
