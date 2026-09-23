// NUNTII -- messages. The count of live notifications.
import QtQuick

Modulus {
	id: root

	label: Lexicon.label("nuntii")
	icon: "bell"

	value: Tabellarius.count === 0 ? Lexicon.absent : Lexicon.numeral(Tabellarius.count)
	valueColor: Tabellarius.count === 0 ? Theme.muted : Tabellarius.critical ? Theme.crit : Theme.text
	motto: Tabellarius.critical ? Lexicon.motto("nuntiiCrit") : ""
	onActivated: button => {
		if (button === Qt.LeftButton)
			Tabellarius.dismissAll()
	}
}
