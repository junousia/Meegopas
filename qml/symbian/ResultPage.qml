import QtQuick 1.1
import com.nokia.symbian 1.1
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

    RoutePage { id: routePage }

    ListModel {
        id: routeModel
        property bool updating : false
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: routeModel
        delegate: ResultDelegate {}

        header: Header {
            text: from + " - " + to
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: list
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
