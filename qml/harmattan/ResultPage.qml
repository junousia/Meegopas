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
import "storage.js" as Storage
import "theme.js" as Theme

Page {
    tools: resultTools

    ToolBarLayout {
        id: resultTools
        ToolIcon { iconId: "toolbar-back"; onClicked: { menu.close(); pageStack.pop(); } }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (menu.status == DialogStatus.Closed) ? menu.open() : menu.close()
        }
    }

    property variant search_parameters : 0

    onStatusChanged: {
        if(status == Component.Ready && !routeModel.count)
            Reittiopas.new_route_instance(search_parameters, routeModel, Storage.getSetting('api'))
    }

    ListModel {
        id: routeModel
        property bool done : false
    }

    Timer {
        id: newSearchTimer
        triggeredOnStart: false
        interval: 500
        onTriggered: {
            routeModel.clear()
            Reittiopas.new_route_instance(search_parameters, routeModel, Storage.getSetting('api'))
        }
    }

    Component {
        id: footer
        Item {
            height: 35
            width: parent.width
            visible: !busyIndicator.visible
            Label {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("...")
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 0.8
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    /* workaround to modify qml array is to make a copy of it,
                       modify the copy and assign the copy back to the original */
                    var new_parameters = search_parameters
                    new_parameters.time.setMinutes(new_parameters.time.getMinutes() + 15)
                    search_parameters = new_parameters
                    newSearchTimer.restart()
                }
            }
            Rectangle {
                height: parent.height
                width: appWindow.width
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
                z: -1
                visible: mouseArea.pressed
            }
        }
    }


    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scalingFactor
        model: routeModel
        footer: footer
        delegate: ResultDelegate {}
        interactive: !busyIndicator.visible
        header: Column {
            width: parent.width
            Header {
                text: search_parameters.from_name + " - " + search_parameters.to_name
                subtext: search_parameters.timetype == "departure"?
                             qsTr("Departure time ") + Qt.formatDateTime(search_parameters.time,"dd.MM.yyyy hh:mm") :
                             qsTr("Arrival time ") + Qt.formatDateTime(search_parameters.time,"dd.MM.yyyy hh:mm")
            }
            Item {
                height: 35
                width: parent.width
                visible: !busyIndicator.visible
                Label {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("...")
                    lineHeightMode: Text.FixedHeight
                    lineHeight: font.pixelSize * 0.8
                    color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        /* workaround to modify qml array is to make a copy of it,
                           modify the copy and assign the copy back to the original */
                        var new_parameters = search_parameters
                        new_parameters.time.setMinutes(new_parameters.time.getMinutes() - 15)
                        search_parameters = new_parameters
                        newSearchTimer.restart()
                    }
                }
                Rectangle {
                    height: parent.height
                    width: appWindow.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
                    z: -1
                    visible: mouseArea.pressed
                }
            }
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
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.done)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
