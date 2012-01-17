import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "storage.js" as Storage
import "helper.js" as Helper

Page {
    id: root
    tools: mainTools

    property date myTime

    Component.onCompleted: {
        theme.inverted = true
        Storage.initialize()

        myTime = new Date()

        /* Set date for date picker */
        timePicker.hour = Qt.formatTime(root.myTime, "hh")
        timePicker.minute = Qt.formatTime(root.myTime, "mm")

        /* Set date for date picker */
        datePicker.day = Qt.formatDate(root.myTime, "dd")
        datePicker.month = Qt.formatDate(root.myTime, "MM")
        datePicker.year = Qt.formatDate(root.myTime, "yyyy")
    }

    ToolBarLayout {
        id: mainTools
        x: 0
        y: 0
        ToolButtonRow {
            ToolButton {
                text: qsTr("Search")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: ((from.destination_coords != '' || from.destination_valid) && (to.destination_coords != '' || to.destination_valid))
                onClicked: {
                    var walking_speed = Storage.getSetting("walking_speed")
                    var optimize = Storage.getSetting("optimize")
                    var change_margin = Storage.getSetting("change_margin")
                    var parameters = {}
                    parameters.from = from.getCoords().coords
                    parameters.to = to.getCoords().coords
                    parameters.from_name = from.text
                    parameters.to_name = to.text
                    parameters.time = root.myTime
                    parameters.timetype = timeType.checked? "arrival" : "departure"
                    parameters.walk_speed = walking_speed == "Unknown"?"70":walking_speed
                    parameters.optimize = optimize == "Unknown"?"default":optimize
                    parameters.change_margin = change_margin == "Unknown"?"3":Math.floor(change_margin)

                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }
            }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: myMenu.open(); }
    }

    DatePickerDialog {
        id: datePicker
        onAccepted: {
            var tempTime = new Date(datePicker.year, datePicker.month-1, datePicker.day,
                                    root.myTime.getHours(), root.myTime.getMinutes())
            root.myTime = tempTime
            dateButton.text = Qt.formatDate(root.myTime, "dd. MMMM yyyy")
        }
        minimumYear: 2012

        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    TimePickerDialog {
        id: timePicker
        onAccepted: {
            var tempTime = new Date(root.myTime.getFullYear(), root.myTime.getMonth(),
                                    root.myTime.getDate(), timePicker.hour, timePicker.minute)
            root.myTime = tempTime
            timeButton.text = Qt.formatTime(root.myTime, "hh:mm")
        }

        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    Flickable {
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: content_column.height

        Column {
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width

            Header { text: qsTr("Meegopas"); apptitle: true }

            Item {
                width: parent.width
                height: from.height + to.height + UIConstants.DEFAULT_MARGIN

                LocationEntry { id: from; type: qsTr("From") }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 30 }

                SwitchLocation {
                    anchors.topMargin: UIConstants.DEFAULT_MARGIN/2 + 3
                    from: from
                    to: to
                }

                LocationEntry { id: to; type: qsTr("To"); anchors.top: location_spacing.bottom }
            }

            Spacing {}

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Item {
                    id: timeContainer
                    height: timeButton.height
                    width: timeButton.width

                    BorderImage {
                        anchors.fill: parent
                        visible: timeMouseArea.pressed
                        source: 'qrc:/images/background.png'
                    }

                    Text {
                        id: timeButton
                        font.pixelSize: UIConstants.FONT_XXXXLARGE * appWindow.scaling_factor
                        color: UIConstants.COLOR_INVERTED_FOREGROUND
                        text: Qt.formatTime(root.myTime, "hh:mm")
                    }

                    MouseArea {
                        id: timeMouseArea
                        anchors.fill: parent
                        onClicked: {
                            timePicker.open()
                        }
                    }
                }
                SwitchStyle {
                    id: customswitch
                    switchOn: customswitch.switchOff
                }
                Item {
                    width: 150
                    height: timeType.height + timeTypeText.height
                    Switch {
                        id: timeType
                        platformStyle: customswitch
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: timeTypeText
                        anchors.top: timeType.bottom
                        anchors.horizontalCenter: timeType.horizontalCenter
                        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                        color: UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                        text: timeType.checked? qsTr("arrival") : qsTr("departure")

                        MouseArea {
                            anchors.fill: parent
                            onClicked: timeType.checked = timeType.checked? false : true
                        }
                    }
                }
            }
            Item {
                id: dateContainer
                width: dateButton.width
                height: dateButton.height
                anchors.horizontalCenter: parent.horizontalCenter

                BorderImage {
                    anchors.fill: parent
                    visible: dateMouseArea.pressed
                    source: 'qrc:/images/background.png'
                }
                Text {
                    id: dateButton
                    height: UIConstants.SIZE_BUTTON
                    font.pixelSize: UIConstants.FONT_XXLARGE * appWindow.scaling_factor
                    color: UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                    text: Qt.formatDate(root.myTime, "dd. MMMM yyyy")
                }

                MouseArea {
                    id: dateMouseArea
                    anchors.fill: parent
                    onClicked: {
                        datePicker.open()
                    }
                }
            }

            Button {
                id: timedate_now
                text: qsTr("Now")
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                anchors.horizontalCenter: parent.horizontalCenter
                width: 150
                height: 40
                onClicked: {
                    root.myTime = root.myTime = new Date()
                    timeButton.text = Qt.formatTime(root.myTime, "hh:mm")
                    dateButton.text = Qt.formatDate(root.myTime, "dd. MMMM yyyy")
                }
            }
        }
    }
}
