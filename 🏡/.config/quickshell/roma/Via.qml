// VIA -- the road. Whether there is a route out, and over which interface.
import QtQuick
import Quickshell.Io

Modulus {
	id: root

	label: Lexicon.label("via")
	icon: iface === "" ? "networkOff" : "network"

	value: iface === "" ? Lexicon.absent : iface.toUpperCase()
	valueColor: iface === "" ? Theme.crit : Theme.text
	motto: iface === "" ? Lexicon.motto("viaDown") : ""

	property string iface: ""

	Process {
		id: probe
		command: ["sh", "-c", "ip route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i <= NF; i++) if ($i == \"dev\") { print $(i + 1); exit } }'"]
		stdout: StdioCollector {
			onStreamFinished: root.iface = text.trim()
		}
	}

	Timer {
		interval: 5000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: probe.running = true
	}
}
