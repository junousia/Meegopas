import QtQuick 1.1
import com.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UI
import "reittiopas.js" as Reittiopas

Page {
    tools: commonTools
    property alias routeModel : routeModel
    property string from : ""
    property string to : ""

    RouteView { id: routeView }

    ListModel {
        id: routeModel
    }

    Component {
        id: routeDelegate
        Rectangle {
            width: parent.width
            height: 100
            color: "transparent"
            Row {
                spacing: UI.MARGIN_DEFAULT
                height: 100
                width: parent.width
                Column {
                    Text {
                        text: Qt.formatTime(start, "hh:mm")
                        font.pixelSize: UI.FONT_DEFAULT
                        font.family: UI.FONT_FAMILY
                        color: !theme.inverted ?
                                   UI.COLOR_FOREGROUND :
                        UI.COLOR_INVERTED_FOREGROUND
                    }
                }
                Repeater {
                    model: legs
                    Column {
                        width: 50
                        Image {
                            id: transportIcon
                            source: "../images/" + type + ".svg"
                            smooth: true
                            height: 50
                            width: 50
                        }
                        Text {
                            text: type == "walk"? "" : code
                            font.pixelSize: UI.FONT_LSMALL
                            font.family: UI.FONT_FAMILY
                            color: !theme.inverted ?
                                       UI.COLOR_FOREGROUND :
                            UI.COLOR_INVERTED_FOREGROUND
                            anchors.horizontalCenter: transportIcon.horizontalCenter
                        }
                    }
                }
                Column {
                    anchors.right: parent.right
                    Text {
                        text: Qt.formatTime(finish, "hh:mm")
                        font.pixelSize: UI.FONT_DEFAULT
                        font.family: UI.FONT_FAMILY
                        color: !theme.inverted ?
                                   UI.COLOR_FOREGROUND :
                        UI.COLOR_INVERTED_FOREGROUND
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    routeView.model.clear()

                    for (var legindex in list.currentIndex.legs) {
                        var legdata = list.currentIndex.legs[legindex]
                        console.log(legdata + " " + routeView.model.count)
                        routeView.model.append(legdata)
                    }
                    pageStack.push(routeView)
                }
            }
        }
    }
    ListView {
        id: list
        anchors.fill: parent
        model: routeModel
        delegate: routeDelegate
        anchors.topMargin: appWindow.inPortrait?
                               UI.HEADER_DEFAULT_TOP_SPACING_PORTRAIT :
                               UI.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
        onCountChanged: busyIndicator.visible = false
    }

        BusyIndicator {
            id: busyIndicator
            visible: true
            running: true
            platformStyle: BusyIndicatorStyle { size: 'large' }
            anchors.centerIn: parent
        }
    }
