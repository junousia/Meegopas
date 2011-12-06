import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/storage.js" as Storage
import "../common/helper.js" as Helper

Page {
    id: root
    tools: mainTools

    property date myDate
    property date myTime

    Component.onCompleted: {
        theme.inverted = true
        myDate = new Date()
        myTime = new Date()
        Storage.initialize()
        Favorites.initialize()
    }

    ToolBarLayout {
        id: mainTools
        x: 0
        y: 0
        ToolButtonRow {
            ToolButton {
                text: qsTr("Search")
                enabled: ((from.destination_coords != '' || from.destination_valid) && (to.destination_coords != '' || to.destination_valid))
                onClicked: {
                    result_page.item.routeModel.clear()
                    var walking_speed = Storage.getSetting("walking_speed")
                    var optimize = Storage.getSetting("optimize")
                    var change_margin = Storage.getSetting("change_margin")
                    Reittiopas.route(from.getCoords().coords,
                                     to.getCoords().coords,
                                     from.text,
                                     to.text,
                                     Qt.formatDate(root.myDate, "yyyyMMdd"),
                                     Qt.formatTime(root.myTime, "hhmm"),
                                     timeType.checked? "arrival" : "departure",
                                     walking_speed == "Unknown"?"70":walking_speed,
                                     optimize == "Unknown"?"default":optimize,
                                     change_margin == "Unknown"?"3":Math.floor(change_margin),
                                     result_page.item.routeModel)
                    result_page.item.from = from.getCoords().name
                    result_page.item.to = to.getCoords().name
                    pageStack.push(result_page.item)
                }
            }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: myMenu.open(); }
    }

    Loader {
        id: result_page
        source: "ResultPage.qml"
    }

    DatePickerDialog {
        id: datePicker
        onAccepted: {
            root.myDate = new Date(datePicker.year, datePicker.month - 1, datePicker.day, 0)
            dateButton.text = Qt.formatDate(root.myDate, "dd. MMMM yyyy")
        }
        minimumYear: 2011

        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    TimePickerDialog {
        id: timePicker
        onAccepted: {
            root.myTime = new Date(0, 0, 0, timePicker.hour, timePicker.minute, 0, 0)
            timeButton.text = Qt.formatTime(root.myTime, "hh:mm")
        }
        hour: Qt.formatTime(root.myDate, "hh")
        minute: Qt.formatTime(root.myDate, "mm")

        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    Flickable {
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN
        }
        width: parent.width
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: content_column.height

        Column {
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width

            Spacing {}

            Item {
                width: parent.width
                height: from.height + to.height + location_spacing.height

                LocationEntry { id: from; type: qsTr("From") }

                SwitchLocation {
                    anchors.topMargin: UIConstants.DEFAULT_MARGIN/2
                    from: from
                    to: to
                }

                Spacing { id: location_spacing; anchors.top: from.bottom }

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
                        source: '../../images/background.png'
                    }

                    Text {
                        id: timeButton
                        font.pixelSize: MyConstants.FONT_XXXXLARGE
                        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                        text: Qt.formatTime(root.myTime, "hh:mm")
                    }

                    MouseArea {
                        id: timeMouseArea
                        anchors.fill: parent
                        onClicked: {
                            timePicker.hour = Qt.formatTime(root.myTime, "hh")
                            timePicker.minute = Qt.formatTime(root.myTime, "mm")
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
                        font.pixelSize: UIConstants.FONT_LARGE
                        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
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
                    source: '../../images/background.png'
                }
                Text {
                    id: dateButton
                    height: ExtrasConstants.SIZE_BUTTON
                    font.pixelSize: MyConstants.FONT_XXLARGE
                    color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                    text: Qt.formatDate(root.myDate, "dd. MMMM yyyy")
                }

                MouseArea {
                    id: dateMouseArea
                    anchors.fill: parent
                    onClicked: {
                        datePicker.day = Qt.formatDate(root.myDate, "dd")
                        datePicker.month = Qt.formatDate(root.myDate, "MM")
                        datePicker.year = Qt.formatDate(root.myDate, "yyyy")
                        datePicker.open()
                    }
                }
            }

            Button {
                id: timedate_now
                text: qsTr("Now")
                font.pixelSize: UIConstants.FONT_SMALL
                anchors.horizontalCenter: parent.horizontalCenter
                width: 150
                height: 40
                onClicked: {
                    root.myTime = root.myDate = new Date()
                    timeButton.text = Qt.formatTime(root.myTime, "hh:mm")
                    dateButton.text = Qt.formatDate(root.myDate, "dd. MMMM yyyy")
                }
            }
        }
    }
}
