import QtQuick 1.1
import com.nokia.meego 1.0
import "reittiopas.js" as Reittiopas
import "UIConstants.js" as UIConstants

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

    Loader {
        id: map_loader
        source: "MapElement.qml"
        anchors.fill: parent
        visible: !(map_loader.progress < 1.0)
    }

    BusyIndicator {
        id: busyIndicator
        visible: (map_loader.progress < 1.0)
        running: true
        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: 'large' }
    }
}

