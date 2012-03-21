/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

import QtQuick 1.1
import QtMobility.location 1.2
import com.nokia.meego 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "theme.js" as Theme

Page {
    id: stop_page
    property string leg_code
    property int leg_index
    property alias position : position
    property alias list : routeList
    anchors.fill: parent

    state: appWindow.map_visible? "map" : "normal"

    onStateChanged: {
        if(state == "map") {
            map_loader.sourceComponent = map_component
        }
    }

    onStatusChanged: {
        if(status == Component.Ready && !stopModel.count) {
            var route = Reittiopas.get_route_instance()
            route.dump_stops(leg_index, stopModel)
            if(appWindow.map_visible)
                map_loader.sourceComponent = map_component
        }
    }

    anchors.margins: UIConstants.DEFAULT_MARGIN

    tools: stopTools

    ToolBarLayout {
        id: stopTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
        ToolButton {
            text: qsTr("Map")
            checkable: true
            checked: appWindow.map_visible
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                appWindow.map_visible = appWindow.map_visible? false : true
            }
        }
        ToolButton {
            text: qsTr("Follow")
            checkable: true
            enabled: stop_page.state == "map"
            checked: appWindow.follow_mode
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                appWindow.follow_mode = appWindow.follow_mode ? false : true
            }
        }
//        ToolIcon { platformIconId: "toolbar-view-menu";
//             anchors.right: parent===undefined ? undefined : parent.right
//             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
//        }
    }

    PositionSource {
        id: position
        updateInterval: 500
        active: appWindow.positioning_active
    }

    ListModel {
        id: stopModel
        property bool done : false
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    ListView {
        id: routeList
        clip: true
        anchors.top: parent.top
        height: parent.height/2
        width: parent.width
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        z: 200
        model: stopModel
        delegate: StopDelegate {}
        interactive: !busyIndicator.visible
        header: Header {
            text: leg_code ? qsTr("Stops for line ") + leg_code : qsTr("Walking route")
        }
    }

    Rectangle {
        id: map_clipper
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: 100
        width: parent.width + UIConstants.DEFAULT_MARGIN * 2
        anchors.top: parent.top
        anchors.bottom: map.top
        anchors.topMargin: -UIConstants.DEFAULT_MARGIN
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: map
        property alias map_loader : map_loader
        anchors.top: routeList.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height/2 + UIConstants.DEFAULT_MARGIN
        width: parent.width + UIConstants.DEFAULT_MARGIN * 2
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND

        Loader {
            id: map_loader
            anchors.fill: parent
            onLoaded: {
                map_loader.item.initialize()

                // go to first stop
                map.map_loader.item.flickable_map.panToLatLong(stopModel.get(0).stop_latitude,stopModel.get(0).stop_longitude)
            }
        }
    }

    Component {
        id: map_component
        MapElement {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
        }
    }

    states: [
        State {
            name: "map"
            PropertyChanges { target: map; opacity: 1.0 }
            PropertyChanges { target: routeList; height: parent.height/2 }
            PropertyChanges { target: map_clipper; height: parent.height/2 }
        },
        State {
            name: "normal"
            PropertyChanges { target: map; opacity: 0.0 }
            PropertyChanges { target: routeList; height: parent.height }
            PropertyChanges { target: map_clipper; height: parent.height }
        }
    ]
    transitions: Transition {
        NumberAnimation { properties: "height"; duration: 500; easing.type: Easing.OutCubic }
        NumberAnimation { properties: "opacity"; duration: 500; }
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(stopModel.done)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
