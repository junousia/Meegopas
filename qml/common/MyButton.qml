import QtQuick 1.1

Item {
    width: 45
    height: 45
    property alias source : image.source
    property alias mouseArea : mouseArea

    BorderImage {
        anchors.fill: parent
        visible: mouseArea.pressed
        source: theme.inverted ? '../../images/background.png': '../../images/background.png'
    }

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: parent.enabled ? 0.8 : 0.3
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

