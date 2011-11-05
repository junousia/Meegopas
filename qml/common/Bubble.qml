import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Rectangle {
    height: 30
    width: count_label.width + 10
    radius: 10
    smooth: true
    color: "#4466ff"
    property int count
    Text {
        id: count_label
        text: count
        font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
        color: UIConstants.COLOR_INVERTED_FOREGROUND
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
