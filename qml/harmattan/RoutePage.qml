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
import com.nokia.meego 1.0
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
        ToolIcon { iconId: "toolbar-back"; onClicked: { menu.close(); pageStack.pop(); } }
        ToolButton {
            text: qsTr("Map")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { pageStack.push(Qt.resolvedUrl("RouteMapPage.qml")) }
        }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (menu.status == DialogStatus.Closed) ? menu.open() : menu.close()
        }
    }

    ListModel {
        id: routeModel
        property bool done : false
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
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scalingFactor
        model: routeModel
        delegate: delegate
        interactive: !busyIndicator.visible
        header: Header {
            text: header
            subtext: subheader
        }
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && routeModel.count == 0)
        width: parent.width
        text: qsTr("No results")
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scalingFactor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.done)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
