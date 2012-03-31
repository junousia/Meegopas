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

CommonDialog {
    id: add_dialog
    property alias name : addTextField.text
    property string coord : ""

    visualParent: pageStack
    titleText:qsTr("Enter favorite name")
    buttonTexts: [qsTr("Add"), qsTr("Cancel")]
    content: Column {
        id: edit_column
        width: parent.width
        spacing: UIConstants.DEFAULT_MARGIN

        Spacing { height: UIConstants.DEFAULT_MARGIN/2 }

        TextField {
            id: addTextField
            width: parent.width
            text: add_dialog.name

            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/images/clear.png"
                visible: (addTextField.activeFocus)
                opacity: 0.8
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        addTextField.text = ''
                    }
                }
            }

            Keys.onReturnPressed: {
                addTextField.platformCloseSoftwareInputPanel()
                parent.focus = true
            }
        }
    }
    onButtonClicked: {
        if(index == 0) {
            if(add_dialog.name != '') {
                if(("OK" == Favorites.addFavorite(add_dialog.name, coord))) {
                    favoritesModel.clear()
                    Favorites.getFavorites(favoritesModel)
                    add_dialog.name = ''

                    appWindow.banner.success = true
                    appWindow.banner.text = qsTr("Location added to favorites")
                    appWindow.banner.open()
                } else {
                    appWindow.banner.success = false
                    appWindow.banner.text = qsTr("Location already in the favorites")
                    appWindow.banner.open()
                }
            }
            else {
                appWindow.banner.success = false
                appWindow.banner.text = qsTr("Name cannot be empty")
                appWindow.banner.open()
            }
            add_dialog.close()
        }
        else
            add_dialog.close()
    }
}
