import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "theme.js" as Theme

Item {
    property alias text : header.text
    height: header.height
    anchors.margins: UIConstants.DEFAULT_MARGIN/2
    width: parent.width

    Rectangle {
        height: 1
        anchors.left: parent.left
        anchors.right: header.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: UIConstants.DEFAULT_MARGIN / 2
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
    }

    Text {
        id: header
        font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        lineHeightMode: Text.FixedHeight
        lineHeight: font.pixelSize * 1.2
    }
}
