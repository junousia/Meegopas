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
    id: timeContainer
    height: timeButton.height
    width: timeButton.width

    signal timeChanged(variant newTime)

    function updateTime() {
        var tempTime = new Date()

        /* Set date for date picker */
        timePicker.hour = Qt.formatTime(tempTime, "hh")
        timePicker.minute = Qt.formatTime(tempTime, "mm")
        timeButton.text = Qt.formatTime(tempTime, "hh:mm")

        timeChanged(tempTime)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
        z: -1
        visible: timeMouseArea.pressed
    }

    Text {
        id: timeButton
        font.pixelSize: UIConstants.FONT_XXXXLARGE
        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }

    MouseArea {
        id: timeMouseArea
        anchors.fill: parent
        onClicked: {
            timePicker.open()
        }
    }

    TimePickerDialog {
        id: timePicker
        titleText: qsTr("Choose time")
        onAccepted: {
            var tempTime = new Date(2012, 12-1, 24, timePicker.hour, timePicker.minute)
            timeContainer.timeChanged(tempTime)
            timeButton.text = Qt.formatTime(tempTime, "hh:mm")
        }

        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }
}
