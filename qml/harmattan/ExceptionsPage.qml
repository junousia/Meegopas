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
import "theme.js" as Theme

Page {
    tools: exceptionTools

    Component.onCompleted: {
        exceptionModel.reload()
    }
    ToolBarLayout {
        id: exceptionTools
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
        ToolButton {
            text: qsTr("Update")
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: { exceptionModel.reload() }
        }
        ToolIcon { visible: false }
    }
    XmlListModel {
        id: exceptionModel
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
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scalingFactor
        model: exceptionModel
        delegate: ExceptionDelegate {}

        header: Header {
            text: qsTr("Traffic exception info")
        }
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && exceptionModel.count == 0)
        width: parent.width
        text: qsTr("No current traffic exceptions")
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scalingFactor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }

    BusyIndicator {
        id: busyIndicator
        visible: (exceptionModel.status != XmlListModel.Ready)
        running: true
        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: 'large' }
    }
}
