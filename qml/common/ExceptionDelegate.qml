import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "helper.js" as Helper

Component {
    id: disruptionDelegate
    Item {
        id: delegate_item
        width: parent.width
        height: column.height + UIConstants.DEFAULT_MARGIN
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: delegate_item
            property: "opacity"
            to: 1.0
            duration: 125
        }
        Column {
            id: column
            anchors.right: parent.right
            anchors.left: parent.left
            Text {
                text: Qt.formatDateTime(Helper.parse_disruption_time(time), "dd.MM.yyyy - hh:mm")
                anchors.left: parent.left
                horizontalAlignment: Qt.AlignLeft
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: info_fi
                horizontalAlignment: Text.AlignLeft
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
    }
}
