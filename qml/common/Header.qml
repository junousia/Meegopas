import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Item {
    property string text
    property string subtext
    anchors.left: parent.left
    anchors.right: parent.right
    height: headerText.height + headerDivider.height + UIConstants.DEFAULT_MARGIN * 2 + (subheaderText.visible ? subheaderText.height : 0)

    Text {
        id: headerText
        font.pixelSize: UIConstants.FONT_XLARGE
        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
        width: parent.width
        wrapMode: Text.WordWrap
        text: parent.text
    }
    Text {
        id: subheaderText
        anchors.top: headerText.bottom
        width: parent.width
        font.pixelSize: UIConstants.FONT_DEFAULT
        font.family: "Nokia Pure Text Light"
        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
        text: '<i>' + subtext + '</i>'
        wrapMode: Text.WordWrap
        visible: parent.subtext
    }
    Separator {
        id: headerDivider
        anchors.top: subheaderText.visible ? subheaderText.bottom : headerText.bottom
    }
}
