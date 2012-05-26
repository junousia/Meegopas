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
import "UIConstants.js" as UIConstants
import "theme.js" as Theme

Component {
    id: stopDelegate

    Item {
        id: stop_item
        height: UIConstants.LIST_ITEM_HEIGHT_DEFAULT * appWindow.scaling_factor
        width: parent.width
        opacity: 1.0

        Coordinate {
            id: coordinate
            latitude: stop_latitude
            longitude: stop_longitude
        }

        Component.onCompleted: ListItemAnimation { target: stop_item }

        onStateChanged: {
            if(state == "there")
                stop_page.list.selectedIndex = index
        }
        state: (coordinate.distanceTo(stop_page.position.position.coordinate) && coordinate.distanceTo(stop_page.position.position.coordinate) < 150)? "near": "far"

        states: [
            State {
                name: "far"
                PropertyChanges { target: routeList; currentIndex: routeList.currentIndex }
            },
            State {
                name: "near"
                PropertyChanges { target: routeList; currentIndex: index }
            }
        ]
        transitions: [
            Transition {
                ParallelAnimation {
                    ColorAnimation { duration: 300 }
                    NumberAnimation { properties: "opacity"; duration: 500 }
                }
            }
        ]

        Rectangle {
            height: parent.height
            width: appWindow.width
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
            z: -1
            visible: mouseArea.pressed
        }
        Column {
            id: time_column
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 100 * appWindow.scaling_factor
            Text {
                id: diff
                anchors.right: time.right
                horizontalAlignment: Qt.AlignRight
                text: "+" + time_diff + " min"
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
            Text {
                id: time
                text: (index === 0)? Qt.formatTime(depTime, "hh:mm") : Qt.formatTime(arrTime, "hh:mm")
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
        Row {
            anchors.left: time_column.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            layoutDirection: Qt.RightToLeft
            spacing: UIConstants.DEFAULT_MARGIN / 2 * appWindow.scaling_factor
            clip: true

            Text {
                text: name
                horizontalAlignment: Qt.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
            Text {
                id: station_code
                visible: appWindow.show_station_code
                horizontalAlignment: Qt.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                text: shortCode? "(" + shortCode + ")" : ""
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                // show map if currently hidden
                if(appWindow.map_visible == false)
                    appWindow.map_visible = true

                // follow mode disables panning to location
                if(!appWindow.follow_mode)
                    map.map_loader.item.flickable_map.panToLatLong(stop_latitude,stop_longitude)
            }
        }
    }
}
