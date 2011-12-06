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

    MapElement { anchors.fill: parent }
}
