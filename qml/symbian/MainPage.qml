import QtQuick 1.1
import com.nokia.symbian 1.0
import com.nokia.extras 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/storage.js" as Storage
import "../common/favorites.js" as Favorites
import "../common/helper.js" as Helper

Page {
    id: root
    tools: toolBarLayout

    property date myDate
    property date myTime

    Component.onCompleted: {
        myDate = new Date()
        myTime = new Date()
        Storage.initialize()
        Favorites.initialize()
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: pageStack.depth <= 1 ? Qt.quit() : pageStack.pop()
        }
        ToolButton {
            text: qsTr("Search")
            enabled: ((from.destination_coords != '' || from.destination_valid) && (to.destination_coords != '' || to.destination_valid))
            onClicked: {
                resu.routeModel.clear()
                var walking_speed = Storage.getSetting("walking_speed")
                var optimize = Storage.getSetting("optimize")
                var change_margin = Storage.getSetting("change_margin")
                Reittiopas.route(from.getCoords().coords,
                                 to.getCoords().coords,
                                 Qt.formatDate(root.myDate, "yyyyMMdd"),
                                 Qt.formatTime(root.myTime, "hhmm"),
                                 timeType.checked? "arrival" : "departure",
                                 walking_speed == "Unknown"?"70":walking_speed,
                                 optimize == "Unknown"?"default":optimize,
                                 change_margin == "Unknown"?"3":Math.floor(change_margin),
                                 resu.routeModel)
                resu.from = from.getCoords().name
                resu.to = to.getCoords().name
                pageStack.push(resu)
            }
        }
        ToolButton { iconSource: "toolbar-view-menu" ; onClicked: myMenu.open(); }
    }

    ResultPage { id: resu }

    DatePickerDialog {
        id: datePicker
        onAccepted: {
            root.myDate = new Date(datePicker.year, datePicker.month-1, datePicker.day, 0)
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

            Spacing {}

            Item {
                width: parent.width
                height: from.height + to.height + UIConstants.DEFAULT_MARGIN

                LocationEntry { id: from; type: qsTr("From") }

                Spacing { id: location_spacing; anchors.top: from.bottom }

                SwitchLocation {
                    anchors.topMargin: location_spacing.height/2
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
                        source: theme.inverted ? '../../images/background.png': '../../images/background.png'
                    }

                    Text {
                        id: timeButton
                        font.pixelSize: MyConstants.FONT_XXXXLARGE * appWindow.scaling_factor
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                        color: UIConstants.COLOR_INVERTED_FOREGROUND
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
                Item {
                    width: 150
                    height: timeType.height + timeTypeText.height
                    Switch {
                        id: timeType
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: timeTypeText
                        anchors.top: timeType.bottom
                        anchors.horizontalCenter: timeType.horizontalCenter
                        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
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
                    source: theme.inverted ? '../../images/background.png': '../../images/background.png'
                }
                Text {
                    id: dateButton
                    height: ExtrasConstants.SIZE_BUTTON
                    font.pixelSize: MyConstants.FONT_XXLARGE * appWindow.scaling_factor
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
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
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
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
