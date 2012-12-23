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

    property date myTime

    onMyTimeChanged: console.debug("Time changed: " + myTime)

    /* Current location acquired with GPS */
    property variant currentCoord: ''
    property variant currentName: ''

    /* Values entered in "To" field */
    property variant toCoord: ''
    property variant toName: ''

    /* Values entered in "From" field */
    property variant fromCoord: ''
    property variant fromName: ''

    property bool endpointsValid : (toCoord && (fromCoord || currentCoord))

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
        timeButton.updateTime()
        dateButton.updateDate()

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

    Component.onCompleted: {
        theme.inverted = Theme.theme[appWindow.colorscheme].PLATFORM_INVERTED
        Storage.initialize()

        function acceptCallback() {
            Storage.setSetting('gps', 'true')
            appWindow.gpsEnabled = true
            mainTools.enabled = true
        }

        function rejectCallback() {
            Storage.setSetting('gps', 'false')
            appWindow.gpsEnabled = false
            mainTools.enabled = true
        }

        var allowGps = Storage.getSetting("gps")
        if(allowGps === "Unknown") {
            var agreement = Qt.createComponent("Agreement.qml")
            var agreementDialog = agreement.createObject(mainPage)
            agreementDialog.accepted.connect(acceptCallback)
            agreementDialog.rejected.connect(rejectCallback)
            mainTools.enabled = false
            agreementDialog.open()
        }
        else if(allowGps == "true") {
            appWindow.gpsEnabled = true
        }

        var apiValue = Storage.getSetting("api")
        if(apiValue === "Unknown") {
            Storage.setSetting("api", "helsinki")
            var apiComponent = Qt.createComponent("ApiDialog.qml")
            var apiDialog = apiComponent.createObject(mainPage)
            apiDialog.open()
        }

        timeButton.updateTime()
        dateButton.updateDate()
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
        parameters.timetype = timeTypeSwitch.checked? "arrival" : "departure"
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
            margins: UIConstants.DEFAULT_MARGIN
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
                        toCoord = coord
                    }
                    anchors.top: location_spacing.bottom
                }
            }

            Spacing { height: appWindow.inPortrait? 20 : 0 }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                TimeButton {
                    id: timeButton
                }

                Connections {
                    target: timeButton
                    onTimeChanged: {
                        mainPage.myTime = new Date(myTime.getFullYear()? myTime.getFullYear() : 0,
                                                myTime.getMonth()? myTime.getMonth() : 0,
                                                myTime.getDate()? myTime.getDate() : 0,
                                                newTime.getHours(), newTime.getMinutes())
                    }
                }

                TimeTypeSwitch {
                    id: timeTypeSwitch
                    anchors.verticalCenter: timeButton.verticalCenter
                }
            }

            DateButton {
                id: dateButton
            }

            Connections {
                target: dateButton
                onDateChanged: {
                    mainPage.myTime = new Date(newDate.getFullYear(), newDate.getMonth(), newDate.getDate(),
                                               myTime.getHours()? myTime.getHours() : 0,
                                               myTime.getMinutes()? myTime.getMinutes() : 0)
                }
            }

            Button {
                id: timeDateNow
                text: qsTr("Now")
                font.pixelSize: UIConstants.FONT_SMALL
                anchors.horizontalCenter: parent.horizontalCenter
                width: 150
                height: 40
                onClicked: {
                    timeButton.updateTime()
                    dateButton.updateDate()
                }
            }
        }
    }
}
