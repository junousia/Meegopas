import QtQuick 1.1
import com.nokia.symbian 1.1
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas

Page {
    tools: routeTools
    property string fromLoc : ''
    property string toLoc : ''
    property alias model : routeModel
    property string header
    property string subheader

    ToolBarLayout {
        id: routeTools
        visible: false
        ToolButton { iconSource: "toolbar-back"; onClicked: { pageStack.pop(); } }
        ToolButton {
            text: qsTr("Map")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { pageStack.push(Qt.resolvedUrl("RouteMapPage.qml")) }
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
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: routeModel
        delegate: RouteDelegate {}
        header: Header {
            text: header
            subtext: subheader
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && routeModel.count == 0)
        width: parent.width
        text: qsTr("No results")
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: MyConstants.FONT_XXXLARGE * appWindow.scaling_factor
        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
    }

    BusyIndicator {
        id: busyIndicator
        visible: (routeModel.updating)
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
