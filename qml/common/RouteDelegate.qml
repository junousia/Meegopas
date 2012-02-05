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

Component {
    id: routeDelegate
    Item {
        id: delegate_item
        height: visible ? 100 : 0
        width: parent.width
        // do not show if from and to times or names match
        visible: !(from.name == to.name || from.time == to.time)
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: delegate_item
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
            anchors.left: parent.left
            anchors.right: transportColumn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: UIConstants.DEFAULT_MARGIN

            Text {
                text: Qt.formatTime(from.time, "hh:mm")
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: (index === 0)? from_name : from.name
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
        Column {
            id: transportColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/images/" + type + ".png"
                smooth: true
                height: 50 * appWindow.scaling_factor
                width: height
            }
            Text {
                text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            anchors.right: parent.right
            anchors.left: transportColumn.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: UIConstants.DEFAULT_MARGIN
            Text {
                text: Qt.formatTime(to.time, "hh:mm")
                anchors.right: parent.right
                horizontalAlignment: Qt.AlignRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: index === routeModel.count - 1? to_name : to.name
                horizontalAlignment: Text.AlignRight
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("StopPage.qml"),{ leg_index: index, leg_code: code })
            }
        }
    }
}
