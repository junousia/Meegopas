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
        BorderImage {
            height: parent.height
            width: appWindow.width
            anchors.horizontalCenter: parent.horizontalCenter
            visible: mouseArea.pressed
            source: theme.inverted ? 'qrc:/images/background.png': 'qrc:/images/background.png'
        }
        Column {
            id: time_column
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 100
            Text {
                id: diff
                anchors.right: time.right
                horizontalAlignment: Qt.AlignRight
                text: "+" + time_diff + " min"
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
            Text {
                id: time
                text: (index === 0)? Qt.formatTime(departure_time, "hh:mm") : Qt.formatTime(arrival_time, "hh:mm")
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
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
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: {
                if(stop_page.state == "normal") {
                    stop_page.state = "map"
                }
                map.flickable_map.panToLatLong(latitude,longitude)
            }
        }
    }
}
