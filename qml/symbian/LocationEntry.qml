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
import QtMobility.location 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "favorites.js" as Favorites

Column {
    property alias type : label.text
    property variant destination_coords : ''
    property bool destination_valid : (suggestionModel.count > 0)
    property alias model: suggestionModel
    property alias text : textfield.text
    property alias auto_update : textfield.auto_update
    property alias selected_favorite : favoriteQuery.selectedIndex
    property bool disable_favorites : false

    height: textfield.height + labelContainer.height
    width: parent.width

    Component.onCompleted: {
        Favorites.initialize()
    }

    function clear() {
        suggestionModel.source = ""
        textfield.text = ''
        destination_coords = ''
        query.selectedIndex = -1
    }

    function update_location(name, housenumber, coords) {
        suggestionModel.source = ""
        var address = name

        if(housenumber)
            address += " " + housenumber

        textfield.auto_update = true
        textfield.text = address
        destination_coords = coords
    }

    function getCoords() {
        if(destination_coords != '') {
            return { "name":text, "coords":destination_coords }
        }
        else if(textfield.acceptableInput) {
            return { "name":suggestionModel.get(0).name, "coords":suggestionModel.get(0).coords}
        }
        else
            console.log("no acceptable input")
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: true
    }

    XmlListModel {
        id: suggestionModel
        query: "/response/node"
        XmlRole { name: "name"; query: "name/string()" }
        XmlRole { name: "city"; query: "city/string()" }
        XmlRole { name: "coords"; query: "coords/string()" }
        XmlRole { name: "housenumber"; query: "details/houseNumber/string()" }

        onCountChanged: {
            if(suggestionModel.count == 1) {
                update_location(suggestionModel.get(0).name.split(',', 1).toString(),
                                suggestionModel.get(0).housenumber,
                                suggestionModel.get(0).coords)
            }
        }
    }

    ListModel {
        id: favoritesModel
    }

    SelectionDialog {
        id: query
        model: suggestionModel
        delegate: SuggestionDelegate {}
        titleText: qsTr("Choose location")
        onAccepted: {
            update_location(suggestionModel.get(selectedIndex).name,
                            suggestionModel.get(selectedIndex).housenumber,
                            suggestionModel.get(selectedIndex).coords)
        }
        onRejected: {}
    }

    SelectionDialog {
        id: favoriteQuery
        model: favoritesModel
        titleText: qsTr("Choose location")

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
                update_location(favoritesModel.get(selectedIndex).modelData,
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
        anchors.rightMargin: UIConstants.DEFAULT_MARGIN
        height: label.height
        width: label.width + count.width
        BorderImage {
            anchors.fill: parent
            visible: labelMouseArea.pressed
            source: 'qrc:/images/background.png'
        }
        Text {
            id: label
            font.pixelSize: UIConstants.FONT_XXLARGE
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            anchors.left: parent.left
            anchors.top: parent.top
        }
        Bubble {
            id: count
            count: suggestionModel.count
            visible: (suggestionModel.count > 1)
            anchors.left: label.right
            anchors.leftMargin: 2
            anchors.verticalCenter: label.verticalCenter
        }
        BusyIndicator {
            id: busyIndicator
            visible: suggestionModel.status == XmlListModel.Loading
            running: true
            anchors.left: label.right
            anchors.verticalCenter: label.verticalCenter
        }

        MouseArea {
            id: labelMouseArea
            anchors.fill: parent
            enabled: (suggestionModel.count > 1)
            onClicked: {
                if(suggestionModel.count > 1) {
                    query.open()
                }
            }
        }
    }

    Item {
        width: parent.width
        height: textfield.height
        TextField {
            id: textfield
            platformLeftMargin: 30
            property bool auto_update : false
            anchors.left: parent.left
            anchors.right: disable_favorites ? parent.right : favoritePicker.left
            placeholderText: qsTr("Type a location")
            validator: RegExpValidator { regExp: /^.{3,50}$/ }
            inputMethodHints: Qt.ImhNoPredictiveText

            onTextChanged: {
                if(auto_update)
                    auto_update = false
                else {
                    suggestionModel.source = ""
                    selected_favorite = -1
                    destination_coords = ''
                    if(acceptableInput)
                        suggestionTimer.restart()
                    else
                        suggestionTimer.stop()
                }
            }
            Rectangle {
                id: status
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: UIConstants.DEFAULT_MARGIN
                smooth: true
                radius: 10
                height: 20
                width: 20
                state: destination_coords?"validated":suggestionModel.count > 0? "sufficient":"error"
                opacity: 0.6

                states: [
                    State {
                        name: "error"
                        PropertyChanges { target: status; color: "red" }
                    },
                    State {
                        name: "sufficient"
                        PropertyChanges { target: status; color: "yellow" }
                    },
                    State {
                        name: "validated"
                        PropertyChanges { target: status; color: "green" }
                    }
                ]
                transitions: [
                    Transition {
                        ColorAnimation { duration: 100 }
                    }
                ]
            }
            Image {
                id: clearLocation
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/images/clear.png"
                visible: ((textfield.activeFocus) && !busyIndicator.visible)
                opacity: 0.8
                MouseArea {
                    id: locationInputMouseArea
                    anchors.fill: parent
                    onClicked: {
                        clear()
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
                        !theme.inverted?'qrc:/images/favorite-unmark.png':'qrc:/images/favorite-unmark-inverse.png' :
                        !theme.inverted?'qrc:/images/favorite-mark.png':'qrc:/images/favorite-mark-inverse.png'
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            mouseArea.onClicked: {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                favoritesModel.insert(0, {modelData: qsTr("Current location"),coord:"0,0"})
                favoriteQuery.open()
            }
        }
    }
}
