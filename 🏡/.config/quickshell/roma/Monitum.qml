pragma Singleton

// Shared hover state for the motto tooltips.
import QtQuick
import Quickshell

Singleton {
	id: root

	property bool enabled: true
	property Item anchorItem: null
	property string text: ""
	readonly property bool active: enabled && anchorItem !== null && text !== ""

	Timer {
		id: dwell
		interval: 550
		onTriggered: {
			root.anchorItem = pending.item
			root.text = pending.text
		}
	}

	QtObject {
		id: pending
		property Item item: null
		property string text: ""
	}

	function show(item: Item, phrase: string): void {
		if (!root.enabled || phrase === "")
			return
		pending.item = item
		pending.text = phrase
		dwell.restart()
	}

	function hide(item: Item): void {
		if (pending.item === item) {
			dwell.stop()
			pending.item = null
			pending.text = ""
		}
		if (root.anchorItem === item) {
			root.anchorItem = null
			root.text = ""
		}
	}
}
