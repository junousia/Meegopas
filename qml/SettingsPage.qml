import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "storage.js" as Storage

Page {
    tools: commonTools
    Flickable {
        id: settingsContent
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait?
                           UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT :
            UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            leftMargin: UIConstants.DEFAULT_MARGIN
            rightMargin: UIConstants.DEFAULT_MARGIN
        }
        width: parent.width
        flickableDirection: Flickable.VerticalFlick
        Row {
            id: optimizeRow
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width
            Text {
                text: "Optimize"
                font.pixelSize: UIConstants.FONT_DEFAULT
                font.family: UIConstants.FONT_FAMILY
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            ButtonColumn {
                id: optimize
                anchors.right: parent.right
                Button {
                    id: def
                    text: "default"
                }
                Button {
                    id: fastest
                    text: "fastest"
                }
                Button {
                    id: transfers
                    text: "Least transfers"
                }
                Button {
                    id: walking
                    text: "Least walking"
                }
            }
        }
        Row {
            id: typeRow
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width
            anchors.top: optimizeRow.bottom
            anchors.right: parent.right
            Text {
                text: "Types"
                font.pixelSize: UIConstants.FONT_DEFAULT
                font.family: UIConstants.FONT_FAMILY
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            ButtonColumn {
                id: types

                Button {
                    id: bus
                    text: "Bus"
                }
                Button {
                    id: train
                    text: "Train"
                }
                Button {
                    id: metro
                    text: "Metro"
                }
                Button {
                    id: tram
                    text: "Tram"
                }
            }
        }
        Row {
            id: walkingRow
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width
            anchors.top: typeRow.bottom
            anchors.right: parent.right
            Text {
                text: "Walking speed"
                font.pixelSize: UIConstants.FONT_DEFAULT
                font.family: UIConstants.FONT_FAMILY
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
            Slider {
                platformStyle: SliderStyle
                minimumValue: 70
                maximumValue: 300
            }
        }
    }
}
