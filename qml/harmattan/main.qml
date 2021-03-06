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
import "storage.js" as Storage

PageStackWindow {
    id: appWindow
    initialPage: MainPage {}

    signal followModeEnabled

    showStatusBar: appWindow.inPortrait

    property alias about : aboutLoader.item
    property alias menu : menuLoader.item
    property alias banner : banner
    property variant scalingFactor : 1
    property bool positioningActive : (platformWindow.active && gpsEnabled)
    property bool followMode : false
    property bool mapVisible : false
    property bool showStationCode : true
    property string colorscheme : "default"
    property bool gpsEnabled : false
    property string region

    platformStyle: PageStackWindowStyle {
        id: defaultStyle
    }

    onFollowModeChanged: {
        if(followMode)
            followModeEnabled()
    }

    Component {
        id: aboutComponent
            AboutDialog { id: about }
    }

    InfoBanner {
        id: banner
        property bool success : false
        y: 40
        iconSource: success ? 'qrc:/images/banner_green.png':'qrc:/images/banner_red.png'
    }

    Component {
        id: menuComponent
        Menu {
            visualParent: pageStack
            MenuLayout {
                MenuItem { text: qsTr("Settings"); onClicked: { mapVisible = false; pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
                MenuItem { text: qsTr("Manage favorites"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
                MenuItem { text: qsTr("Exception info"); onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
                MenuItem { text: qsTr("About"); onClicked: about.open() }
            }
        }
    }

    Loader {
        id: menuLoader
        anchors.fill: parent
        sourceComponent: menuComponent
    }
    Loader {
        id: aboutLoader
        anchors.fill: parent
        sourceComponent: aboutComponent
    }

}
