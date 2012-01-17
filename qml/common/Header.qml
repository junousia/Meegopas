import QtQuick 1.1
import "UIConstants.js" as UIConstants

Item {
    property string text
    property string subtext
    property bool apptitle : false

    anchors.left: parent.left
    anchors.right: parent.right
    height: headerText.height + headerDivider.height + (subheaderText.visible ? subheaderText.height : UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor) + UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor

    Text {
        id: headerText
        width: parent.width
        font.pixelSize: apptitle?UIConstants.FONT_XLARGE * appWindow.scaling_factor : UIConstants.FONT_XLARGE * appWindow.scaling_factor
        color: apptitle ? !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND : !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
        wrapMode: Text.WordWrap
        text: parent.text
        horizontalAlignment: apptitle ? Text.AlignRight : Text.AlignLeft
    }

    Text {
        id: subheaderText
        anchors.top: headerText.bottom
        width: parent.width
        font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
        text: subtext
        wrapMode: Text.WordWrap
        visible: parent.subtext
    }

    Separator {
        id: headerDivider
        anchors.bottom: parent.bottom
    }
}
