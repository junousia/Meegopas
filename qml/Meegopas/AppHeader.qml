import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Rectangle {
    color: "#0000ff"
    height: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_HEIGHT_PORTRAIT : UIConstants.HEADER_DEFAULT_HEIGHT_LANDSCAPE
    Text {
        text: "Meegopas"
        font.pixelSize: UIConstants.FONT_XLARGE
        font.family: UIConstants.FONT_FAMILY
        color: UIConstants.COLOR_FOREGROUND
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.bottomMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
        anchors.topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
    }
}
