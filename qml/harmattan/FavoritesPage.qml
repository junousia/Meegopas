import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/favorites.js" as Favorites

Page {
    tools: favoritesTools

    ToolBarLayout {
        id: favoritesTools
        x: 0
        y: 0
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
    }
    property alias auto_update : textfield.auto_update
    property variant destCoords : ''
    property bool destValid : (suggestionModel.count > 0)

    Component.onCompleted: {
        favoritesModel.clear()
        Favorites.initialize()
        Favorites.getFavorites(favoritesModel)
    }

    function clear() {
        suggestionModel.clear()
        textfield.text = ''
        destCoords = ''
    }

    QueryDialog {
        id: deleteQuery
        property string name
        titleText: qsTr("Delete favorite?")
        message: name

        rejectButtonText: qsTr("Cancel")
        acceptButtonText: qsTr("Delete")
        onAccepted: {
            Favorites.deleteFavorite(favoritesModel.get(list.currentIndex).coord, favoritesModel)
        }
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
                destCoords = suggestionModel.get(0).coords
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
            textfield.auto_update = true
            textfield.text = suggestionModel.get(selectedIndex).name
            destCoords = suggestionModel.get(selectedIndex).coords
            suggestionModel.clear()
            favoritesModel.clear()
            Favorites.getFavorites(favoritesModel)
        }
        onRejected: {
            destCoords = ''
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

    ListModel {
        id: suggestionModel
        property bool updating : false
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

    Sheet {
        id: sheet
        visualParent: pageStack

        acceptButtonText: qsTr("Save")
        rejectButtonText: qsTr("Cancel")

        property alias text : sheetTextfield.text

        content: Item {
             anchors.fill: parent
             anchors.margins: UIConstants.DEFAULT_MARGIN

             Column {
                 width: parent.width

                 Label {
                     text: qsTr("Enter name")
                     font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                     font.pixelSize: MyConstants.FONT_XXLARGE
                     anchors.left: parent.left
                 }
                 TextField {
                     id: sheetTextfield
                     width: parent.width

                     Image {
                         anchors.right: parent.right
                         anchors.verticalCenter: parent.verticalCenter
                         source: 'image://theme/icon-m-input-clear'
                         visible: (sheetTextfield.activeFocus)
                         opacity: 0.8
                         MouseArea {
                             anchors.fill: parent
                             onClicked: {
                                 sheetTextfield.text = ''
                             }
                         }
                     }

                     Keys.onReturnPressed: {
                         textfield.platformCloseSoftwareInputPanel()
                         parent.focus = true
                     }
                 }
             }
         }
         onAccepted: {
             Favorites.addFavorite(sheetTextfield.text, destCoords)
             console.log("added " + sheetTextfield.text + " " + destCoords + " to the favorites")
             favoritesModel.clear()
             Favorites.getFavorites(favoritesModel)
             sheetTextfield.text = ''
             clear()
         }
         onRejected: {
             sheetTextfield.text = ''
         }
    }

    Flickable {
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN
            fill: parent
        }
        flickableDirection: Flickable.VerticalFlick
        contentHeight: content_column.height + UIConstants.DEFAULT_MARGIN

        Component.onCompleted: {
            Favorites.initialize()
        }

        Column {
            id: content_column
            width: parent.width
            spacing: UIConstants.DEFAULT_MARGIN
            Header {
                text: qsTr("Manage favorites")
            }
            Column {
                width: parent.width
                Item {
                    id: labelContainer
                    height: 50
                    width: parent.width

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
                        anchors.bottom: parent.bottom
                        text: qsTr("Add favorite")
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
                TextField {
                    id: textfield
                    property bool auto_update : false
                    width: parent.width
                    height: 50
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
                        state: destCoords?"validated":suggestionModel.count > 0? "sufficient":"error"
                        opacity: 0.8

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
            }

            Button {
                id: addButton
                text: qsTr("Add")
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_SMALL
                width: 150
                height: 40
                enabled: destCoords != ''
                onClicked: {
                    sheet.text = textfield.text
                    sheet.open()
                }
            }

            Separator {}

            Component {
                id: favoritesManageDelegate
                Item {
                    width: parent.width
                    height: UIConstants.LIST_ITEM_HEIGHT_SMALL

                    Text {
                        text: name
                        anchors.left: parent.left
                        anchors.right: remove_button.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                        font.pixelSize: UIConstants.FONT_XLARGE
                        elide: Text.ElideRight
                    }
                    Button {
                        id: remove_button
                        text: qsTr("Remove")
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                        font.pixelSize: UIConstants.FONT_SMALL
                        width: 150
                        height: 40
                        onClicked: {
                            list.currentIndex = index
                            deleteQuery.name = name
                            deleteQuery.open()
                        }
                    }
                }
            }

            ListView {
                id: list
                width: parent.width
                height: favoritesModel.count * UIConstants.LIST_ITEM_HEIGHT_SMALL + UIConstants.DEFAULT_MARGIN * 3
                interactive: false
                header: Label {
                    id: favoritesLabel
                    text: qsTr("Favorites")
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    font.pixelSize: MyConstants.FONT_XXLARGE
                }
                model: favoritesModel
                delegate: favoritesManageDelegate
            }
        }
    }
}
