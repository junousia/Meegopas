import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Component {
    id: routeDelegate
    Item {
        id: delegate_item
        width: parent.width
        height: 100
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: delegate_item
            property: "opacity"
            to: 1.0
            duration: 125
        }

        BorderImage {
            height: parent.height
            width: appWindow.width
            anchors.horizontalCenter: parent.horizontalCenter
            visible: mouseArea.pressed
            source: theme.inverted ? '../../images/background.png': '../../images/background.png'
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "(" + Qt.formatTime(start, "hh:mm") + ")"
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
            }

            Text {
                text: first_transport ? Qt.formatTime(first_transport, "hh:mm") : Qt.formatTime(start, "hh:mm")
                width: 75
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }

            Text {
                text: duration + " min"
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
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
                        height: 50 * appWindow.scaling_factor
                        width: height
                    }
                    Text {
                        text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                        visible: true
                        font.pixelSize: code == "metro" ? UIConstants.FONT_SMALL  * appWindow.scaling_factor : UIConstants.FONT_LSMALL * appWindow.scaling_factor
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
                text: "(" + Qt.formatTime(finish, "hh:mm") + ")"
                anchors.right: parent.right
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
            }
            Text {
                text: last_transport ? Qt.formatTime(last_transport, "hh:mm") : Qt.formatTime(finish, "hh:mm")
                anchors.right: parent.right
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: qsTr("Walk ") + Math.floor(walk/100)/10 + ' km'
                horizontalAlignment: Qt.AlignRight
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                routePage.model.clear()
                Reittiopas.dump_legs(index,routePage.model)
                routePage.fromLoc = from
                routePage.toLoc = to
                routePage.header = from + " - " + to
                routePage.subheader = qsTr("total duration") + " " + duration + " min - " + qsTr("amount of walking") + " " + Math.floor(walk/100)/10 + ' km'
                pageStack.push(routePage)
            }
        }
    }
}
