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
import "reittiopas.js" as Reittiopas
import "storage.js" as Storage
import "helper.js" as Helper
import "theme.js" as Theme

Page {
    id: mainPage
    tools: mainTools

    property alias timePicker : timeLoader.item
    property alias datePicker : dateLoader.item

    property date myTime

    property variant currentCoord: ''
    property variant currentName: ''

    property variant toCoord: ''
    property variant toName: ''

    property variant fromCoord: ''
    property variant fromName: ''

    property bool endpointsValid : (toCoord && (fromCoord || currentCoord))

    /* Connect dbus callback to function newRoute() */
    Connections {
        target: Route
        onNewRoute: newRoute(name, coord)
    }

    /* Connect dbus callback to function newCycling() */
    Connections {
        target: Route
        onNewCycling: newCycling(name, coord)
    }

    function newRoute(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        updateTime()

        /* Update new destination to "to" */
        to.updateLocation(name, 0, coord)

        /* Remove user input location and use gps location */
        from.clear()

        /* use current location if available - otherwise wait for it */
        if(currentCoord != "") {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
        else if(appWindow.gpsEnabled == false) {
            appWindow.banner.success = false
            appWindow.banner.text = qsTr("Positioning service disabled from application settings")
            appWindow.banner.show()
        }
        else {
            state = "waiting_route"
        }
    }

    function newCycling(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        to.updateLocation(name, 0, coord)

        if(currentCoord != "") {
            var parameters = {}
            setCyclingParameters(parameters)
            pageStack.push(Qt.resolvedUrl("CyclingPage.qml"), { search_parameters: parameters })
        }
        else if(appWindow.gpsEnabled == false) {
            appWindow.banner.success = false
            appWindow.banner.text = qsTr("Positioning service disabled from application settings")
            appWindow.banner.show()
        }
        else {
            state = "waiting_cycling"
        }
    }

    function updateTime() {
        myTime = new Date()

        /* Set date for date picker */
        timePicker.hour = Qt.formatTime(mainPage.myTime, "hh")
        timePicker.minute = Qt.formatTime(mainPage.myTime, "mm")
        timeButton.text = Qt.formatTime(mainPage.myTime, "hh:mm")

        /* Set date for date picker */
        datePicker.day = Qt.formatDate(mainPage.myTime, "dd")
        datePicker.month = Qt.formatDate(mainPage.myTime, "MM")
        datePicker.year = Qt.formatDate(mainPage.myTime, "yyyy")
        dateButton.text = Qt.formatDate(mainPage.myTime, "dd. MMMM yyyy")
    }

    onEndpointsValidChanged: {
        /* if we receive coordinates we are waiting for, start route search */
        if(state == "waiting_route" && endpointsValid) {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
        if(state == "waiting_cycling" && endpointsValid) {
            var parameters = {}
            setCyclingParameters(parameters)
            pageStack.push(Qt.resolvedUrl("CyclingPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
    }

    Component.onCompleted: {
        theme.inverted = Theme.theme[appWindow.colorscheme].PLATFORM_INVERTED
        Storage.initialize()

        if(Storage.getSetting("gps") == "false")
            appWindow.gpsEnabled = false
        console.debug("gps enabled: " + Storage.getSetting("gps"))
        updateTime()
    }

    states: [
        State {
            name: "normal"
            PropertyChanges { target: waiting; opacity: 0.0 }
            PropertyChanges { target: busyIndicator; opacity: 0.0 }
        },
        State {
            name: "waiting_route"
            PropertyChanges { target: waiting; opacity: 0.7 }
            PropertyChanges { target: busyIndicator; opacity: 1.0 }
        },
        State {
            name: "waiting_cycling"
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

        parameters.from_name = fromName ? fromName : currentName
        parameters.from = fromCoord ? fromCoord : currentCoord
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

        parameters.from_name = fromName ? fromName : currentName
        parameters.from = fromCoord ? fromCoord : currentCoord
        parameters.to_name = toName
        parameters.to = toCoord
        parameters.profile = optimize_cycling == "Unknown"?"default":optimize_cycling
    }

    ToolBarLayout {
        id: mainTools
        ToolIcon { iconId: "toolbar-back"; visible: false; onClicked: { menu.close(); pageStack.pop(); } }
        ToolButtonRow {
            ToolButton {
                text: qsTr("Cycling")
                enabled: endpointsValid
                onClicked: {
                    var parameters = {}
                    setCyclingParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("CyclingPage.qml"), { search_parameters: parameters })
                }
            }
            ToolButton {
                text: qsTr("Route search")
                enabled: endpointsValid
                onClicked: {
                    var parameters = {}
                    setRouteParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }
            }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: menu.open(); }
    }
    Component {
        id: dateComponent
        DatePickerDialog {
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
    }
    Component {
        id: timeComponent

        TimePickerDialog {
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
    }
    Loader {
        id: dateLoader
        anchors.fill: parent
        sourceComponent: dateComponent
    }
    Loader {
        id: timeLoader
        anchors.fill: parent
        sourceComponent: timeComponent
    }

    Rectangle {
        id: waiting
        color: "black"
        z: 250
        opacity: 0.0
        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            enabled: mainPage.state != "normal"
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

    Flickable {
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors {
            margins: UIConstants.DEFAULT_MARGIN * appWindow.scalingFactor
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
                    isFrom: true
                    onLocationDone: {
                        fromName = name
                        fromCoord = coord
                    }
                    onCurrentLocationDone: {
                        currentName = name
                        currentCoord = coord
                    }
                    onLocationError: {
                        /* error in getting current position, cancel the wait */
                        mainPage.state = "normal"
                    }
                }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 20 * appWindow.scalingFactor }

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
                        font.pixelSize: UIConstants.FONT_XXXXLARGE * appWindow.scalingFactor
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
                        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
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
                    font.pixelSize: UIConstants.FONT_XXLARGE * appWindow.scalingFactor
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
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scalingFactor
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
