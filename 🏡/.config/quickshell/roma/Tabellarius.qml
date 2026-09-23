pragma Singleton

// TABELLARIUS -- the letter-carrier. Owns the machine's notification daemon.
import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root

	readonly property var live: server.trackedNotifications.values
	readonly property int count: live.length
	readonly property bool critical: live.some(n => n.urgency === NotificationUrgency.Critical)

	NotificationServer {
		id: server

		actionsSupported: true
		actionIconsSupported: false
		bodySupported: true
		bodyMarkupSupported: false
		imageSupported: true
		onNotification: notification => {notification.tracked = true}
	}

	function dismissAll(): void {
		for (const n of root.live.slice())
			n.dismiss()
	}
}
