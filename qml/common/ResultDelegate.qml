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

Component {
    id: routeDelegate
    Item {
        id: delegate_item
        width: parent.width
        height: 125 * appWindow.scaling_factor
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: delegate_item
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
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "(" + Qt.formatTime(start, "hh:mm") + ")"
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }

            Text {
                text: first_transport ? Qt.formatTime(first_transport, "hh:mm") : Qt.formatTime(start, "hh:mm")
                width: 75
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }

            Text {
                text: duration + " min"
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
        Flow {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                id: repeater
                model: legs
                Column {
                    visible: repeater.count == 1? true : (type == "walk")? false : true
                    Image {
                        id: transportIcon
                        source: "qrc:/images/" + type + ".png"
                        smooth: true
                        height: 50 * appWindow.scaling_factor
                        width: height
                    }
                    Text {
                        text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                        visible: true
                        font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                        anchors.horizontalCenter: transportIcon.horizontalCenter
                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize * 1.2
                    }
                }
            }
        }
        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "(" + Qt.formatTime(finish, "hh:mm") + ")"
                anchors.right: parent.right
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
            Text {
                text: last_transport ? Qt.formatTime(last_transport, "hh:mm") : Qt.formatTime(finish, "hh:mm")
                anchors.right: parent.right
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
            Text {
                text: qsTr("Walk ") + Math.floor(walk/100)/10 + ' km'
                horizontalAlignment: Qt.AlignRight
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                pageStack.push(Qt.resolvedUrl("RoutePage.qml"), { route_index: index,
                                   header: search_parameters.from_name + " - " + search_parameters.to_name,
                                   subheader: qsTr("total duration") + " " + duration + " min - " + qsTr("amount of walking") + " " + Math.floor(walk/100)/10 + ' km'
                               })
            }
        }
    }
}
