import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Page {
    tools: commonTools
    property string fromLoc : ''
    property string toLoc : ''
    property alias model : routeModel

    ListModel {
        id: routeModel
    }

    StopsPage { id: stopsPage }

    Component {
        id: routeDelegate
        Item {
            height: 100
            width: parent.width
            anchors.leftMargin: ExtrasConstants.LIST_ITEM_MARGIN
            anchors.rightMargin: ExtrasConstants.LIST_ITEM_MARGIN

            BorderImage {
                anchors.fill: parent
                visible: mouseArea.pressed
                source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
            }
            Column {
                anchors.left: parent.left
                width: parent.width/3
                Text {
                    text: (index === 0)? fromLoc : from.name
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: UIConstants.FONT_FAMILY
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                }
                Text {
                    text: Qt.formatTime(from.time, "hh:mm")
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: UIConstants.FONT_FAMILY
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                }
            }
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    id: transportIcon
                    source: "../images/" + type + ".png"
                    smooth: true
                    height: 50
                    width: 50
                }
                Text {
                    text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: UIConstants.FONT_FAMILY
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                    anchors.horizontalCenter: transportIcon.horizontalCenter
                }
            }
            Column {
                anchors.right: parent.right
                width: parent.width/3
                Text {
                    text: index === routeModel.count - 1? toLoc : to.name
                    width: parent.width
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: UIConstants.FONT_FAMILY
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                }

                Text {
                    text: Qt.formatTime(to.time, "hh:mm")
                    anchors.right: parent.right
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: UIConstants.FONT_FAMILY
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                }
            }
            MouseArea {
                id: mouseArea
                enabled: !(type == "walk")
                anchors.fill: parent
                onClicked: {
                    stopsPage.model.clear()
                    Reittiopas.dump_stops(index, stopsPage.model)
                    pageStack.push(stopsPage)
                }
            }
        }
    }

    ListView {
        id: routeList
        anchors.fill: parent
        model: routeModel
        delegate: routeDelegate
        header: Header {
            text: fromLoc + " - " + toLoc
        }

        anchors.topMargin: appWindow.inPortrait?
                               UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT :
        UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
    }

        BusyIndicator {
            id: busyIndicator
            visible: !(routeModel.count)
            running: true
            platformStyle: BusyIndicatorStyle { size: 'large' }
            anchors.centerIn: parent
        }
    }
