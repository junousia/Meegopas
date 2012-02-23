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
import "storage.js" as Storage
import "theme.js" as Theme

Page {
    tools: commonTools
    property variant search_parameters : 0

    onStatusChanged: {
        if(status == Component.Ready && !routeModel.count)
            Reittiopas.new_route_instance(search_parameters, routeModel)
    }

    ListModel {
        id: routeModel
        property bool done : false
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: routeModel
        delegate: ResultDelegate {}

        header: Header {
            text: search_parameters.from_name + " - " + search_parameters.to_name
            subtext: search_parameters.timetype == "departure"?
                         qsTr("Departure time ") + Qt.formatDateTime(search_parameters.time,"dd.MM.yyyy hh:mm") :
                         qsTr("Arrival time ") + Qt.formatDateTime(search_parameters.time,"dd.MM.yyyy hh:mm")
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: list
        platformStyle: ScrollDecoratorStyle {}
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && routeModel.count == 0)
        width: parent.width
        text: qsTr("No results")
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.done)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
