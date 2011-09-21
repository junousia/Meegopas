import QtQuick 1.1
import com.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UI
import "reittiopas.js" as Reittiopas

Page {
    tools: commonTools
    property alias model : routeModel
    property alias list : routeList
    ListModel {
        id: routeModel
    }

    Component {
        id: routeDelegate
        Row {
            spacing: UI.MARGIN_DEFAULT
            height: 100

            Column {
                Image {
                    id: transportIcon
                    source: "../images/train.svg"
                    smooth: true
                    height: 50
                    width: 50
                }
                Text {
                    text: type == "walk"? Math.round(length/100)/10 + " km" : code
                    font.pixelSize: UI.FONT_DEFAULT
                    font.family: UI.FONT_FAMILY
                    color: !theme.inverted ?
                               UI.COLOR_FOREGROUND :
                    UI.COLOR_INVERTED_FOREGROUND
                    anchors.horizontalCenter: transportIcon.horizontalCenter
                }
            }
        }
    }
    ListView {
        id: routeList
        anchors.fill: parent
        model: routeModel
        delegate: routeDelegate
        anchors.topMargin: appWindow.inPortrait?
                                 UI.HEADER_DEFAULT_TOP_SPACING_PORTRAIT :
            UI.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
        onCountChanged: { busyIndicator.visible = false }
    }

        BusyIndicator {
            id: busyIndicator
            visible: true
            running: true
            platformStyle: BusyIndicatorStyle { size: 'large' }
            anchors.centerIn: parent
        }
    }
