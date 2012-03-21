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
import com.nokia.symbian 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "theme.js" as Theme

Page {
    tools: routeTools
    property int route_index
    property string from_name
    property string to_name
    property string header
    property string subheader

    onStatusChanged: {
        if(status == Component.Ready && !routeModel.count) {
            var route = Reittiopas.get_route_instance()
            route.dump_legs(route_index, routeModel)
            from_name = route.from_name
            to_name = route.to_name
        }
    }

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
        property bool done : false
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    Component {
        id: delegate
        Loader {
            width: parent.width
            source: type == "station" ? "qrc:/qml/RouteStationDelegate.qml" : "qrc:/qml/RouteDelegate.qml"
        }

    }
    ListView {
        id: routeList
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: routeModel
        delegate: delegate
        interactive: !busyIndicator.visible
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
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.done)
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
