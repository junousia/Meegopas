import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Component {
    id: favoritesDelegate

    Item {
        id: delegateItem
        property bool selected: index == selectedIndex;

        height: root.platformStyle.itemHeight
        anchors.left: parent.left
        anchors.right: parent.right

        MouseArea {
            id: delegateMouseArea
            anchors.fill: parent;
            onPressed: selectedIndex = index;
            onClicked: accept();
        }

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: delegateItem.selected ? root.platformStyle.itemSelectedBackgroundColor : root.platformStyle.itemBackgroundColor
        }

        BorderImage {
            id: background
            anchors.fill: parent
            border { left: UIConstants.CORNER_MARGINS; top: UIConstants.CORNER_MARGINS; right: UIConstants.CORNER_MARGINS; bottom: UIConstants.CORNER_MARGINS }
            source: delegateMouseArea.pressed ? root.platformStyle.itemPressedBackground :
            delegateItem.selected ? root.platformStyle.itemSelectedBackground :
                root.platformStyle.itemBackground
        }

        Image {
            id: icon
            source: index == 0?'../../images/gps-icon-inverted.png':'image://theme/icon-m-common-favorite-mark-inverse'
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: locName
            elide: Text.ElideRight
            color: delegateItem.selected ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.left: icon.right
            anchors.right: parent.right
            anchors.leftMargin: UIConstants.MARGIN_DEFAULT
            anchors.rightMargin: UIConstants.MARGIN_DEFAULT
            text: name
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            font.pointSize: UIConstants.FONT_DEFAULT
        }
    }
}
