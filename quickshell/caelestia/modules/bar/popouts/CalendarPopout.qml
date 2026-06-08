import "../../dashboard/dash"
import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components

Item {
    id: root

    width: Tokens.sizes.bar.networkWidth
    height: calendar.implicitHeight

    DashboardState {
        id: localState
    }

    Calendar {
        id: calendar
        dashState: localState
    }
}
