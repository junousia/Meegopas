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
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
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

            Text {
                text: qsTr("Used transports")
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND

                anchors.left: parent.left
            }

            ButtonColumn {
                id: transports
                exclusive: false
                spacing: UIConstants.BUTTON_SPACING
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
                    checkable: true
                    checked: true
                    onClicked: Storage.setSetting('bus_disabled', (!checked).toString())
                }
                Button {
                    id: train
                    checkable: true
                    checked: true
                    text: qsTr("Train")
                    onClicked: Storage.setSetting('train_disabled', (!checked).toString())
                }
                Button {
                    id: metro
                    checkable: true
                    checked: true
                    text: qsTr("Metro")
                    onClicked: Storage.setSetting('metro_disabled', (!checked).toString())
                }
                Button {
                    id: tram
                    checkable: true
                    checked: true
                    text: qsTr("Tram")
                    onClicked: {
                        Storage.setSetting('tram_disabled', (!checked).toString())
                    }
                }
            }

            Separator {}

            Text {
                text: qsTr("Change margin") + " (min)"
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                anchors.left: parent.left
            }
            Row {
                width: parent.width

                Slider {
                    id: change_margin
                    anchors.fill: parent
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
            }

            Spacing {}

            Separator {}

            Text {
                text: qsTr("Optimize route by")
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
