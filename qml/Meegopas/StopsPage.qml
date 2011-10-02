import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Page {
    property alias model: stopModel
    property string code

    //anchors.margins: UIConstants.DEFAULT_MARGIN

    // lock to portrait
    orientationLock: PageOrientation.LockPortrait

    tools: commonTools

    ListModel {
        id: stopModel
    }

    Component {
        id: stopDelegate
        Row {
            height: UIConstants.LIST_ITEM_HEIGHT_SMALL
            width: parent.width

            Column {
                anchors.left: parent.left
                width: 100
                Text {
                    text: (index === 0)? Qt.formatTime(depTime, "hh:mm") : Qt.formatTime(arrTime, "hh:mm")
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_XLARGE
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
                    font.pixelSize: UIConstants.FONT_XLARGE
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                }
            }
        }
    }

    ListView {
        id: routeList
        anchors.fill: parent
        anchors.topMargin: appWindow.inPortrait?UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
        model: stopModel
        delegate: stopDelegate
        header: Header {
            text: "Stops for line " + code
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(stopModel.count)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
