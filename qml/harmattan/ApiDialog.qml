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
import "storage.js" as Storage

SelectionDialog {
    id: apiDialog
    visualParent: pageStack
    titleText: qsTr("Choose region")

    signal configurationChanged

    model: ListModel {
        ListElement { name: "Helsinki" }
        ListElement { name: "Tampere" }
    }

    onAccepted: {
        Storage.setSetting('api', apiDialog.selectedIndex == 0? "helsinki" : "tampere")
        configurationChanged()
    }
    onRejected: {
        Storage.setSetting('api', apiDialog.selectedIndex == 0? "helsinki" : "tampere")
        configurationChanged()
    }
}
