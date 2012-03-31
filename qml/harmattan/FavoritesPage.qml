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
import com.nokia.meego 1.1
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

    FavoriteSheet { id: sheet }

    Component.onCompleted: {
        favoritesModel.clear()
        Favorites.initialize()
        Favorites.getFavorites(favoritesModel)
    }

    ListModel {
        id: favoritesModel
    }

    Dialog {
        id: edit_dialog
        property alias name : editTextField.text
        property string coord
        property string old_name : ""
        title: Text {
                text: qsTr("Edit favorite name")
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignCenter
                elide: Text.ElideNone
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                font.bold: true
                font.family: UIConstants.FONT_FAMILY
                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
            }

        content: TextField {
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
        buttons: Column {
            spacing: UIConstants.DEFAULT_MARGIN
            anchors.horizontalCenter: parent.horizontalCenter
            width: button_save.width

            Spacing {}

            Button {
                id: button_save
                text: qsTr("Save")
                font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scaling_factor
                width: UIConstants.BUTTON_WIDTH * appWindow.scaling_factor
                height: UIConstants.BUTTON_HEIGHT * appWindow.scaling_factor
                onClicked: {
                    if("OK" == Favorites.updateFavorite(edit_dialog.name, favoritesModel.get(list.currentIndex).coord, favoritesModel)) {

                        /* update shortcut, if exists */
                        if(Shortcut.checkIfExists(edit_dialog.old_name)) {
                            Shortcut.removeShortcut(edit_dialog.old_name)
                            Shortcut.toggleShortcut(edit_dialog.name,favoritesModel.get(list.currentIndex).coord)
                        }

                        favoritesModel.clear()
                        Favorites.getFavorites(favoritesModel)

                        appWindow.banner.success = true
                        appWindow.banner.text = qsTr("Favorite name successfully modified")
                        appWindow.banner.show()
                    } else {
                        appWindow.banner.success = false
                        appWindow.banner.text = qsTr("Favorite name modification failed")
                        appWindow.banner.show()
                    }

                    edit_dialog.close()
                }
            }
            Button {
                id: button_cancel
                text: qsTr("Cancel")
                font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scaling_factor
                width: UIConstants.BUTTON_WIDTH * appWindow.scaling_factor
                height: UIConstants.BUTTON_HEIGHT * appWindow.scaling_factor
                onClicked: edit_dialog.close()
            }
        }
    }
    Dialog {
        id: delete_dialog
        property string name
        title: Text {
            text: qsTr("Delete favorite?")
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Qt.AlignCenter
            elide: Text.ElideNone
            font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
            font.bold: true
            font.family: UIConstants.FONT_FAMILY
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
        }

        content: Text {
            text: delete_dialog.name
            anchors.centerIn: parent
            anchors.bottomMargin: UIConstants.DEFAULT_MARGIN
            color: UIConstants.COLOR_INVERTED_FOREGROUND
            font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
            elide: Text.ElideRight
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.2
        }
        buttons: Column {
            spacing: UIConstants.DEFAULT_MARGIN
            anchors.horizontalCenter: parent.horizontalCenter
            width: button_save.width

            Spacing {}

            Button {
                id: delete_ok
                text: qsTr("Delete")
                font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scaling_factor
                width: UIConstants.BUTTON_WIDTH * appWindow.scaling_factor
                height: UIConstants.BUTTON_HEIGHT * appWindow.scaling_factor
                onClicked: {
                    Favorites.deleteFavorite(favoritesModel.get(list.currentIndex).coord, favoritesModel)
                    appWindow.banner.success = true
                    appWindow.banner.text = qsTr("Favorite removed")
                    appWindow.banner.show()
                    Shortcut.removeShortcut(delete_dialog.name)
                    delete_dialog.close()
                }
            }
            Button {
                id: delete_cancel
                text: qsTr("Cancel")
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                width: UIConstants.BUTTON_WIDTH * appWindow.scaling_factor
                height: UIConstants.BUTTON_HEIGHT * appWindow.scaling_factor
                onClicked: delete_dialog.close()
            }
        }
    }
    Dialog {
        id: add_dialog
        property string name : ''
        property string coord : ''
        content: LocationEntry {
                id: entry
                anchors.bottomMargin: UIConstants.DEFAULT_MARGIN
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                font.bold: true
                font.family: UIConstants.FONT_FAMILY
                lineHeightMode: Text.FixedHeight
                lineHeight: font.pixelSize * 1.5
                label.anchors.horizontalCenter: entry.horizontalCenter
                type: qsTr("Search for location")
                disable_favorites: true
                onLocationDone: {
                    add_dialog.name = name
                    add_dialog.coord = coord
                }
            }
        buttons: Column {
            spacing: UIConstants.DEFAULT_MARGIN
            anchors.horizontalCenter: parent.horizontalCenter
            width: button_save.width

            Spacing {}

            Button {
                text: qsTr("Next")
                enabled: add_dialog.coord != ''
                font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scaling_factor
                width: UIConstants.BUTTON_WIDTH * appWindow.scaling_factor
                height: UIConstants.BUTTON_HEIGHT * appWindow.scaling_factor
                onClicked: {
                    sheet.name = add_dialog.name
                    sheet.coord = add_dialog.coord
                    sheet.open()
                    add_dialog.close()
                    entry.clear()
                }
            }
            Button {
                text: qsTr("Cancel")
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                width: UIConstants.BUTTON_WIDTH * appWindow.scaling_factor
                height: UIConstants.BUTTON_HEIGHT * appWindow.scaling_factor
                onClicked: {
                    add_dialog.close()
                    entry.clear()
                }
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    Flickable {
        interactive: favoritesModel.count

        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
            fill: parent
        }
        flickableDirection: Flickable.VerticalFlick
        contentHeight: content_column.height + UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor

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

            Button {
                width: parent.width
                text: qsTr("Add favorite")
                onClicked: {
                    add_dialog.open()
                }
            }

            Component {
                id: favoritesManageDelegate
                Item {
                    width: parent.width
                    height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor

                    Text {
                        text: modelData
                        anchors.left: parent.left
                        anchors.right: shortcut_button.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                        font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                        elide: Text.ElideRight
                        lineHeightMode: Text.FixedHeight
                        lineHeight: font.pixelSize * 1.2
                    }
                    MyButton {
                        id: shortcut_button
                        property bool toggled : false
                        imageSize: 40
                        Component.onCompleted: {
                            toggled = Shortcut.checkIfExists(modelData)
                        }
                        anchors.right: edit_button.left
                        source: toggled?
                                    Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?'qrc:/images/favorite-mark-inverse.png':'qrc:/images/favorite-mark.png' :
                                    Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?'qrc:/images/favorite-unmark-inverse.png':'qrc:/images/favorite-unmark.png'
                        mouseArea.onClicked: {
                            Shortcut.toggleShortcut(modelData, coord)
                            toggled = toggled ? false : true
                            if(toggled) {
                                appWindow.banner.success = true
                                appWindow.banner.text = qsTr("Favorite added to application menu")
                                appWindow.banner.show()
                            } else {
                                appWindow.banner.success = false
                                appWindow.banner.text = qsTr("Favorite removed from application menu")
                                appWindow.banner.show()
                            }
                        }
                    }

                    MyButton {
                        id: edit_button
                        source: Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?'image://theme/icon-m-toolbar-edit-white':'image://theme/icon-m-toolbar-edit'
                        anchors.right: remove_button.left
                        mouseArea.onClicked: {
                            list.currentIndex = index
                            edit_dialog.name = modelData
                            edit_dialog.old_name = modelData
                            edit_dialog.coord = coord
                            edit_dialog.open()
                        }
                    }
                    MyButton {
                        id: remove_button
                        source: Theme.theme[appWindow.colorscheme].BUTTONS_INVERTED?'image://theme/icon-m-toolbar-delete-white':'image://theme/icon-m-toolbar-delete'
                        anchors.right: parent.right
                        mouseArea.onClicked: {
                            list.currentIndex = index
                            delete_dialog.name = modelData
                            delete_dialog.open()
                        }
                    }
                }
            }

            ListView {
                id: list
                width: parent.width
                height: favoritesModel.count * UIConstants.LIST_ITEM_HEIGHT_SMALL + UIConstants.DEFAULT_MARGIN * 3
                interactive: false
                model: favoritesModel
                delegate: favoritesManageDelegate
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: favoritesModel.count == 0
        width: parent.width
        text: qsTr("No saved favorites")
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
    }
}
