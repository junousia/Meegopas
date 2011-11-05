import QtQuick 1.1
import com.nokia.symbian 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/storage.js" as Storage

Page {
    tools: settingsTools

    ToolBarLayout {
        id: settingsTools
        x: 0
        y: 0
        ToolButton { iconSource: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
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
            console.log("optimize setting: " + Storage.getSetting("optimize"))
            walking_speed.set_value(Storage.getSetting("walking_speed"))
            console.log("walking_speed setting: " + Storage.getSetting("walking_speed"))
            change_margin.set_value(Storage.getSetting("change_margin"))
            console.log("change_margin setting: " + Storage.getSetting("change_margin"))
        }

        Column {
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width
            Header {
                text: qsTr("Settings")
            }

            Text {
                text: qsTr("Change margin") + " (min)"
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                anchors.left: parent.left
            }
            Row {
                Text {
                    text: "0"
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
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
                Text {
                    text: "10"
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                }
            }

            Separator {}

            Text {
                text: qsTr("Optimize route by")
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                anchors.left: parent.left
            }

            ButtonColumn {
                id: optimize
                spacing: UIConstants.BUTTON_SPACING
                function set_value(value) {
                    if(value == "default")
                        optimize.checkedButton = def
                    else if(value == "fastest")
                        optimize.checkedButton = fastest
                    else if(value == "least_transfers")
                        optimize.checkedButton = transfers
                    else if(value == "least_walking")
                        optimize.checkedButton = lwalking
                    else
                        console.log("optimize value not set")
                }

                anchors.right: parent.right
                Button {
                    id: def
                    text: qsTr("Default")
                    checkable: true
                    onClicked: Storage.setSetting('optimize', 'default')
                }
                Button {
                    id: fastest
                    checkable: true
                    text: qsTr("Fastest")
                    onClicked: Storage.setSetting('optimize', 'fastest')
                }
                Button {
                    id: transfers
                    checkable: true
                    text: qsTr("Least transfers")
                    onClicked: Storage.setSetting('optimize', 'least_transfers')
                }
                Button {
                    id: lwalking
                    checkable: true
                    text: qsTr("Least walking")
                    onClicked: { Storage.setSetting('optimize', 'least_walking')
                        console.log("set value")
                    }
                }
            }

            Separator {}

            Text {
                text: qsTr("Walking speed")
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                anchors.left: parent.left
            }
            ButtonColumn {
                id: walking_speed
                spacing: UIConstants.BUTTON_SPACING
                function set_value(value) {
                    if(value == "70")
                        walking_speed.checkedButton = walking
                    else if(value == "100")
                        walking_speed.checkedButton = fwalking
                    else if(value == "120")
                        walking_speed.checkedButton = vfwalking
                    else if(value == "150")
                        walking_speed.checkedButton = running
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
