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
import "helper.js" as Helper

Item {
    id: locationSwitch
    state: "normal"
    anchors.right: parent.right
    anchors.top: from.bottom
    width: 50
    height: 50

    property variant from
    property variant to

    BorderImage {
        anchors.fill: parent
        visible: locationSwitchMouseArea.pressed
        source: theme.inverted ? 'qrc:/images/background.png': 'qrc:/images/background.png'
    }

    Image {
        anchors.centerIn: parent
        source: !theme.inverted?'qrc:/images/switch.png':'qrc:/images/switch-inverse.png'
        opacity: locationSwitch.enabled ? 0.8 : 0.3
        smooth: true
        height: 50
        width: height
    }
    MouseArea {
        id: locationSwitchMouseArea
        anchors.fill: parent

        onClicked: {
            Helper.switch_locations(from,to)
            locationSwitch.state = locationSwitch.state == "normal" ? "rotated" : "normal"
        }
    }
    states: [
        State {
            name: "rotated"
            PropertyChanges { target: locationSwitch; rotation: 180 }
        },
        State {
            name: "normal"
            PropertyChanges { target: locationSwitch; rotation: 0 }
        }
    ]
    transitions: Transition {
        RotationAnimation { duration: 500; direction: RotationAnimation.Clockwise; easing.type: Easing.InOutCubic }
    }
}

