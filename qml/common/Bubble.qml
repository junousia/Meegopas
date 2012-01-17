import QtQuick 1.1
import "UIConstants.js" as UIConstants

Rectangle {
    height: 35
    width: count_label.width + 15
    radius: 12
    smooth: true
    color: "#0d67b3"
    property int count
    Text {
        id: count_label
        text: count
        font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
        color: UIConstants.COLOR_INVERTED_FOREGROUND
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
