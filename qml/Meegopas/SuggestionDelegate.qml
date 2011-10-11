import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Component {
    id: suggestionDelegate

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

        Text {
            id: locName
            elide: Text.ElideRight
            color: delegateItem.selected ? root.platformStyle.itemSelectedTextColor : root.platformStyle.itemTextColor
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.left: parent.left
            anchors.right: locType.left
            anchors.leftMargin: UIConstants.MARGIN_DEFAULT
            anchors.rightMargin: UIConstants.MARGIN_DEFAULT
            text: name
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            font.pixelSize: UIConstants.FONT_LARGE
        }
        Text {
            id: locType
            width: 100
            elide: Text.ElideRight
            color: UIConstants.COLOR_BUTTON_SECONDARY_FOREGROUND
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: delegateItem.verticalCenter
            anchors.right: parent.right
            anchors.leftMargin: UIConstants.MARGIN_DEFAULT
            anchors.rightMargin: UIConstants.MARGIN_DEFAULT
            text: city
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            font.pixelSize: UIConstants.FONT_LSMALL
        }
    }
}
