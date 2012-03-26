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
    property int imageSize: 50
    width: 50
    height: 50
    property alias source : image.source
    property alias mouseArea : mouseArea
    property alias image : image

    Rectangle {
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
        z: -1
        visible: mouseArea.pressed
    }

    Image {
        id: image
        anchors.centerIn: parent
        smooth: true
        height: imageSize
        width: imageSize
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

