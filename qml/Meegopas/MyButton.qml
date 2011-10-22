import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "MyConstants.js" as MyConstants

Item {
    width: 45
    height: 45
    property alias source : image.source
    property alias mouseArea : mouseArea

    BorderImage {
        anchors.fill: parent
        visible: mouseArea.pressed
        source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
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

