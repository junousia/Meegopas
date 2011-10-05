import QtQuick 1.1
import com.nokia.meego 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Item {
    property alias text: headerText.text

    anchors.left: parent.left
    anchors.right: parent.right

    height: headerText.height + headerDivider.height + UIConstants.DEFAULT_MARGIN * 2

    Text {
        id: headerText
        font.pixelSize: UIConstants.FONT_XLARGE
        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
        width: parent.width
        wrapMode: Text.WordWrap
    }

    Rectangle {
        id: headerDivider
        anchors.top: headerText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: UIConstants.DEFAULT_MARGIN
        anchors.bottomMargin: UIConstants.DEFAULT_MARGIN
        height: 1
        color: theme.inverted ? ExtrasConstants.LIST_SUBTITLE_COLOR_INVERTED : ExtrasConstants.LIST_SUBTITLE_COLOR
    }
}
