import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.location 1.1
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/favorites.js" as Favorites

Column {
    property string type : ""
    property variant destination_coords : ''
    property bool destination_valid : (suggestionModel.count > 0)
    property alias model: suggestionModel
    property alias text : textfield.text
    property alias auto_update : textfield.auto_update
    property alias selected_favorite : favoriteQuery.selectedIndex

    height: textfield.height + labelContainer.height
    width: parent.width

    Component.onCompleted: {
        Favorites.initialize()
    }

    function clear() {
        suggestionModel.clear()
        textfield.text = ''
        destination_coords = ''
    }

    Timer {
        id: updateTimer
        repeat: false
        interval: 100
        triggeredOnStart: false
        onTriggered: {
            if(suggestionModel.count == 1 && !suggestionModel.updating) {
                textfield.auto_update = true
                textfield.text = suggestionModel.get(0).name
                destination_coords = suggestionModel.get(0).coords
            }
        }
    }

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
            textfield.auto_update = true
            textfield.text = suggestionModel.get(selectedIndex).name
            destination_coords = suggestionModel.get(selectedIndex).coords
            suggestionModel.clear()
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
                clear()
                Reittiopas.location_to_address(positionSource.position.coordinate.latitude.toString(),
                                               positionSource.position.coordinate.longitude.toString(),suggestionModel)

            } else {
                textfield.auto_update = true
                textfield.text = favoritesModel.get(selectedIndex).name
                destination_coords = favoritesModel.get(selectedIndex).coord
                suggestionModel.clear()
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
        height: 60
        width: label.width + count.width
        BorderImage {
            anchors.fill: parent
            visible: labelMouseArea.pressed
            source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
        }
        Label {
            id: label
            font.pixelSize: MyConstants.FONT_XXLARGE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: UIConstants.DEFAULT_MARGIN
            text: type
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
            anchors.right: favoritePicker.left
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
                        ColorAnimation { to: "green"; duration: 100 }
                    },
                    Transition {
                        ColorAnimation { to: "yellow"; duration: 100 }
                    },
                    Transition {
                        ColorAnimation { to: "red"; duration: 100 }
                    }
                ]
            }
            Image {
                id: clearLocation
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: 'image://theme/icon-m-input-clear'
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
            source: selected_favorite == -1?
                        !theme.inverted?'image://theme/icon-m-common-favorite-unmark':'image://theme/icon-m-common-favorite-unmark-inverse' :
                        !theme.inverted?'image://theme/icon-m-common-favorite-mark':'image://theme/icon-m-common-favorite-mark-inverse'
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            mouseArea.onClicked: {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                favoritesModel.insert(0, {name: qsTr("Current location"),coord:"0,0"})
                favoriteQuery.open()
            }
        }
    }
}
