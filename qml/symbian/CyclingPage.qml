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
import "storage.js" as Storage
import "theme.js" as Theme

Page {
    id: cyclingPage
    tools: mapTools
    property variant search_parameters : 0
    property bool initDone : false
    property bool routeDone : (doneIndicator.done && map_loader.status == Loader.Ready)

    onRouteDoneChanged: {
        if(routeDone) {
            map_loader.item.initialize_cycling()
        }
    }

    onStatusChanged: {
        if(status == Component.Ready && !initDone) {
            initDone = true
            map_loader.sourceComponent = map_component
            Reittiopas.new_cycling_instance(search_parameters, doneIndicator)
        }
    }

    Connections {
        target: map_loader.item
        onNewCycling: length >= 1000?
                          title.title = qsTr("Route length: ") + Math.floor(length/100)/10 + " km" :
                          title.title = qsTr("Route length: ") + length + " m"
    }

    ToolBarLayout {
        id: mapTools
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: { menu.close(); pageStack.pop(); }
        }
        ToolButton {
            text: qsTr("Follow")
            checkable: true
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
    }

    Item {
        id: doneIndicator
        property bool done : false
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    ApplicationHeader {
        id: title
        title: qsTr("")
        color: Theme.theme[appWindow.colorscheme].COLOR_MAPHEADER_BACKGROUND
        title_color: Theme.theme[appWindow.colorscheme].COLOR_MAPHEADER_FOREGROUND
        anchors.top: parent.top
    }

    Loader {
        id: map_loader
        anchors.fill: cyclingPage
    }

    Component {
        id: map_component
        MapElement {}
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && false)
        width: parent.width
        text: qsTr("No results")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scalingFactor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(doneIndicator.done)
        running: true
        width: 75
        height: 75
        anchors.centerIn: parent
    }
}
