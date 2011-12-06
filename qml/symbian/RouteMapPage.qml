// adapted from example: http://developer.qt.nokia.com/wiki/QML_Maps_with_Pinch_Zoom

import QtQuick 1.1
import com.nokia.symbian 1.1
import QtMobility.location 1.2
import "../common"

Page {
    id: page
    tools: mapTools
    anchors.fill: parent

    ToolBarLayout {
        id: mapTools
        x: 0
        y: 0
        ToolButton { iconSource: "toolbar-back"; onClicked: { pageStack.pop(); } }
    }

    Loader {
        id: map_loader
        source: "../common/MapElement.qml"
        anchors.fill: parent
        visible: !(map_loader.progress < 1.0)
    }

    BusyIndicator {
        id: busyIndicator
        visible: (map_loader.progress < 1.0)
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
