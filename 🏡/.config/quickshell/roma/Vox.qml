// VOX -- the voice. The default source's gain; right-click lets down the inputs.
import QtQuick
import Quickshell.Services.Pipewire

Modulus {
	id: root

	readonly property PwNode source: Pipewire.defaultAudioSource
	readonly property var audio: source?.audio ?? null

	PwObjectTracker {objects: [root.source]}

	label: audio?.muted ? Lexicon.label("mutus") : Lexicon.label("vox")
	icon: !audio || audio.muted ? "microphoneMute" : "microphone"

	value: !audio || audio.muted ? Lexicon.absent : `${Math.round(audio.volume * 100)}%`
	valueColor: !audio || audio.muted ? Theme.muted : Theme.text

	onActivated: button => {
		if (button === Qt.RightButton)
			Velum.toggle(root, "aditus")
		else if (button === Qt.LeftButton && audio)
			audio.muted = !audio.muted
	}

	onScrolled: delta => {
		if (!audio)
			return
		const step = delta > 0 ? 0.02 : -0.02
		audio.volume = Math.max(0, Math.min(1.0, audio.volume + step))
	}
}
