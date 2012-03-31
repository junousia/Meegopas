/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

import QtQuick 1.1
import com.nokia.symbian 1.1
import "UIConstants.js" as UIConstants
import "storage.js" as Storage
import "theme.js" as Theme

Page {
    tools: settingsTools

    ToolBarLayout {
        id: settingsTools
        ToolButton { iconSource: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.theme[appWindow.colorscheme].COLOR_BACKGROUND
        z: -50
    }

    Flickable {
        id: settingsContent
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        contentHeight: content_column.height + 2 * UIConstants.DEFAULT_MARGIN
        flickableDirection: Flickable.VerticalFlick

        Component.onCompleted: {
            Storage.initialize()
            optimize.set_value(Storage.getSetting("optimize"))
            walking_speed.set_value(Storage.getSetting("walking_speed"))
            change_margin.set_value(Storage.getSetting("change_margin"))

            if(Storage.getSetting("train_disabled") == "true") {
                console.debug("train disabled")
                transports.set_value("train")
            }
            if(Storage.getSetting("bus_disabled") == "true") {
                console.debug("bus disabled")
                transports.set_value("bus")
            }
            if(Storage.getSetting("metro_disabled") == "true") {
                console.debug("metro disabled")
                transports.set_value("metro")
            }
            if(Storage.getSetting("tram_disabled") == "true") {
                console.debug("tram disabled")
                transports.set_value("tram")
            }
        }

        Column {
            id: content_column
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width
            Header {
                text: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Used transports")
            }

//            SettingsItem {
//                setting.text: "Color sceme"
//                value.text: ""
//                showComboBox: true
//                Component.onCompleted: {
//                    settingModel.append({"name":"default"})
//                    settingModel.append({"name":"light"})
//                    settingModel.append({"name":"warm"})
//                }
//            }

            ButtonRow {
                id: transports
                exclusive: false
                width: parent.width
                function set_value(value) {
                    if(value == "bus")
                        bus.checked = false
                    else if(value == "train")
                        train.checked = false
                    else if(value == "metro")
                        metro.checked = false
                    else if(value == "tram")
                        tram.checked = false
                    else
                        console.log("unknown value")
                }

                anchors.right: parent.right
                Button {
                    id: bus
                    text: qsTr("Bus")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    iconSource: "qrc:/images/bus.png"
                    checkable: true
                    checked: true
                    onClicked: Storage.setSetting('bus_disabled', (!checked).toString())
                }
                Button {
                    id: train
                    text: qsTr("Train")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    checkable: true
                    checked: true
                    iconSource: "qrc:/images/train.png"
                    onClicked: Storage.setSetting('train_disabled', (!checked).toString())
                }
                Button {
                    id: metro
                    text: qsTr("Metro")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    checkable: true
                    checked: true
                    iconSource: "qrc:/images/metro.png"
                    onClicked: Storage.setSetting('metro_disabled', (!checked).toString())
                }
                Button {
                    id: tram
                    text: qsTr("Tram")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    checkable: true
                    checked: true
                    iconSource: "qrc:/images/tram.png"
                    onClicked: {
                        Storage.setSetting('tram_disabled', (!checked).toString())
                    }
                }
            }
            SectionHeader {
                text: qsTr("Change margin") + " (min)"
            }
            Item {
                anchors.right: parent.right
                width: parent.width
                height: change_margin.height
                Text {
                    id: min_change
                    anchors.left: parent.left
                    text: "0"
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    id: change_margin
                    anchors.right: max_change.left
                    anchors.left: min_change.right
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
                    id: max_change
                    text: "10"
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }
            }

            SectionHeader {
                text: qsTr("Optimize route by")
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
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Default")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('optimize', 'default')
                }
                Button {
                    id: fastest
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Fastest")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('optimize', 'fastest')
                }
                Button {
                    id: transfers
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Least transfers")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('optimize', 'least_transfers')
                }
                Button {
                    id: lwalking
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Least walking")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('optimize', 'least_walking')
                }
            }

            SectionHeader {
                text: qsTr("Walking speed")
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
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Walking")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('walking_speed', '70')
                }
                Button {
                    id: fwalking
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Fast walking")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('walking_speed', '100')
                }
                Button {
                    id: vfwalking
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Very fast walking")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('walking_speed', '120')
                }
                Button {
                    id: running
                    width: UIConstants.SYMBIAN_SETTINGS_BUTTON_WIDTH
                    text: qsTr("Running")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    onClicked: Storage.setSetting('walking_speed', '150')
                }
            }
        }
    }
}
