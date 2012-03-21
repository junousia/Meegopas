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

Component {
    id: suggestionDelegate

    Item {
        id: delegateItem
        property bool selected: index == selectedIndex;

        height: UIConstants.LIST_ITEM_HEIGHT_DEFAULT * appWindow.scaling_factor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.rightMargin: UIConstants.DEFAULT_MARGIN

        MouseArea {
            id: delegateMouseArea
            anchors.fill: parent;
            onPressed: selectedIndex = index;
            onClicked: accept();
        }
        Rectangle {
            id: backgroundRect
            width: parent.width + 2 * UIConstants.DEFAULT_MARGIN
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            color: delegateItem.selected ? "#333333" : "transparent"
        }
        Image {
            id: icon
            source: index == 0?'qrc:/images/gps-icon-inverted.png':'qrc:/images/favorite-mark-inverse.png'
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 30
            width: 30
            smooth: true
        }
        Text {
            id: locName
            elide: Text.ElideRight
            color: UIConstants.COLOR_INVERTED_FOREGROUND
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.left: icon.right
            anchors.right: parent.right
            anchors.leftMargin: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
            text: modelData
            font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
        }
    }
}
