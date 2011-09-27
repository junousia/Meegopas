import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Page {
    id: mainPage
    tools: commonTools
    property date myDate
    property date myTime

    Component.onCompleted: {
        theme.inverted = true
        myDate = new Date()
        myTime = new Date()
    }
    ResultPage { id: resu }

    LocationEntry { id: from; type: "From"; anchors.top: parent.top }
    LocationEntry { id: to; type: "To"; anchors.top: from.bottom }

    DatePickerDialog {
        id: datePicker
        onAccepted: {
            myDate = new Date(datePicker.year, datePicker.month, datePicker.day, 0)
            dateButton.text = Qt.formatDate(myDate, "dd.MMMM yyyy")
        }
        day: Qt.formatDate(myDate, "d")
        month: Qt.formatDate(myDate, "M")
        year: Qt.formatDate(myDate, "yyyy")

        acceptButtonText: "Accept"
        rejectButtonText: "Reject"
    }

    TimePickerDialog {
        id: timePicker
        onAccepted: {
            myTime = new Date(0, 0, 0, timePicker.hour, timePicker.minute, 0, 0)
            timeButton.text = Qt.formatTime(myTime, "hh:mm")
        }
        hour: Qt.formatTime(myDate, "hh")
        minute: Qt.formatTime(myDate, "m")
        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: "Accept"
        rejectButtonText: "Reject"
    }

    Row {
        id: searchButtonRow
        anchors.top: to.bottom
        spacing: UIConstants.MARGIN_XLARGE
        anchors.topMargin: UIConstants.DEFAULT_MARGIN
        anchors.bottomMargin: UIConstants.DEFAULT_MARGIN
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.rightMargin: UIConstants.DEFAULT_MARGIN

        ListButton {
            id: searchButton
            text: "Search"
            width: ExtrasConstants.WIDTH_TUMBLER_BUTTON
            height: ExtrasConstants.SIZE_BUTTON
            enabled: ((from.destCoords != '' || from.destValid) && (to.destCoords != '' || to.destValid))
            onClicked: {
                resu.routeModel.clear()
                Reittiopas.route(from.getCoords().coords,to.getCoords().coords, Qt.formatDate(myDate, "yyyyMMdd"),Qt.formatTime(myTime, "hhmm"),"departure",70,resu.routeModel)
                resu.from = from.getCoords().name
                resu.to = to.getCoords().name
                pageStack.push(resu)
            }
        }
    }
    Row {
        anchors.top: searchButtonRow.bottom
        spacing: UIConstants.MARGIN_XLARGE
        anchors.topMargin: UIConstants.DEFAULT_MARGIN
        anchors.bottomMargin: UIConstants.DEFAULT_MARGIN
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.rightMargin: UIConstants.DEFAULT_MARGIN

        Text {
            id: timeButton
            width: 150
            height: ExtrasConstants.SIZE_BUTTON
            font.pixelSize: UIConstants.FONT_XLARGE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

            text: Qt.formatTime(myTime, "hh:mm")
            MouseArea {
                anchors.fill: parent
                onClicked: timePicker.open()
            }
        }
        Text {
            id: dateButton
            width: 300
            height: ExtrasConstants.SIZE_BUTTON
            font.pixelSize: UIConstants.FONT_XLARGE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            text: Qt.formatDate(myDate, "dd. MMMM yyyy")
            MouseArea {
                anchors.fill: parent
                onClicked: datePicker.open()
            }
        }
    }
}
