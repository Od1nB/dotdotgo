// ONUS -- the burden. CPU utilisation.
import QtQuick
import Quickshell.Io

Modulus {
	id: root

	label: Lexicon.label("onus")
	motto: Lexicon.motto("onus")
	icon: "chip"

	value: pct < 0 ? Lexicon.absent : `${pct}%`
	valueColor: pct >= 90 ? Theme.crit : pct >= 65 ? Theme.warn : Theme.text

	property int pct: -1
	property real prevBusy: -1
	property real prevTotal: -1

	FileView {
		id: stat
		path: "/proc/stat"
		blockLoading: true
		printErrors: false
	}

	Timer {
		interval: 2000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			stat.reload()
			root.absorb(stat.text())
		}
	}

	function absorb(raw: string): void {
		const line = raw.split("\n")[0]
		if (!line || !line.startsWith("cpu "))
			return

		const f = line.trim().split(/\s+/).slice(1).map(Number)
		if (f.length < 5)
			return

		const total = f.reduce((a, b) => a + b, 0)
		const busy = total - f[3] - f[4]

		if (root.prevTotal >= 0) {
			const dTotal = total - root.prevTotal
			const dBusy = busy - root.prevBusy
			// dTotal can be 0 if two samples land inside one jiffy; dividing then
			// yields NaN and the readout sticks on it forever.
			if (dTotal > 0)
				root.pct = Math.max(0, Math.min(100, Math.round(dBusy / dTotal * 100)))
		}

		root.prevTotal = total
		root.prevBusy = busy
	}
}
