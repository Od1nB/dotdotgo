pragma Singleton

// The state behind the calendar dropdown. Fasti.qml draws it; this decides whether it
// is up and which month it is showing.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property bool open: false
	property int monthOffset: 0

	SystemClock {
		id: clock
		precision: SystemClock.Hours
	}

	readonly property date today: clock.date
	readonly property date shown: new Date(root.today.getFullYear(), root.today.getMonth() + root.monthOffset, 1)

	function toggle(): void {
		if (!root.open)
			root.monthOffset = 0
		root.open = !root.open
	}

	function close(): void {root.open = false}
	function prevMonth(): void {root.monthOffset -= 1}
	function nextMonth(): void {root.monthOffset += 1}
	function hodie(): void {root.monthOffset = 0}

	IpcHandler {
		target: "fasti"

		function aperi(): string {
			root.monthOffset = 0
			root.open = true
			return "apertum"
		}

		function claude(): string {
			root.open = false
			return "clausum"
		}
	}
}
