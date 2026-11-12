// SACELLUM -- the little shrine. A tray item's own menu, read over DBus and laid
// out like the rest of the drawers. Submenus are walked into in place, with a way
// back, rather than opened as further popups.
import QtQuick
import Quickshell
import Quickshell.Widgets

Column {
	id: root

	property var item: null
	property var stack: [] // the submenus walked into, deepest last

	onItemChanged: {
		root.stack = []
		if (!root.item && Velum.which === "lararium")
			Velum.close()
	}

	QsMenuOpener {
		id: opener
		menu: root.stack.length > 0 ? root.stack[root.stack.length - 1] : (root.item?.menu ?? null)
	}

	spacing: 2

	Inscriptio {
		width: parent.width
		height: 22
		text: {
			const top = root.stack.length > 0 ? root.stack[root.stack.length - 1].text : ""
			const name = top || root.item?.tooltipTitle || root.item?.title || root.item?.id || Lexicon.label("lararium")
			return Lexicon.inscribe(name.replace(/&/g, ""))
		}
		color: Theme.accent
	}

	// The way back out of a submenu.
	Item {
		width: root.width
		height: 26
		visible: root.stack.length > 0

		Rectangle {
			anchors.fill: parent
			radius: Theme.radius
			color: Theme.accent
			opacity: Theme.stateLayers && back.containsMouse ? 0.10 : 0
			visible: opacity > 0
		}

		Inscriptio {
			anchors.fill: parent
			anchors.leftMargin: 6
			anchors.rightMargin: 6
			text: `‹ ${Lexicon.label("reditus")}`
			color: Theme.textAlt
		}

		MouseArea {
			id: back
			anchors.fill: parent
			hoverEnabled: true
			onClicked: root.stack = root.stack.slice(0, -1)
		}
	}

	Repeater {
		model: opener.children

		delegate: Item {
			id: entry

			required property var modelData
			readonly property bool checkable: modelData.buttonType !== QsMenuButtonType.None
			readonly property bool checked: modelData.checkState === Qt.Checked

			width: root.width
			height: modelData.isSeparator ? 9 : 26

			// Separator.
			Rectangle {
				visible: entry.modelData.isSeparator
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 6
				anchors.rightMargin: 6
				height: 1
				color: Theme.rule
			}

			Item {
				anchors.fill: parent
				visible: !entry.modelData.isSeparator
				opacity: entry.modelData.enabled ? 1.0 : 0.4

				Rectangle {
					anchors.fill: parent
					radius: Theme.radius
					color: Theme.accent
					opacity: Theme.stateLayers && hit.containsMouse && entry.modelData.enabled ? 0.10 : 0
					visible: opacity > 0
				}

				// Check / radio mark, as Electio marks the chosen device.
				Rectangle {
					id: mark
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: 6
					height: 6
					radius: entry.modelData.buttonType === QsMenuButtonType.RadioButton ? 3 : 1
					visible: entry.checkable
					color: entry.checked ? Theme.accentBright : "transparent"
					border.width: 1
					border.color: entry.checked ? Theme.accentBright : Theme.rule
				}

				IconImage {
					id: glyph
					anchors.left: entry.checkable ? mark.right : parent.left
					anchors.leftMargin: entry.checkable ? 8 : 6
					anchors.verticalCenter: parent.verticalCenter
					implicitSize: 14
					source: entry.modelData.icon
					visible: entry.modelData.icon !== ""
				}

				Inscriptio {
					anchors.left: glyph.visible ? glyph.right : entry.checkable ? mark.right : parent.left
					anchors.right: more.left
					anchors.leftMargin: glyph.visible || entry.checkable ? 8 : 6
					anchors.rightMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					inscriptional: false
					// DBus menus mark mnemonics with "_" or "&"; drop them.
					text: entry.modelData.text.replace(/_(?=\S)/g, "").replace(/&(?=\S)/g, "")
					color: entry.checked ? Theme.text : Theme.textAlt
				}

				Inscriptio {
					id: more
					anchors.right: parent.right
					anchors.rightMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					inscriptional: false
					text: entry.modelData.hasChildren ? "›" : ""
					color: Theme.textAlt
				}

				MouseArea {
					id: hit
					anchors.fill: parent
					hoverEnabled: true
					enabled: entry.modelData.enabled
					onClicked: {
						if (entry.modelData.hasChildren) {
							root.stack = root.stack.concat([entry.modelData])
							return
						}
						entry.modelData.triggered()
						Velum.close()
					}
				}
			}
		}
	}
}
