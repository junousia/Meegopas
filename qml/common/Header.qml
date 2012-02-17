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
    property string text
    property string subtext
    property bool apptitle : false

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottomMargin: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
    height: headerText.height + headerDivider.height +
            (subheaderText.visible ? subheaderText.height : 0) +
            UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor

    Text {
        id: headerText
        width: parent.width
        font.pixelSize: apptitle?UIConstants.FONT_XLARGE * appWindow.scaling_factor : UIConstants.FONT_XLARGE * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
        wrapMode: Text.WordWrap
        text: parent.text
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }

    Text {
        id: subheaderText
        anchors.top: headerText.bottom
        width: parent.width
        font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        text: subtext
        wrapMode: Text.WordWrap
        visible: parent.subtext
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.1
    }

    Separator {
        id: headerDivider
        anchors.bottom: parent.bottom
    }
}
