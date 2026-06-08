import QtQuick
import Quickshell
import Caelestia.Images

Item {
    id: root

    property string path
    property int fillMode: Image.PreserveAspectFit
    property bool smooth: true
    property size sourceSize: {
        const dpr = (QsWindow.window as QsWindow)?.devicePixelRatio ?? 1;
        return Qt.size(width * dpr, height * dpr);
    }
    readonly property int status: path.endsWith(".gif") ? gif.status : img.status

    Image {
        id: img

        anchors.fill: parent
        visible: !root.path.endsWith(".gif")
        asynchronous: true
        fillMode: root.fillMode
        smooth: root.smooth
        source: visible ? IUtils.urlForPath(root.path, fillMode) : ""
        sourceSize: root.sourceSize
    }

    AnimatedImage {
        id: gif

        anchors.fill: parent
        visible: root.path.endsWith(".gif")
        asynchronous: true
        fillMode: root.fillMode
        smooth: root.smooth
        source: visible ? `file://${root.path}` : ""
    }
}
