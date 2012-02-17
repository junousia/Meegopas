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
import "UIConstants.js" as UIConstants
import "theme.js" as Theme

Component {
    id: stopDelegate
    Item {
        id: stop_item
        height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor
        width: parent.width
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: stop_item
            property: "opacity"
            to: 1.0
            duration: 125
        }
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
            width: UIConstants.LIST_ITEM_HEIGHT_SMALL
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
                text: (index === 0)? Qt.formatTime(departure_time, "hh:mm") : Qt.formatTime(arrival_time, "hh:mm")
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
        Column {
            anchors.right: parent.right
            anchors.left: time_column.right
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: name
                width: parent.width
                horizontalAlignment: Qt.AlignRight
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                if(stop_page.state == "normal") {
                    if(!map.map_loader.item)
                        map_loader.sourceComponent = map_component
                    stop_page.state = "map"
                }
                map.map_loader.item.flickable_map.panToLatLong(latitude,longitude)
            }
        }
    }
}
