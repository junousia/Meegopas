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

import QtQuick 1.0
import com.nokia.symbian 1.1
import "UIConstants.js" as UIConstants

Component {
    id: favoritesManageDelegate
    Item {
        width: parent.width
        height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor

        Text {
            text: modelData
            anchors.left: parent.left
            anchors.right: remove_button.left
            anchors.verticalCenter: parent.verticalCenter
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
            elide: Text.ElideRight
        }
        Button {
            id: remove_button
            text: qsTr("Remove")
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
            width: 150 * appWindow.scaling_factor
            height: 40
            onClicked: {
                list.currentIndex = index
                deleteQuery.message = modelData
                deleteQuery.open()
            }
        }
    }
}
