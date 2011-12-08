import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/storage.js" as Storage

Page {
    tools: commonTools
    property alias routeModel : routeModel
    property string from : ""
    property string to : ""

    anchors.margins: UIConstants.DEFAULT_MARGIN

    RoutePage { id: routePage }

    ListModel {
        id: routeModel
        property bool updating : false
    }

    ListView {
        id: list
        anchors.fill: parent
        model: routeModel
        delegate: ResultDelegate {}

        header: Header {
            text: from + " - " + to
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: list
        platformStyle: ScrollDecoratorStyle {}
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
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
