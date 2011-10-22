import QtQuick 1.1
import "UIConstants.js" as UIConstants

Rectangle {
    width: parent.width - 2 * UIConstants.DEFAULT_MARGIN
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.margins: UIConstants.DEFAULT_MARGIN
    height: 1
    color: "gray"
}
