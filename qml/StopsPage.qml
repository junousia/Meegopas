import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Page {
    property alias model: stopModel

    tools: commonTools

    ListModel {
        id: stopModel
    }

    Component {
        id: stopDelegate
        Row {
            height: 100
            width: parent.width
            anchors.leftMargin: ExtrasConstants.LIST_ITEM_MARGIN
            anchors.rightMargin: ExtrasConstants.LIST_ITEM_MARGIN

            Column {
                anchors.left: parent.left
                width: 100
                Text {
                    text: (index === 0)? Qt.formatTime(depTime, "hh:mm") : Qt.formatTime(arrTime, "hh:mm")
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_LARGE
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                }
            }
            Column {
                anchors.right: parent.right
                width: parent.width - 100
                Text {
                    text: name
                    width: parent.width
                    horizontalAlignment: Qt.AlignRight
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_LARGE
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                }
            }
        }
    }

    ListView {
        id: routeList
        anchors.fill: parent
        model: stopModel
        delegate: stopDelegate

        anchors.topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(stopModel.count)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
