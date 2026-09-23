// SONUS -- sound. The default sink's volume.
import QtQuick
import Quickshell.Services.Pipewire

Modulus {
	id: root

	readonly property PwNode sink: Pipewire.defaultAudioSink
	readonly property var audio: sink?.audio ?? null

	PwObjectTracker {objects: [root.sink]}

	label: audio?.muted ? Lexicon.label("mutus") : Lexicon.label("sonus")
	icon: audio?.muted ? "volumeMute" : "volume"

	value: {
		if (!audio)
			return Lexicon.absent
		if (audio.muted)
			return Lexicon.absent
		return `${Math.round(audio.volume * 100)}%`
	}

	valueColor: !audio ? Theme.muted : audio.muted ? Theme.muted : audio.volume > 1.0 ? Theme.warn : Theme.text

	onActivated: button => {
		if (button === Qt.LeftButton && audio)
			audio.muted = !audio.muted
	}

	onScrolled: delta => {
		if (!audio)
			return
		const step = delta > 0 ? 0.02 : -0.02
		audio.volume = Math.max(0, Math.min(1.0, audio.volume + step))
	}
}
