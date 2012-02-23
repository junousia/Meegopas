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
import "helper.js" as Helper
import "theme.js" as Theme

Component {
    id: disruptionDelegate
    Item {
        id: delegate_item
        width: parent.width
        height: column.height + UIConstants.DEFAULT_MARGIN
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: delegate_item
            property: "opacity"
            to: 1.0
            duration: 125
        }
        Column {
            id: column
            anchors.right: parent.right
            anchors.left: parent.left

            Text {
                text: Qt.formatDateTime(Helper.parse_disruption_time(time), "dd.MM.yyyy - hh:mm")
                anchors.left: parent.left
                horizontalAlignment: Qt.AlignLeft
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
            Text {
                text: info_fi
                horizontalAlignment: Text.AlignLeft
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.2
            }
        }
    }
}
