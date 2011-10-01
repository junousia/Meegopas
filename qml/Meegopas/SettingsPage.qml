import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "storage.js" as Storage

Page {
    tools: commonTools

    anchors.margins: UIConstants.DEFAULT_MARGIN

    Flickable {
        id: settingsContent
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN
        }
        width: parent.width
        flickableDirection: Flickable.VerticalFlick
        Column {
            spacing: UIConstants.DEFAULT_MARGIN
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
            ButtonRow {
                id: types
                exclusive: false
                Button {
                    id: bus
                    text: "Bus"
                    checkable: true
                }
                Button {
                    id: train
                    text: "Train"
                    checkable: true
                }
                Button {
                    id: metro
                    text: "Metro"
                    checkable: true
                }
                Button {
                    id: tram
                    text: "Tram"
                    checkable: true
                }
            }
            ButtonRow {
                id: speedrow
                Button {
                    id: slow
                    text: "slow"
                }
                Button {
                    id: fast
                    text: "fast"
                }
                Button {
                    id: vfast
                    text: "very fast"
                }
            }
        }
    }
}
