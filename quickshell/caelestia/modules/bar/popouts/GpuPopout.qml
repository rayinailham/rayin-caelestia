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
        text: SystemUsage.gpuName ? SystemUsage.gpuName : qsTr("GPU Information")
        font.weight: 600
        font.pointSize: Tokens.font.size.normal
    }

    StyledText {
        text: qsTr("Usage: %1%").arg(Math.round(SystemUsage.gpuPerc * 100))
    }

    StyledText {
        text: qsTr("Temperature: %1°C").arg(Math.round(SystemUsage.gpuTemp))
        visible: SystemUsage.gpuTemp > 0
    }
}
