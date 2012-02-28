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
    id: settings_item
    property alias mouseArea : mouseArea
    property alias setting : setting
    property alias value : value

    property bool showDrillDown : false
    property bool showComboBox : false

    height: UIConstants.LIST_ITEM_HEIGHT_LARGE * appWindow.scaling_factor
    width: parent.width
    opacity: 0.0

    Component.onCompleted: ListItemAnimation { target: settings_item }

    function set_value(new_value) {
        value.text = new_value
    }

    function add_value(new_value) {
        value.text += value.text != ""? ", " : ""
        value.text += new_value
    }

    function clear_value() {
        value.text = ""
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
        width: parent.width - (parent.showDrillDown ? 64 : 0)
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: setting
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
            font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
        Text {
            id: value
            width: parent.width
            color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
            font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
    }

    Image {
        source: "image://theme/icon-m-common-drilldown-arrow" + (Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED? "-inverse" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: parent.showDrillDown
    }

    Image {
        source: "image://theme/meegotouch-combobox-indicator" + (Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED? "-inverted" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: parent.showComboBox
    }

    MouseArea {
        id: mouseArea
        anchors.fill: settings_item
    }
}

