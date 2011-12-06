import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.location 1.2
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/favorites.js" as Favorites

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
        suggestionModel.clear()
        textfield.text = ''
        destination_coords = ''
        query.selectedIndex = -1
    }

    function update_location(name, coords) {
        suggestionModel.clear()
        textfield.auto_update = true
        textfield.text = name
        destination_coords = coords
    }

    Timer {
        id: updateTimer
        repeat: false
        interval: 100
        triggeredOnStart: false
        onTriggered: {
            if(suggestionModel.count == 1 && !suggestionModel.updating) {
                update_location(suggestionModel.get(0).name,suggestionModel.get(0).coords)
            }
        }
    }

    FavoriteSheet { id: favorite_sheet }

    ListView {
        id:dummyview
        visible: false
        delegate: Component {
            Text { text: "dummy" }
        }
        model: suggestionModel
        onCountChanged: { updateTimer.start() }
    }

    function getCoords() {
        if(destination_coords != '') {
            return { "name":text, "coords":destination_coords }
        }
        else if(textfield.acceptableInput) {
            return { "name":suggestionModel.get(0).displayname, "coords":suggestionModel.get(0).coords}
        }
        else
            console.log("no acceptable input")
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: platformWindow.active
    }

    ListModel {
        id: suggestionModel
        property bool updating : false
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
            update_location(suggestionModel.get(selectedIndex).name,suggestionModel.get(selectedIndex).coords)
        }
        onRejected: {}
    }

    SelectionDialog {
        id: favoriteQuery
        model: favoritesModel
        delegate: FavoritesDelegate {}
        titleText: qsTr("Choose location")

        onAccepted: {
            if(selectedIndex == 0) {
                if(positionSource.position.latitudeValid && positionSource.position.longitudeValid) {
                    Reittiopas.location_to_address(positionSource.position.coordinate.latitude.toString(),
                                                   positionSource.position.coordinate.longitude.toString(),suggestionModel)
                }
                else {
                    favoriteQuery.selectedIndex = -1
                    appWindow.banner.success = false
                    appWindow.banner.text = qsTr("Position not yet available")
                    appWindow.banner.show()
                }
            } else {
                update_location(favoritesModel.get(selectedIndex).modelData, favoritesModel.get(selectedIndex).coord)
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
                Reittiopas.address_to_location(textfield.text,suggestionModel)
            }
        }
    }

    Item {
        id: labelContainer
        anchors.top: parent.top
        anchors.rightMargin: 5
        height: label.height
        width: label.width + count.width
        BorderImage {
            anchors.fill: parent
            visible: labelMouseArea.pressed
            source: '../../images/background.png'
        }
        Text {
            id: label
            font.pixelSize: MyConstants.FONT_XXLARGE
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            anchors.left: parent.left
            anchors.top: parent.top
        }

        CountBubble {
            id: count
            largeSized: true
            value: suggestionModel.count
            visible: (suggestionModel.count > 1)
            anchors.left: label.right
            anchors.bottom: label.bottom
        }

        BusyIndicator {
            id: busyIndicator
            visible: suggestionModel.updating
            running: suggestionModel.updating
            anchors.left: label.right
            anchors.verticalCenter: label.verticalCenter
            platformStyle: BusyIndicatorStyle { size: 'medium' }
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
        TextField {
            id: textfield
            property bool auto_update : false
            anchors.left: parent.left
            anchors.right: disable_favorites ? parent.right : favoritePicker.left
            placeholderText: qsTr("Type a location")
            validator: RegExpValidator { regExp: /^.{3,50}$/ }
            inputMethodHints: Qt.ImhNoPredictiveText
            platformStyle: TextFieldStyle {
                paddingLeft: 45
            }

            onTextChanged: {
                if(auto_update)
                    auto_update = false
                else {
                    suggestionModel.clear()
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
                source: '../../images/clear.png'
                visible: ((textfield.activeFocus) && !busyIndicator.running)
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
                        !theme.inverted?'../../images/favorite-unmark.png':'../../images/favorite-unmark-inverse.png' :
                        !theme.inverted?'../../images/favorite-mark.png':'../../images/favorite-mark-inverse.png'
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            mouseArea.onClicked: {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                favoritesModel.insert(0, {modelData: qsTr("Current position"),coord:"0,0"})
                favoriteQuery.open()
            }
            mouseArea.onPressAndHold: {
                if(destination_coords) {
                    favorite_sheet.coords = destination_coords
                    favorite_sheet.text = textfield.text
                    favorite_sheet.open()
                }
            }
        }
    }
}
