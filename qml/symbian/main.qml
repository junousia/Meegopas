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
import com.nokia.extras 1.1
import "UIConstants.js" as UIConstants

Window {
    id: appWindow
    property alias banner : banner
    property variant scaling_factor : 0.75
    property variant colorscheme : "default"
    Item {
        id: theme
        property bool inverted : true
    }

    InfoBanner {
        id: banner
        property bool success : false
        iconSource: success ? "qrc:/images/banner_green.png":"qrc:/images/banner_red.png"
    }

    StatusBar {
        id: status_bar
        anchors.top: parent.top
        visible: true
        z: -1
        opacity: 0.5
    }

    PageStack {
        id: pageStack
        toolBar: toolBar
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: toolBar.top }
        MouseArea {
            anchors.fill: parent
            enabled: pageStack.busy
        }
    }

    ToolBar {
        id: toolBar
        anchors.bottom: appWindow.bottom
        tools: ToolBarLayout {
            id: commonTools
            ToolButton {
                flat: true
                iconSource: "toolbar-back"
                onClicked: pageStack.pop()
            }
        }
    }

    AboutDialog { id: about }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: qsTr("Manage favorites"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem { text: qsTr("Exception info"); onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
            MenuItem { text: qsTr("About"); onClicked: about.open() }
            MenuItem { text: qsTr("Exit"); onClicked: Qt.quit() }
        }
    }

    Component.onCompleted: {
        pageStack.push(Qt.resolvedUrl("MainPage.qml"))
    }
}
