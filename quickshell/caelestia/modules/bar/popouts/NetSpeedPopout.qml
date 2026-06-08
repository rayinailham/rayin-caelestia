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
        text: qsTr("Network Speed")
        font.weight: 600
        font.pointSize: Tokens.font.size.normal
    }

    StyledText {
        text: {
            const s = SystemUsage.formatSpeed(SystemUsage.netDown);
            return qsTr("Download: %1 %2").arg(s.value).arg(s.unit);
        }
    }

    StyledText {
        text: {
            const s = SystemUsage.formatSpeed(SystemUsage.netUp);
            return qsTr("Upload: %1 %2").arg(s.value).arg(s.unit);
        }
    }
}
