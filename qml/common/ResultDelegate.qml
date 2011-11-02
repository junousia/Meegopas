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
            source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-horizontal-center': 'image://theme/meegotouch-list-background-pressed-horizontal-center'
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: "(" + Qt.formatTime(start, "hh:mm") + ")"
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_LSMALL
            }

            Text {
                text: first_transport ? Qt.formatTime(first_transport, "hh:mm") : Qt.formatTime(start, "hh:mm")
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
                        visible: true
                        font.pixelSize: code == "metro" ? UIConstants.FONT_SMALL : UIConstants.FONT_LSMALL
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
                text: "(" + Qt.formatTime(finish, "hh:mm") + ")"
                anchors.right: parent.right
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_LSMALL
            }
            Text {
                text: last_transport ? Qt.formatTime(last_transport, "hh:mm") : Qt.formatTime(finish, "hh:mm")
                anchors.right: parent.right
                font.pixelSize: UIConstants.FONT_XLARGE
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: qsTr("Walk ") + Math.floor(walk/100)/10 + ' km'
                horizontalAlignment: Qt.AlignRight
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_LSMALL
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
                pageStack.push(routePage)
            }
        }
    }
}
