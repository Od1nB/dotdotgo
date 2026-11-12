pragma Singleton

// VELUM -- the awning. Which drawer is down, and which module let it down.
import QtQuick
import Quickshell

Singleton {
	id: root

	property Item anchorItem: null
	property string which: "" // "" is closed; otherwise a key the Entablature knows how to fill
	readonly property bool open: anchorItem !== null && which !== ""

	function toggle(item: Item, key: string): void {
		if (root.anchorItem === item && root.which === key) {
			root.close()
			return
		}
		Monitum.hide(item)
		root.anchorItem = item
		root.which = key
	}

	function close(): void {
		root.anchorItem = null
		root.which = ""
	}

	function holds(item: Item, key: string): bool {return root.anchorItem === item && root.which === key}
}
