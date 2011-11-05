import QtQuick 1.1
import com.nokia.symbian 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas

Page {
    property alias model: stopModel
    property string code

    tools: commonTools

    anchors.margins: UIConstants.DEFAULT_MARGIN

    ListModel {
        id: stopModel
        property bool updating : false
    }

    ListView {
        id: routeList
        anchors.fill: parent
        model: stopModel
        delegate: StopDelegate {}
        header: Header {
            text: qsTr("Stops for line ") + code
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    BusyIndicator {
        id: busyIndicator
        visible: (stopModel.updating)
        running: true
        anchors.centerIn: parent
    }
}
