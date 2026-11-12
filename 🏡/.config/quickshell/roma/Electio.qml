// ELECTIO -- the choosing. Every sink (or, with `inputs`, every source) PipeWire
// knows, the default marked, and the default's level as a rule you can drag.
import QtQuick
import Quickshell.Services.Pipewire

Column {
	id: root

	property bool inputs: false

	readonly property PwNode current: inputs ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
	readonly property var audio: current?.audio ?? null
	readonly property var nodes: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.isSink === !root.inputs)

	PwObjectTracker {objects: root.nodes.concat([root.current])}

	spacing: 2

	Inscriptio {
		width: parent.width
		height: 22
		text: Lexicon.label(root.inputs ? "aditus" : "exitus")
		color: Theme.accent
	}

	Inscriptio {
		width: parent.width
		height: 26
		visible: root.nodes.length === 0
		text: Lexicon.absent
		inscriptional: false
	}

	Repeater {
		model: root.nodes

		delegate: Item {
			id: row

			required property PwNode modelData
			readonly property bool chosen: modelData === root.current

			width: root.width
			height: 26

			Rectangle {
				anchors.fill: parent
				radius: Theme.radius
				color: Theme.accent
				opacity: Theme.stateLayers && hit.containsMouse ? 0.10 : 0
				visible: opacity > 0
			}

			Rectangle {
				id: mark
				anchors.left: parent.left
				anchors.leftMargin: 6
				anchors.verticalCenter: parent.verticalCenter
				width: 6
				height: 6
				radius: 3
				color: row.chosen ? Theme.accentBright : "transparent"
				border.width: 1
				border.color: row.chosen ? Theme.accentBright : Theme.rule
			}

			Inscriptio {
				anchors.left: mark.right
				anchors.right: parent.right
				anchors.leftMargin: 10
				anchors.rightMargin: 6
				anchors.verticalCenter: parent.verticalCenter
				inscriptional: false
				text: row.modelData.description || row.modelData.nickname || row.modelData.name
				color: row.chosen ? Theme.text : Theme.textAlt
			}

			MouseArea {
				id: hit
				anchors.fill: parent
				hoverEnabled: true
				onClicked: {
					if (root.inputs)
						Pipewire.preferredDefaultAudioSource = row.modelData
					else
						Pipewire.preferredDefaultAudioSink = row.modelData
				}
			}
		}
	}

	// The level of whichever is the default. Click or drag along it; 100% is the end.
	Item {
		width: parent.width
		height: 22
		visible: root.audio !== null

		Rectangle {
			id: track
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.leftMargin: 6
			anchors.rightMargin: 6
			anchors.verticalCenter: parent.verticalCenter
			height: 2
			color: Theme.rule

			Rectangle {
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				height: parent.height
				width: parent.width * Math.min(1, root.audio?.volume ?? 0)
				color: root.audio?.muted ? Theme.muted : Theme.accent
			}
		}

		MouseArea {
			anchors.fill: parent
			function set(x: real): void {
				if (root.audio)
					root.audio.volume = Math.max(0, Math.min(1, (x - track.x) / track.width))
			}
			onPressed: mouse => set(mouse.x)
			onPositionChanged: mouse => set(mouse.x)
		}
	}
}
