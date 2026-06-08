pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

// Standalone bottom-right corner gif.
//
// This lives in its own window (NOT inside Background.qml) so it keeps
// showing even when caelestia's background layer is disabled to let an
// external wallpaper daemon (awww/swww) own the Background Wayland layer.
//
// It sits on the Bottom layer: above the wallpaper, below normal windows.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win

        required property var modelData

        screen: modelData
        WlrLayershell.namespace: "caelestia-gifcorner"
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        // Anchor to the bottom-right corner only; size to the gif.
        anchors.bottom: true
        anchors.right: true
        // Keep this small: animated layer-surface damage was hurting 165Hz pacing.
        implicitWidth: 160
        implicitHeight: 160

        // Let all clicks pass through to whatever is behind the gif.
        mask: Region {}

        AnimatedImage {
            id: animeGif

            anchors.fill: parent
            source: "file:///home/rayin/Pictures/arknights-monstr.gif"
            sourceSize.width: win.implicitWidth
            sourceSize.height: win.implicitHeight
            speed: 0.35
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            cache: true
            playing: true
        }
    }
}
