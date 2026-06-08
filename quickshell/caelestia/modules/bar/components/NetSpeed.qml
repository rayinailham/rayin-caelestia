pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.components.misc
import qs.services

ColumnLayout {
    id: root

    readonly property color colour: Colours.palette.m3secondary
    readonly property real maxSpeed: 12.5 * 1024 * 1024

    spacing: Tokens.spacing.smaller / 2

    Ref {
        service: SystemUsage
    }

    Item {
        implicitWidth: Tokens.sizes.bar.innerWidth
        implicitHeight: Tokens.sizes.bar.innerWidth

        CircularProgress {
            anchors.fill: parent
            value: Math.min(1, SystemUsage.netDown / root.maxSpeed)
            fgColour: root.colour
            bgColour: Qt.alpha(root.colour, 0.15)
            strokeWidth: 2
            padding: Tokens.padding.smaller
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: "download"
            color: root.colour
            font.pointSize: Tokens.font.size.smaller
        }
    }

    Item {
        implicitWidth: Tokens.sizes.bar.innerWidth
        implicitHeight: Tokens.sizes.bar.innerWidth

        CircularProgress {
            anchors.fill: parent
            value: Math.min(1, SystemUsage.netUp / root.maxSpeed)
            fgColour: root.colour
            bgColour: Qt.alpha(root.colour, 0.15)
            strokeWidth: 2
            padding: Tokens.padding.smaller
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: "upload"
            color: root.colour
            font.pointSize: Tokens.font.size.smaller
        }
    }
}
