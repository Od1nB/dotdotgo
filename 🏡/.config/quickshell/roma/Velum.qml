pragma Singleton

// VELUM -- the awning. Which drawer is down, and which module let it down.
import QtQuick
import Quickshell

Singleton {
	id: root

	property Item anchorItem: null
	property string which: "" // "" is closed; otherwise a key the Entablature knows how to fill
	property var subject: null // what the drawer is about, when the key alone isn't enough (a tray item)
	readonly property bool open: anchorItem !== null && which !== ""

	function toggle(item: Item, key: string): void {root.toggleAbout(item, key, null)}

	function toggleAbout(item: Item, key: string, subject: var): void {
		if (root.anchorItem === item && root.which === key) {
			root.close()
			return
		}
		Monitum.hide(item)
		root.subject = subject
		root.anchorItem = item
		root.which = key
	}

	function close(): void {
		root.anchorItem = null
		root.which = ""
		root.subject = null
	}

	function holds(item: Item, key: string): bool {return root.anchorItem === item && root.which === key}
}
