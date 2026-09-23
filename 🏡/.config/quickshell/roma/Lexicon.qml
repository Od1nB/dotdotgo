pragma Singleton
// Every word the bar puts on screen, in one file.
import Quickshell

Singleton {
	id: root

	// Roman inscriptions separate words with a raised point, not a space.
	readonly property string interpunct: "·"
	readonly property string absent: "—"

	function inscribe(phrase: string): string {
		const s = phrase.toUpperCase()
		if (!Theme.orthographia)
			return s
		return s.replace(/U/g, "V").replace(/J/g, "I").replace(/ /g, root.interpunct)
	}

	function numeral(n: int): string {
		if (n < 1 || n > 3999)
			return String(n)

		const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
		const glyphs = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]

		let out = ""
		let left = n
		for (let i = 0; i < values.length; i++) {
			while (left >= values[i]) {
				out += glyphs[i]
				left -= values[i]
			}
		}
		return out
	}

	function romanDate(when: date): string {
		const d = root.numeral(when.getDate())
		const m = root.numeral(when.getMonth() + 1)
		const y = root.numeral(when.getFullYear())
		return [d, m, y].join(Theme.orthographia ? root.interpunct : " ")
	}

	readonly property var months: ["Ianuarius", "Februarius", "Martius", "Aprilis", "Maius", "Iunius", "Iulius", "Augustus", "September", "October", "November", "December"]
	function month(n: int): string {return root.inscribe(root.months[n - 1] || "")}
	readonly property var weekdays: ["Solis", "Lunae", "Martis", "Mercurii", "Iovis", "Veneris", "Saturni"]
	function weekday(i: int, short: bool): string {
		const name = root.weekdays[i] || ""
		return root.inscribe(short ? name.slice(0, 3) : name)
	}

	readonly property var labels: ({
			"regiones": "REGIONES", // workspaces
			"titulus": "TITULUS", // focused window
			"onus": "ONUS", // cpu load
			"calor": "CALOR", // temperature
			"memoria": "MEMORIA", // memory        (unused for now)
			"horreum": "HORREUM", // disk          (unused for now)
			"via": "VIA", // network (the roads)
			"sonus": "SONUS", // volume
			"mutus": "MUTUS", // silent, i.e. muted
			"carmen": "CARMEN", // media
			"nuntii": "NUNTII", // notifications
			"lararium": "LARARIUM", // tray
			"hora": "HORA", // clock
			"dies": "DIES", // date
			"fasti": "FASTI", // the calendar
			"hodie": "HODIE", // today; the link back from a month you navigated away from
			"vigilia": "VIGILIA", // uptime, a night-watch shift (unused for now)
			"ludi": "LUDI", // gamemode, the public games   (unused for now)
			"toga": "TOGA" // scheme switch
		})

	function label(key: string): string {return root.inscribe(root.labels[key] || key)}
	readonly property string sigil: Theme.orthographia ? "S·P·Q·R" : "SPQR"

	readonly property var mottos: ({
			"sigil": "SIC ITUR AD ASTRA", // thus one goes to the stars   -- Virgil
			"onus": "LABOR OMNIA VINCIT", // work conquers all           -- Virgil
			"calor": "FESTINA LENTE", // make haste slowly           -- Augustus
			"calorCrit": "CAVE", // beware
			"hora": "TEMPUS FUGIT", // time flees
			"carmen": "NUNC EST BIBENDUM", // now is the time to drink    -- Horace
			"viaDown": "VIA INTERRUPTA", // the road is cut
			"nuntiiCrit": "ERRARE HUMANUM EST", // to err is human
			"ludi": "PANEM ET CIRCENSES", // bread and circuses          -- Juvenal
			"vigilia": "DUM SPIRO SPERO" // while I breathe, I hope
		})
	function motto(key: string): string {return root.inscribe(root.mottos[key] || "")}
}
