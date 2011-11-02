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
    id: favorites_page
    tools: favoritesTools

    ToolBarLayout {
        id: favoritesTools
        x: 0
        y: 0
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
    }

    property alias textfield : favorite

    Component.onCompleted: {
        favoritesModel.clear()
        Favorites.initialize()
        Favorites.getFavorites(favoritesModel)
    }

    FavoriteSheet { id: sheet }

    ListModel {
        id: favoritesModel
        property bool updating : false
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
            appWindow.banner.show()
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

            LocationEntry { id: favorite; type: qsTr("Add favorite"); disable_favorites: true }

            Button {
                id: addButton
                text: qsTr("Add")
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pointSize: UIConstants.FONT_XXSMALL
                width: 150
                height: 40
                enabled: favorite.destination_coords != ''
                onClicked: {
                    sheet.is_add_favorites = true
                    sheet.text = favorite.getCoords().name
                    sheet.coords = favorite.getCoords().coords
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
                        font.pointSize: UIConstants.FONT_DEFAULT
                        elide: Text.ElideRight
                    }
                    Button {
                        id: remove_button
                        text: qsTr("Remove")
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                        font.pointSize: UIConstants.FONT_XXSMALL
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
                    font.pointSize: UIConstants.FONT_XLARGE
                }
                model: favoritesModel
                delegate: favoritesManageDelegate
            }
        }
    }
}
