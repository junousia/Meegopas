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
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "theme.js" as Theme

Item {
    property alias checked : timeType.checked
    width: 150
    height: timeType.height + timeTypeText.height
    Switch {
        id: timeType
        platformStyle: customSwitch
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
        id: timeTypeText
        anchors.top: timeType.bottom
        anchors.horizontalCenter: timeType.horizontalCenter
        font.pixelSize: UIConstants.FONT_LARGE
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        text: timeType.checked? qsTr("arrival") : qsTr("departure")
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2

        MouseArea {
            anchors.fill: parent
            onClicked: timeType.checked = timeType.checked? false : true
        }
    }

    SwitchStyle {
        id: customSwitch
        switchOn: customSwitch.switchOff
    }
}
