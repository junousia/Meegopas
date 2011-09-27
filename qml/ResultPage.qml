import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
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
        Item {
            width: parent.width
            height: 125

            BorderImage {
                anchors.fill: parent
                visible: mouseArea.pressed
                source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
            }
            Item {
                height: parent.height
                width: parent.width
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: Qt.formatTime(start, "hh:mm")
                        width: 75
                        font.pixelSize: UIConstants.FONT_DEFAULT
                        font.family: UIConstants.FONT_FAMILY
                        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                    }
                }
                Flow {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        model: legs
                        Column {
                            width: 55
                            Image {
                                id: transportIcon
                                source: "../images/" + type + ".png"
                                visible: (type == "walk")? false : true
                                smooth: true
                                height: 60
                                width: 60
                            }
                            Text {
                                text: type == "walk"? "" : code
                                font.pixelSize: UIConstants.FONT_LSMALL
                                font.family: UIConstants.FONT_FAMILY
                                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                                anchors.horizontalCenter: transportIcon.horizontalCenter
                            }
                        }
                    }
                }
                Column {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: Qt.formatTime(finish, "hh:mm")
                        font.pixelSize: UIConstants.FONT_DEFAULT
                        font.family: UIConstants.FONT_FAMILY
                        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                    }
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    routeView.model.clear()
                    Reittiopas.dump_legs(index,routeView.model)
                    routeView.fromLoc = from
                    routeView.toLoc = to
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
        header: Header {
            text: from + " - " + to
        }
        anchors.topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.count > 0)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
