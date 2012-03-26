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
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "favorites.js" as Favorites
import "theme.js" as Theme

Dialog {
    id: add_dialog
    property alias name : editTextField.text
    property string coords : ""

    title: Column {
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            text: qsTr("Enter name for the favorite")
            font.pixelSize: UIConstants.FONT_XLARGE
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Qt.AlignCenter
            elide: Text.ElideNone
            font.bold: true
            font.family: UIConstants.FONT_FAMILY
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
        }
        Spacing { }
    }

    content: Item {
        width: parent.width
        height: edit_column.height + UIConstants.DEFAULT_MARGIN * 2
        Column {
            id: edit_column
            width: parent.width
            spacing: UIConstants.DEFAULT_MARGIN
            TextField {
                id: editTextField
                width: parent.width
                text: add_dialog.name

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
    }
    buttons: Column {
        spacing: UIConstants.DEFAULT_MARGIN
        anchors.horizontalCenter: parent.horizontalCenter
        width: button_save.width
        Button {
            id: button_save
            text: qsTr("Add")
            font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scaling_factor
            width: UIConstants.BUTTON_WIDTH
            height: UIConstants.BUTTON_HEIGHT
            onClicked: {
                if(add_dialog.name != '') {
                    if(("OK" == Favorites.addFavorite(add_dialog.name, coords))) {
                        favoritesModel.clear()
                        Favorites.getFavorites(favoritesModel)
                        add_dialog.name = ''

                        appWindow.banner.success = true
                        appWindow.banner.text = qsTr("Location added to favorites")
                        appWindow.banner.show()
                    } else {
                        appWindow.banner.success = false
                        appWindow.banner.text = qsTr("Location already in the favorites")
                        appWindow.banner.show()
                    }
                }
                else {
                    appWindow.banner.success = false
                    appWindow.banner.text = qsTr("Name cannot be empty")
                    appWindow.banner.show()
                }
                add_dialog.close()
            }
        }
        Button {
            id: button_cancel
            text: qsTr("Cancel")
            font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scaling_factor
            width: UIConstants.BUTTON_WIDTH
            height: UIConstants.BUTTON_HEIGHT
            onClicked: add_dialog.close()
        }
    }
}
