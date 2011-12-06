import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/reittiopas.js" as Reittiopas
import "../common/UIConstants.js" as UIConstants

Page {
    id: page
    tools: mapTools
    anchors.fill: parent

    ToolBarLayout {
        id: mapTools
        x: 0
        y: 0
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
    }

    MapElement { anchors.fill: parent }
}

