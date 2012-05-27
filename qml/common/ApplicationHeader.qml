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

    height: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT * appWindow.scaling_factor:
                                  UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE * appWindow.scaling_factor
    z: 10
    Text {
        id: title
        color: Theme.theme[appWindow.colorscheme].COLOR_APPHEADER_FOREGROUND
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.bottomMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_PORTRAIT * appWindow.scaling_factor:
                                                    UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE * appWindow.scaling_factor
        anchors.topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT * appWindow.scaling_factor:
                                                 UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE * appWindow.scaling_factor
        font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
    }
}
