import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.misc
import qs.services

ColumnLayout {
    spacing: Tokens.spacing.small

    Ref {
        service: SystemUsage
    }

    StyledText {
        text: qsTr("Memory Information")
        font.weight: 600
        font.pointSize: Tokens.font.size.normal
    }

    StyledText {
        readonly property var usedFmt: SystemUsage.formatKib(SystemUsage.memUsed)
        readonly property var totalFmt: SystemUsage.formatKib(SystemUsage.memTotal)
        text: qsTr("Usage: %1% (%2 / %3)").arg(Math.round(SystemUsage.memPerc * 100)).arg(`${usedFmt.value.toFixed(1)} ${usedFmt.unit}`).arg(`${totalFmt.value.toFixed(1)} ${totalFmt.unit}`)
    }
}
