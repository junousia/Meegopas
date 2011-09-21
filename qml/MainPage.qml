import QtQuick 1.1
import com.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UI
import "reittiopas.js" as Reittiopas

Page {
    id: mainPage
    tools: commonTools

    Component.onCompleted: {
        theme.inverted = true
    }

    ResultPage { id: resu }

    LocationEntry { id: from; type: "From"; anchors.top: parent.top }
    LocationEntry { id: to; type: "To"; anchors.top: from.bottom }

    DatePickerDialog {
        id: datePicker
        visible: false
        onAccepted: {
            date.text = "Date: " + datePicker.year + "-" + datePicker.month + "-" + datePicker.day
        }
    }
    TimePickerDialog {
        id: timePicker
        onAccepted: {
            time.text = "Time: " + timePicker.hour + ":" + timePicker.minute
        }
    }

    Row {
        anchors.top: to.bottom
        ToolButton {
            id: searchButton
            text: "Search"
            width: 100
            enabled: ((from.destCoords != '' || from.destValid) && (to.destCoords != '' || to.destValid))
            onClicked: {
                Reittiopas.route(from.getCoords().coords,to.getCoords().coords,Qt.formatDate(new Date, "yyyyMMdd"),Qt.formatTime(new Date, "hhmm"),"departure",70,resu.routeModel)
                resu.routeModel.clear()
                pageStack.push(resu)

                resu.from = from.text
                resu.to = to.text
            }
        }
        ToolButton {
            id: clearButton
            text: "Clear"
            width: 100
            onClicked: {
                to.clear()
                from.clear()
            }
        }
    }
}
