import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "MyConstants.js" as MyConstants
import "reittiopas.js" as Reittiopas
import "favorites.js" as Favorites

Page {
    tools: favoritesTools

    // lock to portrait
    orientationLock: PageOrientation.LockPortrait

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

        content: Flickable {
             anchors.fill: parent
             flickableDirection: Flickable.VerticalFlick
             Column {
                 anchors.top: parent.top
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
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN
        }
        flickableDirection: Flickable.VerticalFlick

        Component.onCompleted: {
            Favorites.initialize()
        }

        Column {
            width: parent.width
            Header {
                text: qsTr("Manage favorites")
            }

            Item {
                id: labelContainer
                height: 60
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
                    anchors.top: parent.top
                    anchors.topMargin: UIConstants.DEFAULT_MARGIN
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
            Row {
                id: textrow
                width: parent.width
                height: textfield.height + UIConstants.DEFAULT_MARGIN

                TextField {
                    id: textfield
                    property bool auto_update : false
                    anchors.left: parent.left
                    anchors.right: addButton.left
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

                MyButton {
                    id: addButton
                    source: !theme.inverted?'image://theme/icon-s-common-add':'image://theme/icon-s-common-add-inverse'
                    anchors.right: parent.right
                    enabled: destCoords != ''
                    mouseArea.onClicked: {
                        sheet.text = textfield.text
                        sheet.open()
                    }
                }
            }

            Separator {}

            Label {
                id: favoritesLabel
                anchors.left: parent.left
                anchors.top: textrow.bottom
                anchors.topMargin: UIConstants.DEFAULT_MARGIN
                text: qsTr("Favorites")
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: MyConstants.FONT_XXLARGE
            }

            Component {
                id: favoritesManageDelegate
                Item {
                    width: parent.width
                    height: 50

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: name
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                            font.pixelSize: UIConstants.FONT_XLARGE
                        }
                        Item {
                            id: removeIcon
                            width: 50
                            height: 50
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            BorderImage {
                                anchors.fill: parent
                                visible: mouseArea.pressed
                                source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                onClicked: {
                                    list.currentIndex = index
                                    deleteQuery.name = name
                                    deleteQuery.open()
                                }
                            }

                            Image {
                                source: !theme.inverted?'image://theme/icon-s-common-remove':'image://theme/icon-s-common-remove-inverse'
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            ListView {
                id: list
                width: parent.width
                height: parent.height
                anchors.top: favoritesLabel.bottom
                interactive: false
                model: favoritesModel
                delegate: favoritesManageDelegate
            }
        }
    }
}
