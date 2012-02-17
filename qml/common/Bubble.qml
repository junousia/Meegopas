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

Rectangle {
    height: 35
    width: count_label.width + 15
    radius: 12
    smooth: true
    color: "#0d67b3"
    property int count
    Text {
        id: count_label
        text: count
        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
