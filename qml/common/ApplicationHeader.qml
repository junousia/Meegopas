import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "theme.js" as Theme

Rectangle {
    id: header
    property alias title: title.text
    property alias title_color: title.color
    property alias background_color: header.color

    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottomMargin: UIConstants.DEFAULT_MARGIN

    height: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT : UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE
    z: 99
    Text {
        id: title
        color: Theme.theme[appWindow.colorscheme].COLOR_APPHEADER_FOREGROUND
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20
        font.pixelSize: 32 * appWindow.scaling_factor
    }
}
