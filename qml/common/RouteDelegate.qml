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
    id: routeDelegate
    height: type != "walk"? UIConstants.LIST_ITEM_HEIGHT_LARGE * appWindow.scalingFactor :
                            UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scalingFactor
    width: parent.width
    opacity: 0.0

    Component.onCompleted: ListItemAnimation { target: routeDelegate }

    Rectangle {
        height: parent.height
        width: appWindow.width
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
        z: -1
        visible: mouseArea.pressed
    }

    Text {
        id: length_text
        width: 80 * appWindow.scalingFactor
        text: type == "walk"? Math.floor(length/100)/10 + " km": duration + " min"
        font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scalingFactor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        anchors.verticalCenter: parent.verticalCenter
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }
    Column {
        id: rect
        anchors.left: length_text.right
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        Rectangle {
            anchors.right: parent.right
            width: 15
            height: 5
            color: Theme.theme['general'].TRANSPORT_COLORS[type]
        }
        Rectangle {
            anchors.right: parent.right
            width: 5
            height: (routeDelegate.height +
                     UIConstants.DEFAULT_MARGIN) * appWindow.scalingFactor
            color: Theme.theme['general'].TRANSPORT_COLORS[type]
        }
        Rectangle {
            anchors.right: parent.right
            width: 15
            height: 5
            color: Theme.theme['general'].TRANSPORT_COLORS[type]
        }
    }

    Column {
        id: transportColumn
        anchors.left: rect.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        width: 100
        Image {
            visible: type != "walk"
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/" + type + ".png"
            smooth: true
            height: 50 * appWindow.scalingFactor
            width: height
        }
        Text {
            visible: type != "walk"
            text: code
            font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scalingFactor
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
            anchors.horizontalCenter: parent.horizontalCenter
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: routeDelegate
        onClicked: {
            pageStack.push(Qt.resolvedUrl("StopPage.qml"),{ leg_index: leg_number, leg_code: code })
        }
    }
}
