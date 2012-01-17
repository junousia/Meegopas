import QtQuick 1.1
import "UIConstants.js" as UIConstants

Component {
    id: suggestionDelegate

    Item {
        id: delegateItem
        property bool selected: index == selectedIndex;

        height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.rightMargin: UIConstants.DEFAULT_MARGIN

        MouseArea {
            id: delegateMouseArea
            anchors.fill: parent;
            onPressed: selectedIndex = index;
            onClicked: accept();
        }

        Text {
            id: locName
            elide: Text.ElideRight
            color: UIConstants.COLOR_INVERTED_FOREGROUND
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.left: parent.left
            anchors.right: locType.left
            text: name + " " + housenumber
            font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
        }
        Text {
            id: locType
            width: 75
            elide: Text.ElideRight
            color: UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.right: parent.right
            text: city
            font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
        }
    }
}
