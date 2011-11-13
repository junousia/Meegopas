import QtQuick 1.1
import com.nokia.symbian 1.1
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
        ToolButton { iconSource: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
    }

    Component.onCompleted: {
        favoritesModel.clear()
        Favorites.initialize()
        Favorites.getFavorites(favoritesModel)
    }

    ListModel {
        id: favoritesModel
        property bool updating : false
    }

    Dialog {
        id: sheet
        property string coords
        property string text
        title: qsTr("Add favorite")
        onFocusChanged: sheetTextfield.focus = true
        onAccepted: {
            if(("OK" == Favorites.addFavorite(sheetTextfield.text, coords))) {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                sheetTextfield.text = ''

                appWindow.banner.success = true
                appWindow.banner.text = qsTr("Location added to favorites")
                appWindow.banner.open()
            } else {
                appWindow.banner.success = false
                appWindow.banner.text = qsTr("Location already in the favorites")
                appWindow.banner.open()
            }
        }
        onRejected: {

        }

        buttons: [
            Row {
                anchors.margins: UIConstants.DEFAULT_MARGIN
                spacing: UIConstants.DEFAULT_MARGIN
                anchors.horizontalCenter: parent.horizontalCenter
                ToolButton {
                    text: qsTr("Save")
                    onClicked: sheet.accept()
                }
                ToolButton {
                    text: qsTr("Cancel")
                    onClicked: sheet.reject()
                }
            }
        ]
        content:[
            Column {
                height: 125
                width: parent.width
                anchors.margins: UIConstants.DEFAULT_MARGIN
                spacing: UIConstants.DEFAULT_MARGIN
                Text {
                    text: qsTr("Enter name")
                    font.pixelSize: MyConstants.FONT_XXLARGE * appWindow.scaling_factor
                    color: UIConstants.COLOR_INVERTED_FOREGROUND
                    anchors.left: parent.left
                }
                TextField {
                    id: sheetTextfield
                    width: parent.width
                    Image {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        source: '../../images/clear.png'
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
                        sheetTextfield.platformCloseSoftwareInputPanel()
                        parent.focus = true
                    }
                }
            }
        ]
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
            appWindow.banner.success = true
            appWindow.banner.text = qsTr("Favorite removed")
            appWindow.banner.open()
        }
    }

    Flickable {
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
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

            LocationEntry { id: favorite; type: qsTr("Add favorite"); disable_favorites: true }

            Button {
                id: addButton
                text: qsTr("Add")
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                width: 150 * appWindow.scaling_factor
                height: 40
                enabled: favorite.destination_coords != ''
                onClicked: {
                    sheet.text = favorite.getCoords().name
                    sheet.coords = favorite.getCoords().coords
                    sheet.open()
                }
            }

            Separator {}

            ListView {
                id: list
                width: parent.width
                height: favoritesModel.count * UIConstants.LIST_ITEM_HEIGHT_SMALL + UIConstants.DEFAULT_MARGIN * 3
                interactive: false
                header: Text {
                    id: favoritesLabel
                    text: qsTr("Favorites")
                    font.pixelSize: MyConstants.FONT_XXLARGE * appWindow.scaling_factor
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                }
                model: favoritesModel
                delegate: FavoritesManageDelegate {}
            }
        }
    }
}
