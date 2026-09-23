// CALOR -- heat. The hottest of the CPU and GPU package sensors.
import QtQuick
import Quickshell.Io

Modulus {
	id: root

	label: Lexicon.label("calor")
	icon: "thermostat"

	value: celsius < 0 ? Lexicon.absent : `${celsius}°`
	valueColor: celsius >= 90 ? Theme.crit : celsius >= 75 ? Theme.warn : Theme.text
	motto: celsius >= 90 ? Lexicon.motto("calorCrit") : Lexicon.motto("calor")

	property int celsius: -1
	Process {
		id: probe
		command: ["sh", "-c", `for d in /sys/class/hwmon/hwmon*; do
			n=$(cat "$d/name" 2>/dev/null) || continue
			case "$n" in
				k10temp|zenpower|coretemp|amdgpu) cat "$d/temp1_input" 2>/dev/null ;;
			esac
		done`]
		stdout: StdioCollector {onStreamFinished: root.absorb(text)}
	}
	Timer {
		interval: 5000 // 5s
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: probe.running = true
	}

	function absorb(raw: string): void {
		const readings = raw.trim().split("\n").map(Number).filter(n => !isNaN(n) && n > 0)
		if (readings.length === 0) {
			root.celsius = -1
			return
		}
		// hwmon reports millidegrees.
		root.celsius = Math.round(Math.max(...readings) / 1000)
	}
}
