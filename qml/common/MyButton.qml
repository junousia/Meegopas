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

Item {
    width: 50
    height: 50
    property alias source : image.source
    property alias mouseArea : mouseArea

    BorderImage {
        anchors.fill: parent
        visible: mouseArea.pressed
        source: theme.inverted ? 'qrc:/images/background.png': 'qrc:/images/background.png'
    }

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: parent.enabled ? 0.8 : 0.3
        smooth: true
        height: 50
        width: height
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

