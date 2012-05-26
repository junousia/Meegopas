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
import QtMobility.location 1.2
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "favorites.js" as Favorites
import "theme.js" as Theme

Column {
    property alias type : label.text
    property alias font : label.font
    property alias label : labelContainer
    property alias lineHeightMode : label.lineHeightMode
    property alias lineHeight : label.lineHeight
    property alias textfield : textfield.text
    property variant destination_name : ''
    property variant destination_coord : ''

    property bool destination_valid : (suggestionModel.count > 0)
    property alias selected_favorite : favoriteQuery.selectedIndex
    property bool disable_favorites : false

    height: textfield.height + labelContainer.height
    width: parent.width

    signal locationDone(string name, string coord)
    signal locationError()

    state: destination_coord ? "validated" : destination_valid ? "sufficient" : "error"

    states: [
        State {
            name: "error"
            PropertyChanges { target: statusIndicator; color: "red" }
        },
        State {
            name: "sufficient"
            PropertyChanges { target: statusIndicator; color: "yellow" }
        },
        State {
            name: "validated"
            PropertyChanges { target: statusIndicator; color: "green" }
        }
    ]
    transitions: [
        Transition {
            ColorAnimation { duration: 100 }
        }
    ]

    Component.onCompleted: {
        Favorites.initialize()
    }

    function clear() {
        suggestionModel.source = ""
        textfield.text = ''
        destination_coord = ''
        query.selectedIndex = -1
        locationDone("","")
    }

    function updateLocation(name, housenumber, coord) {
        suggestionModel.source = ""
        var address = name

        if(housenumber && address.slice(address.length - housenumber.length) != housenumber)
            address += " " + housenumber

        destination_name = address
        destination_coord = coord
        textfield.text = address

        locationDone(address, coord)
    }

    Timer {
        id: gpsTimer
        onTriggered: getCurrentCoord()
        interval: 200
        repeat: true
    }

    function positionValid(position) {
        if(position.latitudeValid &&
                position.longitudeValid &&
                position.horizontalAccuracyValid &&
                position.horizontalAccuracy < 150 &&
                position.verticalAccuracyValid &&
                position.verticalAccuracy < 150)
            return true
        else
            return false
    }

    function getCurrentCoord() {
        /* wait until position is accurate enough */
        if(positionValid(positionSource.position)) {
            gpsTimer.stop()
            suggestionModel.source = Reittiopas.get_reverse_geocode(positionSource.position.coordinate.latitude.toString(),
                                                                    positionSource.position.coordinate.longitude.toString())
        } else {
            /* poll again in 200ms */
            gpsTimer.start()
        }
    }

    FavoriteSheet { id: favorite_sheet }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: platformWindow.active
    }

    XmlListModel {
        id: suggestionModel
        query: "/response/node"
        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "city"; query: "city/string()" }
        XmlRole { name: "coord"; query: "coords/string()" }
        XmlRole { name: "shortCode"; query: "shortCode/string()" }
        XmlRole { name: "housenumber"; query: "details/houseNumber/string()" }

        onStatusChanged: {
            if(status == XmlListModel.Ready && source != "") {
                /* if only result, take it into use */
                if(suggestionModel.count == 1) {
                    updateLocation(suggestionModel.get(0).name.split(',', 1).toString(),
                                   suggestionModel.get(0).housenumber,
                                   suggestionModel.get(0).coord)
                } else if (suggestionModel.count == 0) {
                    appWindow.banner.success = false
                    appWindow.banner.text = qsTr("No results")
                    appWindow.banner.show()
                } else {
                    /* just update the first result to main page */
                    locationDone(suggestionModel.get(0).name.split(',', 1).toString(),suggestionModel.get(0).coord)
                }
            } else if (status == XmlListModel.Error) {
                selected_favorite = -1
                suggestionModel.source = ""
                locationDone("", 0, "")
                locationError()
                appWindow.banner.success = false
                appWindow.banner.text = qsTr("Could not find location")
                appWindow.banner.show()
            }
        }
    }

    ListModel {
        id: favoritesModel
    }

    MySelectionDialog {
        id: query
        model: suggestionModel
        delegate: SuggestionDelegate {}
        titleText: qsTr("Choose location")
        onAccepted: {
            updateLocation(suggestionModel.get(selectedIndex).name,
                            suggestionModel.get(selectedIndex).housenumber,
                            suggestionModel.get(selectedIndex).coord)
        }
        onRejected: {}
    }

    MySelectionDialog {
        id: favoriteQuery
        model: favoritesModel
        titleText: qsTr("Choose location")
        delegate: FavoritesDelegate {}
        height: 5 * UIConstants.LIST_ITEM_HEIGHT_DEFAULT * appWindow.scaling_factor + UIConstants.DEFAULT_MARGIN
        onAccepted: {
            /* if positionsource used */
            if(selectedIndex == 0) {
                if(positionSource.position.latitudeValid && positionSource.position.longitudeValid) {
                    suggestionModel.source = Reittiopas.get_reverse_geocode(positionSource.position.coordinate.latitude.toString(),
                                                                            positionSource.position.coordinate.longitude.toString())
                }
                else {
                    favoriteQuery.selectedIndex = -1
                    appWindow.banner.success = false
                    appWindow.banner.text = qsTr("Position not yet available")
                    appWindow.banner.show()
                }
            } else {
                updateLocation(favoritesModel.get(selectedIndex).modelData,
                                0,
                                favoritesModel.get(selectedIndex).coord)
            }
        }
        onRejected: {}
    }

    Timer {
        id: suggestionTimer
        interval: 1200
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            if(textfield.acceptableInput) {
                suggestionModel.source = Reittiopas.get_geocode(textfield.text)
            }
        }
    }

    Item {
        id: labelContainer
        anchors.top: parent.top
        anchors.rightMargin: 5
        height: label.height
        width: label.width + count.width
        Rectangle {
            height: parent.height
            width: label.width + count.width
            color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND_CLICKED
            z: -1
            visible: labelMouseArea.pressed
        }
        Text {
            id: label
            font.pixelSize: UIConstants.FONT_XXLARGE * appWindow.scaling_factor
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.1
        }
        Bubble {
            id: count
            count: suggestionModel.count
            visible: (suggestionModel.count > 1)
            anchors.left: label.right
            anchors.leftMargin: 2
            anchors.verticalCenter: label.verticalCenter
        }

        MouseArea {
            id: labelMouseArea
            anchors.fill: parent
            enabled: (suggestionModel.count > 1)
            onClicked: {
                if(suggestionModel.count > 1) {
                    query.open()
                    textfield.platformCloseSoftwareInputPanel()
                }
            }
        }
    }

    Item {
        width: parent.width
        height: textfield.height
        MyTextfield {
            id: textfield
            anchors.left: parent.left
            anchors.right: disable_favorites ? parent.right : favoritePicker.left
            placeholderText: qsTr("Type a location")

            onTextChanged: {
                if(text != destination_name) {
                    suggestionModel.source = ""
                    selected_favorite = -1
                    destination_coord = ""
                    destination_name = ""
                    locationDone("","")

                    if(acceptableInput)
                        suggestionTimer.restart()
                    else
                        suggestionTimer.stop()
                }
            }
            Rectangle {
                id: statusIndicator
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: UIConstants.DEFAULT_MARGIN
                smooth: true
                radius: 10
                height: 20
                width: 20
                opacity: 0.6
            }
            Image {
                id: clearLocation
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/images/clear.png"
                visible: ((textfield.activeFocus) && !busyIndicator.visible)
                MouseArea {
                    id: locationInputMouseArea
                    anchors.fill: parent
                    onClicked: {
                        clear()
                    }
                }
            }

            MyBusyIndicator {
                id: busyIndicator
                visible: suggestionModel.status == XmlListModel.Loading
                running: true
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 15

                MouseArea {
                    id: spinnerMouseArea
                    anchors.fill: parent
                    onClicked: {
                        suggestionModel.source = ""
                    }
                }
            }
            Keys.onReturnPressed: {
                textfield.platformCloseSoftwareInputPanel()
                parent.focus = true
            }
        }

        MyButton {
            id: favoritePicker
            enabled: !disable_favorites
            visible: !disable_favorites
            source: selected_favorite == -1?
                        !Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?'qrc:/images/favorite-unmark.png':'qrc:/images/favorite-unmark-inverse.png' :
                        !Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?'qrc:/images/favorite-mark.png':'qrc:/images/favorite-mark-inverse.png'
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            mouseArea.onClicked: {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                favoritesModel.insert(0, {modelData: qsTr("Current location"),coord:"0,0"})
                favoriteQuery.open()
            }
            mouseArea.onPressAndHold: {
                if(destination_coord && favoriteQuery.selectedIndex <= 0) {
                    if(("OK" == Favorites.addFavorite(textfield.text, destination_coord))) {
                        favoritesModel.clear()
                        Favorites.getFavorites(favoritesModel)
                        favoriteQuery.selectedIndex = favoritesModel.count
                        appWindow.banner.success = true
                        appWindow.banner.text = qsTr("Location added to favorites")
                        appWindow.banner.show()
                    } else {
                        appWindow.banner.success = false
                        appWindow.banner.text = qsTr("Location already in the favorites")
                        appWindow.banner.show()
                    }

                }
            }
        }
    }
}
