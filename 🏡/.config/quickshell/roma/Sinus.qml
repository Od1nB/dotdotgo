// SINUS -- the fold. The drawer that hangs out of the bar under whichever module
// let it down (Velum), filleted into the cornice so it reads as part of the bar
// rather than a window floating beneath it.
import QtQuick
import QtQuick.Shapes

Item {
	id: root

	required property Item frieze
	readonly property bool mine: Velum.open
		&& Velum.anchorItem.Window.window === frieze.Window.window

	readonly property int r: Theme.drawerRadius
	readonly property int bodyW: Theme.drawerWidth
	readonly property real fullH: Math.min(Theme.drawerMax, content.implicitHeight + Theme.drawerPad * 2 + r)

	width: bodyW + r * 2
	height: mine ? fullH : 0
	visible: height > 0
	clip: true

	property real centre: 0
	function place(): void {
		if (mine && parent)
			centre = Velum.anchorItem.mapToItem(parent, Velum.anchorItem.width / 2, 0).x
	}
	onMineChanged: place()
	Connections {
		target: Velum
		function onAnchorItemChanged(): void {root.place()}
	}
	Timer {
		interval: 250
		repeat: true
		running: root.mine
		onTriggered: root.place()
	}

	x: parent ? Math.max(0, Math.min(parent.width - width, centre - width / 2)) : 0

	Behavior on height {
		NumberAnimation {
			duration: 160
			easing.type: Easing.OutCubic
		}
	}

	// Anchored to the bottom, so while the height grows the drawer slides out from
	// under the cornice instead of unrolling.
	Item {
		id: body
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		height: root.fullH

		Shape {
			anchors.fill: parent
			preferredRendererType: Shape.CurveRenderer

			// Fill: concave fillet, side, convex corner, bottom, and back up.
			ShapePath {
				fillColor: Theme.popupColor
				strokeColor: "transparent"
				startX: 0
				startY: 0

				PathArc {x: root.r; y: root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise}
				PathLine {x: root.r; y: body.height - root.r}
				PathArc {x: root.r * 2; y: body.height; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise}
				PathLine {x: body.width - root.r * 2; y: body.height}
				PathArc {x: body.width - root.r; y: body.height - root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise}
				PathLine {x: body.width - root.r; y: root.r}
				PathArc {x: body.width; y: 0; radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise}
				PathLine {x: 0; y: 0}
			}

			// Edge: the same outline without the top, so the cornice's gold runs on
			// down the sides and round the bottom.
			ShapePath {
				fillColor: "transparent"
				strokeColor: Theme.accent
				strokeWidth: Theme.corniceHeight
				startX: 0
				startY: 0

				PathArc {x: root.r; y: root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise}
				PathLine {x: root.r; y: body.height - root.r}
				PathArc {x: root.r * 2; y: body.height; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise}
				PathLine {x: body.width - root.r * 2; y: body.height}
				PathArc {x: body.width - root.r; y: body.height - root.r; radiusX: root.r; radiusY: root.r; direction: PathArc.Counterclockwise}
				PathLine {x: body.width - root.r; y: root.r}
				PathArc {x: body.width; y: 0; radiusX: root.r; radiusY: root.r; direction: PathArc.Clockwise}
			}
		}

		// Swallow clicks on the drawer's empty parts so they don't fall through.
		MouseArea {
			anchors.fill: parent
			anchors.leftMargin: root.r
			anchors.rightMargin: root.r
		}

		Loader {
			id: content
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.topMargin: root.r
			anchors.leftMargin: root.r + Theme.drawerPad
			anchors.rightMargin: root.r + Theme.drawerPad

			// Keep the last drawer's content while folding away.
			property string shown: ""
			property var subject: null
			Connections {
				target: Velum
				function onWhichChanged(): void {
					if (Velum.which !== "") {
						content.subject = Velum.subject
						content.shown = Velum.which
					}
				}
				function onSubjectChanged(): void {
					if (Velum.which !== "")
						content.subject = Velum.subject
				}
			}

			sourceComponent: shown === "exitus" ? exitus : shown === "aditus" ? aditus : shown === "lararium" ? lararium : null
		}
	}

	Component {
		id: exitus
		Electio {inputs: false}
	}

	Component {
		id: aditus
		Electio {inputs: true}
	}

	Component {
		id: lararium
		Sacellum {item: content.subject}
	}

	HoverHandler {id: hover}

	readonly property bool away: mine && !hover.hovered && !(Velum.anchorItem?.hovered ?? false)

	Timer {
		id: linger
		interval: 700
		onTriggered: if (root.away) Velum.close()
	}

	onAwayChanged: away ? linger.restart() : linger.stop()
}
