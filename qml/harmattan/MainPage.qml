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
import com.nokia.meego 1.1
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "storage.js" as Storage
import "helper.js" as Helper
import "theme.js" as Theme

Page {
    id: mainPage
    tools: mainTools

    property date myTime

    property variant toCoords: ''
    property variant toName: ''

    property variant fromCoords: ''
    property variant fromName: ''

    property bool endpointsValid : (toCoords && fromCoords)

    /* Connect dbus callback to function newRoute() */
    Connections {
        target: Route
        onNewRoute: newRoute(name, coord)
    }

    function newRoute(name, coord) {
        console.log("New route request " + name + " " + coord)

        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        updateTime()

        /* clear 'from' field, and enter new 'to' */
        from.updateLocation("", 0 , "")
        from.getCurrentCoords()
        to.updateLocation(name, 0, coord)
        state = "waiting"
    }

    function updateTime() {
        myTime = new Date()

        /* Set date for date picker */
        timePicker.hour = Qt.formatTime(mainPage.myTime, "hh")
        timePicker.minute = Qt.formatTime(mainPage.myTime, "mm")

        /* Set date for date picker */
        datePicker.day = Qt.formatDate(mainPage.myTime, "dd")
        datePicker.month = Qt.formatDate(mainPage.myTime, "MM")
        datePicker.year = Qt.formatDate(mainPage.myTime, "yyyy")
    }

    onEndpointsValidChanged: {
        /* if we receive coordinates we are waiting for, start route search */
        if(state == "waiting" && endpointsValid) {
            var parameters = {}
            setParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
    }

    Component.onCompleted: {
        theme.inverted = Theme.theme[appWindow.colorscheme].PLATFORM_INVERTED
        Storage.initialize()

        updateTime()
    }

    states: [
        State {
            name: "normal"
            PropertyChanges { target: waiting; opacity: 0.0 }
            PropertyChanges { target: busyIndicator; opacity: 0.0 }
        },
        State {
            name: "waiting"
            PropertyChanges { target: waiting; opacity: 0.7 }
            PropertyChanges { target: busyIndicator; opacity: 1.0 }
        }
    ]
    transitions: [
        Transition {
            PropertyAnimation { property: opacity; duration: 200 }
        }
    ]
    state: "normal"

    function setParameters(parameters) {
        var walking_speed = Storage.getSetting("walking_speed")
        var optimize = Storage.getSetting("optimize")
        var change_margin = Storage.getSetting("change_margin")

        parameters.from_name = fromName
        parameters.from = fromCoords
        parameters.to_name = toName
        parameters.to = toCoords

        parameters.time = mainPage.myTime
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
    }

    ToolBarLayout {
        id: mainTools
        ToolIcon { iconId: "toolbar-back"; visible: false; onClicked: { myMenu.close(); pageStack.pop(); } }
        ToolButton {
            text: qsTr("Search")
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: endpointsValid
            onClicked: {
                var parameters = {}
                setParameters(parameters)
                pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: myMenu.open(); }
    }

    DatePickerDialog {
        id: datePicker
        titleText: qsTr("Choose date")
        onAccepted: {
            var tempTime = new Date(datePicker.year, datePicker.month-1, datePicker.day,
                                    mainPage.myTime.getHours(), mainPage.myTime.getMinutes())
            mainPage.myTime = tempTime
            dateButton.text = Qt.formatDate(mainPage.myTime, "dd. MMMM yyyy")
        }
        minimumYear: 2012

        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    TimePickerDialog {
        id: timePicker
        titleText: qsTr("Choose time")
        onAccepted: {
            var tempTime = new Date(mainPage.myTime.getFullYear(), mainPage.myTime.getMonth(),
                                    mainPage.myTime.getDate(), timePicker.hour, timePicker.minute)
            mainPage.myTime = tempTime
            timeButton.text = Qt.formatTime(mainPage.myTime, "hh:mm")
        }

        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    Rectangle {
        id: waiting
        color: "black"
        z: 250
        opacity: 0.0
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            enabled: mainPage.state == "waiting"
            onClicked: mainPage.state = "normal"
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: 260
        opacity: 0.0
        running: true
        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle {
            size: "large"
        }
    }

    ApplicationHeader {
        id: title
        title: qsTr("Meegopas")
        color: Theme.theme[appWindow.colorscheme].COLOR_APPHEADER_BACKGROUND
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    Flickable {
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors {
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

            Spacing { height: appWindow.inPortrait? 20 : 0 }

            Item {
                width: parent.width
                height: from.height + to.height + UIConstants.DEFAULT_MARGIN

                LocationEntry {
                    id: from
                    type: qsTr("From")
                    onLocationDone: {
                        fromName = name
                        fromCoords = coord
                    }
                }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 20 }

                SwitchLocation {
                    anchors.topMargin: UIConstants.DEFAULT_MARGIN/2
                    from: from
                    to: to
                }

                LocationEntry {
                    id: to
                    type: qsTr("To")
                    onLocationDone: {
                        toName = name
                        toCoords = coord
                    }
                    anchors.top: location_spacing.bottom
                }
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
                        text: Qt.formatTime(mainPage.myTime, "hh:mm")
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
                }
                SwitchStyle {
                    id: customswitch
                    switchOn: customswitch.switchOff
                }
                Item {
                    width: 150
                    height: timeType.height + timeTypeText.height
                    anchors.verticalCenter: timeContainer.verticalCenter
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
                        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
                        text: timeType.checked? qsTr("arrival") : qsTr("departure")
                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize * 1.2

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
                    text: Qt.formatDate(mainPage.myTime, "dd. MMMM yyyy")
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
            }

            Button {
                id: timedate_now
                text: qsTr("Now")
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scaling_factor
                anchors.horizontalCenter: parent.horizontalCenter
                width: 150
                height: 40
                onClicked: {
                    updateTime()
                }
            }
        }
    }
}
