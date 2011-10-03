import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "MyConstants.js" as MyConstants
import "reittiopas.js" as Reittiopas

Page {
    id: mainPage
    tools: mainTools
    property date myDate
    property date myTime

    // lock to portrait
    orientationLock: PageOrientation.LockPortrait

    anchors.margins: UIConstants.DEFAULT_MARGIN

    Component.onCompleted: {
        theme.inverted = true
        myDate = new Date()
        myTime = new Date()
    }

    ToolBarLayout {
        id: mainTools
        x: 0
        y: 0
        ToolButtonRow {
            ToolButton {
                text: "Search"
                enabled: ((from.destCoords != '' || from.destValid) && (to.destCoords != '' || to.destValid))
                onClicked: {
                    resu.routeModel.clear()
                    Reittiopas.route(from.getCoords().coords,
                                     to.getCoords().coords,
                                     Qt.formatDate(myDate, "yyyyMMdd"),
                                     Qt.formatTime(myTime, "hhmm"),
                                     timeType.checked? "arrival" : "departure",
                                     70,resu.routeModel)

                    resu.from = from.getCoords().name
                    resu.to = to.getCoords().name
                    pageStack.push(resu)
                }
            }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: myMenu.open(); }
    }

    DatePickerDialog {
        id: datePicker
        onAccepted: {
            myDate = new Date(datePicker.year, datePicker.month-1, datePicker.day, 0)
            dateButton.text = Qt.formatDate(myDate, "dd. MMMM yyyy")
        }
        minimumYear: 2011

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
        minute: Qt.formatTime(myDate, "mm")
        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: "Accept"
        rejectButtonText: "Reject"
    }

    ResultPage { id: resu }

    LocationEntry { id: from; type: "From"; anchors.top: parent.top }
    LocationEntry { id: to; type: "To"; anchors.top: from.bottom; anchors.topMargin: UIConstants.DEFAULT_MARGIN }

    SwitchStyle {
        id: customswitch
        switchOn: customswitch.switchOff
    }
    Item {
        anchors.right: parent.right
        anchors.top: to.bottom
        anchors.margins: UIConstants.DEFAULT_MARGIN*3

        width: 150
        height: 100
        Switch {
            id: timeType
            platformStyle: customswitch
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            id: timeTypeText
            anchors.top: timeType.bottom
            anchors.horizontalCenter: timeType.horizontalCenter
            font.pixelSize: UIConstants.FONT_DEFAULT_SIZE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            text: timeType.checked? "arrival" : "departure"
        }
    }
    Item {
        id: timeContainer
        height: timeButton.height
        width: timeButton.width
        anchors.top: to.bottom
        anchors.left: parent.left
        anchors.margins: UIConstants.DEFAULT_MARGIN*3
        BorderImage {
            anchors.fill: parent
            visible: timeMouseArea.pressed
            source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
        }

        Text {
            id: timeButton
            font.pixelSize: MyConstants.FONT_XXXXLARGE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            text: Qt.formatTime(myTime, "hh:mm")
        }

        MouseArea {
            id: timeMouseArea
            anchors.fill: parent
            onClicked: {
                timePicker.hour = Qt.formatTime(myTime, "hh")
                timePicker.minute = Qt.formatTime(myTime, "mm")
                timePicker.open()
            }
        }
    }
    Item {
        id: dateContainer
        width: dateButton.width
        height: dateButton.height
        anchors.top: timeContainer.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        BorderImage {
            anchors.fill: parent
            visible: dateMouseArea.pressed
            source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
        }
        Text {
            id: dateButton
            height: ExtrasConstants.SIZE_BUTTON
            font.pixelSize: MyConstants.FONT_XXLARGE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            text: Qt.formatDate(myDate, "dd. MMMM yyyy")
        }


        MouseArea {
            id: dateMouseArea
            anchors.fill: parent
            onClicked: {
                datePicker.day = Qt.formatDate(myDate, "dd")
                datePicker.month = Qt.formatDate(myDate, "MM")
                datePicker.year = Qt.formatDate(myDate, "yyyy")
                datePicker.open()
            }
        }
    }
}
