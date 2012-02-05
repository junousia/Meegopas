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

Page {
    tools: disruptionTools

    Component.onCompleted: {
        disruptionModel.reload()
    }
    ToolBarLayout {
        id: disruptionTools
        visible: false
        ToolButton { iconSource: "toolbar-back"; onClicked: { pageStack.pop(); } }
        ToolButton {
            text: qsTr("Update")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { disruptionModel.reload() }
        }
    }
    XmlListModel {
        id: disruptionModel
        source: "http://www.poikkeusinfo.fi/xml/v2"
        query: "/DISRUPTIONS/DISRUPTION"
        XmlRole { name: "time"; query: "VALIDITY/@from/string()" }
        XmlRole { name: "info_fi"; query: "INFO/TEXT[1]/string()" }
        XmlRole { name: "info_sv"; query: "INFO/TEXT[2]/string()" }
        XmlRole { name: "info_en"; query: "INFO/TEXT[3]/string()" }
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: disruptionModel
        delegate: ExceptionDelegate {}

        header: Header {
            text: qsTr("Traffic exception info")
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: list
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && disruptionModel.count == 0)
        width: parent.width
        text: qsTr("No current traffic exceptions")
        wrapMode: Text.WordWrap
        horizontalAlignment: Qt.AlignHCenter
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scaling_factor
        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
    }

    BusyIndicator {
        id: busyIndicator
        visible: (disruptionModel.status != XmlListModel.Ready)
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
