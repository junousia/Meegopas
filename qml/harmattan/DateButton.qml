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
    id: dateContainer
    width: dateButton.width
    height: dateButton.height
    anchors.horizontalCenter: parent.horizontalCenter

    signal dateChanged(variant newDate)

    function updateDate() {
        var tempDate = new Date()

        /* Set date for date picker */
        datePicker.day = Qt.formatDate(tempDate, "dd")
        datePicker.month = Qt.formatDate(tempDate, "MM")
        datePicker.year = Qt.formatDate(tempDate, "yyyy")
        dateButton.text = Qt.formatDate(tempDate, "dd. MMMM yyyy")

        dateChanged(tempDate)
    }


    Rectangle {
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
        z: -1
        visible: dateMouseArea.pressed
    }
    Text {
        id: dateButton
        height: UIConstants.SIZE_BUTTON
        font.pixelSize: UIConstants.FONT_XXLARGE
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }

    MouseArea {
        id: dateMouseArea
        anchors.fill: parent
        onClicked: {
            datePicker.open()
        }
    }

    DatePickerDialog {
        id: datePicker
        titleText: qsTr("Choose date")

        onAccepted: {
            var tempDate = new Date(datePicker.year, datePicker.month-1, datePicker.day, 0, 0)
            dateContainer.dateChanged(tempDate)
            dateButton.text = Qt.formatDate(tempDate, "dd. MMMM yyyy")
        }
        minimumYear: 2012

        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }
}


