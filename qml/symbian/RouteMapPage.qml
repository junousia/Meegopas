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
import QtMobility.location 1.2

Page {
    id: stop_page
    tools: mapTools
    anchors.fill: parent

    onStatusChanged: {
        if(status == Component.Ready)
            timer.start()
    }

    Timer {
        id: timer
        interval: 500
        triggeredOnStart: false
        repeat: false
        onTriggered: map_loader.sourceComponent = map_component
    }

    ToolBarLayout {
        id: mapTools
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButton {
            text: qsTr("Follow")
            checkable: true
            enabled: stop_page.state == "map"
            checked: appWindow.followMode
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                appWindow.followMode = appWindow.followMode ? false : true
                appWindow.banner.success = true
                appWindow.banner.text = appWindow.followMode?
                            qsTr("Follow current location enabled") :
                            qsTr("Follow current location disabled")
                appWindow.banner.open()
            }
        }

        ToolButton { iconSource: "toolbar-previous"; enabled: !appWindow.followMode; onClicked: { map_loader.item.previous_station(); } }
        ToolButton { iconSource: "toolbar-next"; enabled: !appWindow.followMode; onClicked: { map_loader.item.next_station(); } }
//        ToolIcon { platformIconId: "toolbar-view-menu";
//             anchors.right: parent===undefined ? undefined : parent.right
//             onClicked: (menu.status == DialogStatus.Closed) ? menu.open() : menu.close()
//        }
    }
    Loader {
        id: map_loader
        anchors.fill: parent
        onLoaded: {
            map_loader.item.initialize()
            map_loader.item.first_station()
        }
    }

    Component {
        id: map_component
        MapElement {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
        }
    }

    BusyIndicator {
        id: busyIndicator
        visible: !map_loader.sourceComponent || map_loader.status == Loader.Loading
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
