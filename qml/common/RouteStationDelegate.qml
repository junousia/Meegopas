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
import "reittiopas.js" as Reittiopas
import "theme.js" as Theme


Item {
    id: stationDelegate
    height: UIConstants.LIST_ITEM_HEIGHT_DEFAULT / 2 * appWindow.scaling_factor
    opacity: 0.0

    Component.onCompleted: ListItemAnimation { target: stationDelegate }

    Column {
        id: time_column
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 100

        Text {
            text: Qt.formatTime(time, "hh:mm")
            font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
    }
    Row {
        height: parent.height
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
}
