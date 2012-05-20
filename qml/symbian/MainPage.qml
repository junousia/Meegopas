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
import "helper.js" as Helper
import "theme.js" as Theme

Page {
    id: mainPage
    tools: mainTools

    property date myTime

    property variant toCoord: ''
    property variant toName: ''

    property variant fromCoord: ''
    property variant fromName: ''

    property bool endpointsValid : (toCoord && fromCoord)

    /* Connect dbus callback to function newRoute() */
    Connections {
        target: Route
        onNewRoute: newRoute(name, coord)
    }

    function newRoute(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        updateTime()

        /* clear 'from' field, and enter new 'to' */
        from.updateLocation("", 0 , "")
        from.getCurrentCoord()
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
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
    }

    Component.onCompleted: {
//        var saved_theme = Storage.getSetting("theme")
//        if(saved_theme && saved_theme != "Unknown")
//            appWindow.colorscheme = saved_theme

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

    function setRouteParameters(parameters) {
        var walking_speed = Storage.getSetting("walking_speed")
        var optimize = Storage.getSetting("optimize")
        var change_margin = Storage.getSetting("change_margin")

        parameters.from_name = fromName
        parameters.from = fromCoord
        parameters.to_name = toName
        parameters.to = toCoord

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

    function setCyclingParameters(parameters) {
        var optimize_cycling = Storage.getSetting("optimize_cycling")

        parameters.from_name = fromName
        parameters.from = fromCoord
        parameters.to_name = toName
        parameters.to = toCoord
        parameters.profile = optimize_cycling == "Unknown"?"default":optimize_cycling
    }

    ToolBarLayout {
        id: mainTools
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: pageStack.depth <= 1 ? Qt.quit() : pageStack.pop()
        }
        ButtonRow {
            Button {
                text: qsTr("Route")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: endpointsValid
                onClicked: {
                    var parameters = {}
                    setRouteParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }
            }
            Button {
                text: qsTr("Cycling")
                enabled: endpointsValid
                onClicked: {
                    var parameters = {}
                    setCyclingParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("CyclingPage.qml"), { search_parameters: parameters })
                }
            }
        }
        ToolButton { iconSource: "toolbar-view-menu" ; onClicked: myMenu.open(); }
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
        width: 75
        height: 75
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
            spacing: appWindow.inPortrait? UIConstants.DEFAULT_MARGIN : UIConstants.DEFAULT_MARGIN / 2
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
                        fromCoord = coord
                    }
                    onLocationError: {
                        /* error in getting current position, cancel the wait */
                        mainPage.state = "normal"
                    }
                }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 30 }

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
                        toCoord = coord
                    }
                    anchors.top: location_spacing.bottom
                }
            }

            Spacing { height: appWindow.inPortrait? 20 : 0 }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                height: Math.max(timetypeContainer.height,timeContainer.height)
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

                Item {
                    id: timetypeContainer
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
