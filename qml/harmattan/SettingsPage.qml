import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/storage.js" as Storage

Page {
    tools: settingsTools

    ToolBarLayout {
        id: settingsTools
        x: 0
        y: 0
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
    }

    Flickable {
        id: settingsContent
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN

        contentHeight: content_column.height + 2 * UIConstants.DEFAULT_MARGIN
        flickableDirection: Flickable.VerticalFlick

        Component.onCompleted: {
            Storage.initialize()
            optimize.set_value(Storage.getSetting("optimize"))
            walking_speed.set_value(Storage.getSetting("walking_speed"))
            change_margin.set_value(Storage.getSetting("change_margin"))
        }

        Column {
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width
            Header {
                text: qsTr("Settings")
            }

            Label {
                text: qsTr("Change margin") + " (min)"
                font.pixelSize: UIConstants.FONT_LARGE
                anchors.left: parent.left
            }
            Row {
                anchors.right: parent.right
                Label {
                    text: "0"
                    font.pixelSize: UIConstants.FONT_LARGE
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    id: change_margin
                    maximumValue: 10
                    minimumValue: 0
                    stepSize: 1
                    valueIndicatorVisible: true

                    function set_value(value) {
                        if(value != "Unknown")
                            change_margin.value = value
                        else
                            change_margin.value = 3
                    }
                    onValueChanged: {
                        Storage.setSetting("change_margin", change_margin.value)
                    }
                }
                Label {
                    text: "10"
                    font.pixelSize: UIConstants.FONT_LARGE
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Separator {}

            Label {
                text: qsTr("Optimize route by")
                font.pixelSize: UIConstants.FONT_LARGE
                anchors.left: parent.left
            }

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
                        lwalking.checked = true
                    else
                        console.log("optimize value not set")
                }

                anchors.right: parent.right
                Button {
                    id: def
                    text: qsTr("Default")
                    onClicked: Storage.setSetting('optimize', 'default')
                }
                Button {
                    id: fastest
                    text: qsTr("Fastest")
                    onClicked: Storage.setSetting('optimize', 'fastest')
                }
                Button {
                    id: transfers
                    text: qsTr("Least transfers")
                    onClicked: Storage.setSetting('optimize', 'least_transfers')
                }
                Button {
                    id: lwalking
                    text: qsTr("Least walking")
                    onClicked: Storage.setSetting('optimize', 'least_walking')
                }
            }

            Separator {}

            Label {
                text: qsTr("Walking speed")
                font.pixelSize: UIConstants.FONT_LARGE
                anchors.left: parent.left
            }
            ButtonColumn {
                id: walking_speed
                function set_value(value) {
                    if(value == "70")
                        walking.checked = true
                    else if(value == "100")
                        fwalking.checked = true
                    else if(value == "120")
                        vfwalking.checked = true
                    else if(value == "150")
                        running.checked = true
                    else
                        console.log("walking_speed value not set")
                }

                anchors.right: parent.right
                Button {
                    id: walking
                    text: qsTr("Walking")
                    onClicked: Storage.setSetting('walking_speed', '70')
                }
                Button {
                    id: fwalking
                    text: qsTr("Fast walking")
                    onClicked: Storage.setSetting('walking_speed', '100')
                }
                Button {
                    id: vfwalking
                    text: qsTr("Very fast walking")
                    onClicked: Storage.setSetting('walking_speed', '120')
                }
                Button {
                    id: running
                    text: qsTr("Running")
                    onClicked: Storage.setSetting('walking_speed', '150')
                }
            }
        }
    }
}
