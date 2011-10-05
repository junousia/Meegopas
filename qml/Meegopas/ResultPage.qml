import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "MyConstants.js" as MyConstants
import "reittiopas.js" as Reittiopas

Page {
    tools: commonTools
    property alias routeModel : routeModel
    property string from : ""
    property string to : ""

    anchors.margins: UIConstants.DEFAULT_MARGIN

    // lock to portrait
    orientationLock: PageOrientation.LockPortrait

    RouteView { id: routeView }

    ListModel {
        id: routeModel
        property bool updating : false
    }

    Component {
        id: routeDelegate
        Item {
            width: parent.width
            height: 100

            BorderImage {
                anchors.fill: parent
                visible: mouseArea.pressed
                source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
            }
            Item {
                anchors.fill: parent

                Row {
                    width: parent.width

                    Column {
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: Qt.formatTime(start, "hh:mm")
                            width: 75
                            font.pixelSize: UIConstants.FONT_XLARGE
                            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                        }

                        Text {
                            text: duration + " min"
                            color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                            font.pixelSize: UIConstants.FONT_LSMALL
                        }
                    }
                    Flow {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            id: repeater
                            model: legs
                            Column {
                                visible: repeater.count == 1? true : (type == "walk")? false : true
                                Image {
                                    id: transportIcon
                                    source: "../../images/" + type + ".png"
                                    smooth: true
                                }
                                Text {
                                    text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                                    font.pixelSize: UIConstants.FONT_LSMALL
                                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
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
                            anchors.right: parent.right
                            font.pixelSize: UIConstants.FONT_XLARGE
                            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                            color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                        }
                        Text {
                            text: qsTr("Walk: ") + Math.floor(walk/100)/10 + ' km'
                            horizontalAlignment: Qt.AlignRight
                            color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                            font.pixelSize: UIConstants.FONT_LSMALL
                        }
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

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: list
        platformStyle: ScrollDecoratorStyle {}
    }

    BusyIndicator {
        id: busyIndicator
        visible: (routeModel.updating)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
