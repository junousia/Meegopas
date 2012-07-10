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

Item {
    property alias text : header.text
    height: header.height
    anchors.margins: UIConstants.DEFAULT_MARGIN/2
    width: parent.width

    Rectangle {
        height: 1
        anchors.left: parent.left
        anchors.right: header.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: UIConstants.DEFAULT_MARGIN / 2
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
    }

    Text {
        id: header
        font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scalingFactor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }
}
