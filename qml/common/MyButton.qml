import QtQuick 1.1

Item {
    width: 50
    height: 50
    property alias source : image.source
    property alias mouseArea : mouseArea

    BorderImage {
        anchors.fill: parent
        visible: mouseArea.pressed
        source: theme.inverted ? 'qrc:/images/background.png': 'qrc:/images/background.png'
    }

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: parent.enabled ? 0.8 : 0.3
        smooth: true
        height: 50
        width: height
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

