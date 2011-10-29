import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/reittiopas.js" as Reittiopas

Page {
    tools: routeTools
    property string fromLoc : ''
    property string toLoc : ''
    property alias model : routeModel
    property string header

    anchors.margins: UIConstants.DEFAULT_MARGIN

    ToolBarLayout {
        id: routeTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
        ToolButton {
            text: qsTr("Map")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { pageStack.push(Qt.resolvedUrl("RouteMapPage.qml")) }
        }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    ListModel {
        id: routeModel
        property bool updating : false
    }

    StopPage { id: stopPage }

    ListView {
        id: routeList
        anchors.fill: parent
        model: routeModel
        delegate: RouteDelegate {}
        header: Header {
            text: header
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    BusyIndicator {
        id: busyIndicator
        visible: (routeModel.updating)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
