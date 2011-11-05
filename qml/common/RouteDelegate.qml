import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Component {
    id: routeDelegate
    Item {
        id: delegate_item
        height: 100
        width: parent.width
        // do not show if from and to times or names match
        enabled: !(from.name == to.name || from.time == to.time)
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
            anchors.left: parent.left
            anchors.right: transportColumn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: UIConstants.DEFAULT_MARGIN

            Text {
                text: Qt.formatTime(from.time, "hh:mm")
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: (index === 0)? fromLoc : from.name
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
        Column {
            id: transportColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../images/" + type + ".png"
            }
            Text {
                text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Column {
            anchors.right: parent.right
            anchors.left: transportColumn.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: UIConstants.DEFAULT_MARGIN
            Text {
                text: Qt.formatTime(to.time, "hh:mm")
                anchors.right: parent.right
                horizontalAlignment: Qt.AlignRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Text {
                text: index === routeModel.count - 1? toLoc : to.name
                horizontalAlignment: Text.AlignRight
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_DEFAULT * appWindow.scaling_factor
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
        MouseArea {
            id: mouseArea
            enabled: !(type == "walk")
            anchors.fill: parent
            onClicked: {
                stopPage.model.clear()
                Reittiopas.dump_stops(index, stopPage.model)
                stopPage.code = code
                pageStack.push(stopPage)
            }
        }
    }
}
