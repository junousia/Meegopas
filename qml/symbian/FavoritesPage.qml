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
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "favorites.js" as Favorites
import "theme.js" as Theme

Page {
    id: favorites_page
    tools: favoritesTools

    ToolBarLayout {
        id: favoritesTools
        ToolButton { iconSource: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
    }

    FavoriteSheet { id: sheet }

    property alias textfield : favorite

    Component.onCompleted: {
        favoritesModel.clear()
        Favorites.initialize()
        Favorites.getFavorites(favoritesModel)
    }

    ListModel {
        id: favoritesModel
        property bool updating : false
    }

    CommonDialog {
        id: edit_dialog
        property alias name : editTextField.text
        visualParent: pageStack
        titleText:qsTr("Edit favorite name")
        buttonTexts: [qsTr("Save"), qsTr("Cancel")]
        content: Column {
            id: edit_column
            width: parent.width
            spacing: UIConstants.DEFAULT_MARGIN
            TextField {
                id: editTextField
                width: parent.width
                text: edit_dialog.name

                Image {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/clear.png"
                    visible: (editTextField.activeFocus)
                    opacity: 0.8
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            editTextField.text = ''
                        }
                    }
                }

                Keys.onReturnPressed: {
                    editTextField.platformCloseSoftwareInputPanel()
                    parent.focus = true
                }
            }
        }
        onButtonClicked: {
            if(index == 0) {
                if("OK" == Favorites.updateFavorite(edit_dialog.name, favoritesModel.get(list.currentIndex).coord, favoritesModel)) {
                    favoritesModel.clear()
                    Favorites.getFavorites(favoritesModel)

                    appWindow.banner.success = true
                    appWindow.banner.text = qsTr("Favorite name successfully modified")
                    appWindow.banner.open()
                } else {
                    appWindow.banner.success = false
                    appWindow.banner.text = qsTr("Favorite name modification failed")
                    appWindow.banner.open()
                }

                edit_dialog.close()
            }
            else
                edit_dialog.close()
        }
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
        contentHeight: content_column.height

        Component.onCompleted: {
            Favorites.initialize()
        }

        Column {
            id: content_column
            width: parent.width
            spacing: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor

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
                    sheet.name = favorite.getCoords().name
                    sheet.coords = favorite.getCoords().coords
                    sheet.open()
                }
            }

            Separator {}

            Component {
                id: favoritesManageDelegate
                Item {
                    width: parent.width
                    height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor

                    Text {
                        text: modelData
                        anchors.left: parent.left
                        anchors.right: edit_button.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                        font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                        elide: Text.ElideRight
                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize * 1.2
                    }
                    MyButton {
                        id: edit_button
                        source: Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?"image://theme/toolbar-settings":"image://theme/toolbar-settings-inverse"
                        anchors.right: remove_button.left
                        image.height: 35
                        mouseArea.onClicked: {
                            list.currentIndex = index
                            edit_dialog.name = modelData
                            edit_dialog.open()
                        }
                    }
                    MyButton {
                        id: remove_button
                        source: Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?"image://theme/toolbar-delete":"image://theme/toolbar-delete-inverse"
                        anchors.right: parent.right
                        image.height: 35
                        mouseArea.onClicked: {
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
                height: favoritesModel.count * UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor + UIConstants.DEFAULT_MARGIN * 5
                interactive: false
                header: Column {
                    width: parent.width
                    Text {
                        id: header_text
                        text: qsTr("Favorites")
                        font.pixelSize: UIConstants.FONT_XXLARGE * appWindow.scaling_factor
                        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize * 1.1
                    }
                }
                model: favoritesModel
                delegate: favoritesManageDelegate
            }
        }
    }
}
