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

        Component.onCompleted: {
            Storage.initialize()
            optimize.set_value(Storage.getSetting("optimize"))
            speed.initialize_value(parseInt(Storage.getSetting("walking_speed")))
            console.log(parseInt(Storage.getSetting("walking_speed")))
        }

        Column {
            spacing: UIConstants.DEFAULT_MARGIN
            ButtonColumn {
                id: optimize
                function set_value(value) {
                    if(value == "default")
                        def.checked = true
                    else if(value == "fastest")
                        fastest.checked = true
                    else if(value == "least_transfers")
                        transfers.checked = true
                    else if(value == "least_walking")
                        walking.checked = true
                    else
                        console.log("optimize value not set")
                }

                anchors.right: parent.right
                Button {
                    id: def
                    text: "default"
                    onClicked: Storage.setSetting('optimize', 'default')
                }
                Button {
                    id: fastest
                    text: "fastest"
                    onClicked: Storage.setSetting('optimize', 'fastest')
                }
                Button {
                    id: transfers
                    text: "Least transfers"
                    onClicked: Storage.setSetting('optimize', 'least_transfers')
                }
                Button {
                    id: walking
                    text: "Least walking"
                    onClicked: Storage.setSetting('optimize', 'least_walking')
                }
            }
            Slider {
                id: speed

                function initialize_value(value) {
                    speed.value = value
                }

                stepSize: 30
                minimumValue: 70
                maximumValue: 500
                valueIndicatorVisible: true
                valueIndicatorText: qsTr("Walking speed")
                onValueChanged: {
                    console.log("setting speed " + speed.value.toString())
                    Storage.setSetting('walking_speed', speed.value.toString())
                }
            }
        }
    }
}
