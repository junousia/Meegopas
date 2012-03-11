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
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "storage.js" as Storage
import "favorites.js" as Favorites
import "helper.js" as Helper
import "theme.js" as Theme

Page {
    id: root
    tools: toolBarLayout

    property date myTime

    Component.onCompleted: {
        Storage.initialize()
        Favorites.initialize()

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
        id: toolBarLayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: pageStack.pop()
            visible: pageStack.depth > 1
        }
        ToolButton {
            text: qsTr("Search")
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
                parameters.transport_types = ["ferry"]
                if(Storage.getSetting("train_disabled") != "true")
                    parameters.transport_types.push("train")
                if(Storage.getSetting("bus_disabled") != "true") {
                    parameters.transport_types.push("bus")
                    parameters.transport_types.push("uline")
                    parameters.transport_types.push("service")
                }
                if(Storage.getSetting("metro_disabled") != "true")
                    parameters.transport_types.push("metro")
                if(Storage.getSetting("tram_disabled") != "true")
                    parameters.transport_types.push("tram")

                pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            }
        }
        ToolButton { iconSource: "toolbar-view-menu" ; onClicked: myMenu.open(); }
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

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    Flickable {
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
            horizontalCenter: parent.horizontalCenter
        }

        interactive: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: content_column.height

        Column {
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width

            Item {
                width: parent.width
                height: from.height + to.height + UIConstants.DEFAULT_MARGIN

                LocationEntry { id: from; type: qsTr("From") }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 30 }

                SwitchLocation {
                    anchors.topMargin: UIConstants.DEFAULT_MARGIN/2
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

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
                        z: -1
                        visible: timeMouseArea.pressed
                    }

                    Text {
                        id: timeButton
                        font.pixelSize: UIConstants.FONT_XXXXLARGE * appWindow.scaling_factor
                    color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
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
                Item {
                    width: 150
                    height: timeType.height + timeTypeText.height
                    anchors.verticalCenter: timeContainer.verticalCenter
                    Switch {
                        id: timeType
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: timeTypeText
                        anchors.top: timeType.bottom
                        anchors.horizontalCenter: timeType.horizontalCenter
                        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
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

                Rectangle {
                    anchors.fill: parent
                    color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
                    z: -1
                    visible: dateMouseArea.pressed
                }
                Text {
                    id: dateButton
                    height: UIConstants.SIZE_BUTTON
                    font.pixelSize: UIConstants.FONT_XXLARGE * appWindow.scaling_factor
                    color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
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
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scaling_factor
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
