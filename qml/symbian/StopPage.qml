import QtQuick 1.1
import com.nokia.symbian 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas

Page {
    property string leg_code
    property int leg_index

    onStatusChanged: {
        if(status == Component.Ready && !stopModel.count) {
            var route = Reittiopas.get_route_instance()
            route.dump_stops(leg_index, stopModel)
        }
    }

    tools: commonTools

    anchors.margins: UIConstants.DEFAULT_MARGIN

    ListModel {
        id: stopModel
        property bool done : false
    }

    ListView {
        id: routeList
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: stopModel
        delegate: StopDelegate {}
        header: Header {
            text: qsTr("Stops for line ") + leg_code
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(stopModel.done)
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
