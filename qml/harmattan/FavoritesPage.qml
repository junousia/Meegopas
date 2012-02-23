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
import "favorites.js" as Favorites
import "theme.js" as Theme

Page {
    id: favorites_page
    tools: favoritesTools

    ToolBarLayout {
        id: favoritesTools
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

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
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
                font.pixelSize: UIConstants.FONT_SMALL  * appWindow.scaling_factor
                width: 150 * appWindow.scaling_factor
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
                        text: modelData
                        anchors.left: parent.left
                        anchors.right: remove_button.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                        font.pixelSize: UIConstants.FONT_XLARGE
                        elide: Text.ElideRight
                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize * 1.2
                    }
                    Button {
                        id: remove_button
                        text: qsTr("Remove")
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: UIConstants.FONT_SMALL
                        width: 150
                        height: 40
                        onClicked: {
                            list.currentIndex = index
                            deleteQuery.name = modelData
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
                header: Text {
                    text: qsTr("Favorites")
                    font.pixelSize: UIConstants.FONT_XXLARGE * appWindow.scaling_factor
                    color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                    lineHeightMode: Text.FixedHeight
                    lineHeight: font.pixelSize * 1.1
                }
                model: favoritesModel
                delegate: favoritesManageDelegate
            }
        }
    }
}
