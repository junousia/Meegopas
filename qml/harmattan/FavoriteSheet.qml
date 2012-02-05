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
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "favorites.js" as Favorites

Sheet {
    visualParent: pageStack

    acceptButtonText: qsTr("Save")
    rejectButtonText: qsTr("Cancel")

    property alias text : sheetTextfield.text
    property string coords
    property bool is_add_favorites : false

    content: Item {
         anchors.fill: parent
         anchors.margins: UIConstants.DEFAULT_MARGIN

         Column {
             width: parent.width
             Header {
                 text: qsTr("Add to favorites")
             }

             Spacing {}

             Text {
                 text: qsTr("Enter name")
                 font.pixelSize: UIConstants.FONT_XXLARGE
                 color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
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
                     sheetTextfield.platformCloseSoftwareInputPanel()
                     parent.focus = true
                 }
             }
         }
     }
     onAccepted: {
         if(sheetTextfield.text != '') {
             if(("OK" == Favorites.addFavorite(sheetTextfield.text, coords))) {
                 favoritesModel.clear()
                 Favorites.getFavorites(favoritesModel)
                 sheetTextfield.text = ''

                 if(is_add_favorites)
                     favorites_page.textfield.clear()

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
     }
     onRejected: {
         sheetTextfield.text = ''
     }
}
