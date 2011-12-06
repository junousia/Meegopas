import QtQuick 1.0
import com.nokia.symbian 1.1
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants

Component {
    id: favoritesManageDelegate
    Item {
        width: parent.width
        height: UIConstants.LIST_ITEM_HEIGHT_SMALL

        Text {
            text: modelData
            anchors.left: parent.left
            anchors.right: remove_button.left
            anchors.verticalCenter: parent.verticalCenter
            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
            elide: Text.ElideRight
        }
        Button {
            id: remove_button
            text: qsTr("Remove")
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
            width: 150 * appWindow.scaling_factor
            height: 40
            onClicked: {
                list.currentIndex = index
                deleteQuery.message = modelData
                deleteQuery.open()
            }
        }
    }
}
