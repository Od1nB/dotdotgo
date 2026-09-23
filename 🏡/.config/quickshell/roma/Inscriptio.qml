// A Text with the bar's inscriptional defaults already applied.
import QtQuick

Text {
	id: root
	property bool inscriptional: true
	property bool capitalise: false

	color: Theme.muted

	font.family: inscriptional ? Theme.fontInscription : Theme.fontMono
	font.pixelSize: Theme.fontSize
	font.letterSpacing: inscriptional ? Theme.letterSpacing : 0
	font.capitalization: capitalise ? Font.AllUppercase : Font.MixedCase
	font.features: ({
			"liga": 0,
			"calt": 0,
			"dlig": 0,
			"tnum": 1
		})

	verticalAlignment: Text.AlignVCenter
	elide: Text.ElideRight
}
