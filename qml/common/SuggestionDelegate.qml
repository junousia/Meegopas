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

Component {
    id: suggestionDelegate

    Item {
        id: delegateItem
        property bool selected: index == selectedIndex;

        height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor
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

        Text {
            id: locName
            elide: Text.ElideRight
            color: UIConstants.COLOR_INVERTED_FOREGROUND
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.left: parent.left
            anchors.right: locType.left
            text: name + " " + housenumber
            font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
        }
        Text {
            id: locType
            width: 75
            elide: Text.ElideRight
            color: UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.right: parent.right
            text: city
            font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
        }
    }
}
