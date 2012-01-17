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
        RotationAnimation { duration: 300; direction: RotationAnimation.Clockwise }
    }
}

