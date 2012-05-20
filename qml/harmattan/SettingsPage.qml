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
import com.nokia.meego 1.0
import "UIConstants.js" as UIConstants
import "storage.js" as Storage
import "theme.js" as Theme

Page {
    tools: settingsTools

    ToolBarLayout {
        id: settingsTools
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
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
            //theme.set_value(Storage.getSetting("theme"))
            optimize.set_value(Storage.getSetting("optimize"))
            walking_speed.set_value(Storage.getSetting("walking_speed"))
            change_margin.set_value(Storage.getSetting("change_margin"))
            optimize_cycling.set_value(Storage.getSetting("optimize_cycling"))

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
//            Text {
//                text: qsTr("Color scheme")
//                font.pixelSize: UIConstants.FONT_XLARGE  * appWindow.scaling_factor
//                color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
//                anchors.left: parent.left
//                lineHeightMode: Text.FixedHeight
//                lineHeight: font.pixelSize * 1.2
//            }

//            ButtonColumn {
//                id: theme
//                function set_value(value) {
//                    if(value == "default")
//                        theme_default.checked = true
//                    else if(value == "ligth")
//                        theme_light.checked = true
//                    else if(value == "warm")
//                        theme_warm.checked = true
//                }

//                anchors.right: parent.right
//                Button {
//                    id: theme_default
//                    text: qsTr("Default")
//                    onClicked: Storage.setSetting('theme', 'default')
//                }
//                Button {
//                    id: theme_light
//                    text: qsTr("Light")
//                    onClicked: Storage.setSetting('theme', 'light')
//                }
//                Button {
//                    id: theme_warm
//                    text: qsTr("Warm")
//                    onClicked: Storage.setSetting('theme', 'warm')
//                }
//            }

//            Separator {}

            SectionHeader {
                text: qsTr("Used transports")
            }

            ButtonColumn {
                id: transports
                exclusive: false
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
                    onClicked: Storage.setSetting('train_disabled', (!checked).toString())
                }
                Button {
                    id: metro
                    text: qsTr("Metro")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    checkable: true
                    checked: true
                    onClicked: Storage.setSetting('metro_disabled', (!checked).toString())
                }
                Button {
                    id: tram
                    text: qsTr("Tram")
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    checkable: true
                    checked: true
                    onClicked: {
                        Storage.setSetting('tram_disabled', (!checked).toString())
                    }
                }
            }

            SectionHeader {
                text: qsTr("Change margin") + " (min)"
            }

            Row {
                anchors.right: parent.right
                Text {
                    text: "0"
                    font.pixelSize: UIConstants.FONT_XLARGE
                    color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                    anchors.verticalCenter: parent.verticalCenter
                    lineHeightMode: Text.FixedHeight
                    lineHeight: font.pixelSize * 1.2
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
                    font.pixelSize: UIConstants.FONT_XLARGE
                    color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
                    anchors.verticalCenter: parent.verticalCenter
                    lineHeightMode: Text.FixedHeight
                    lineHeight: font.pixelSize * 1.2
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
                }

                anchors.right: parent.right
                Button {
                    id: def
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Default")
                    onClicked: Storage.setSetting('optimize', 'default')
                }
                Button {
                    id: fastest
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Fastest")
                    onClicked: Storage.setSetting('optimize', 'fastest')
                }
                Button {
                    id: transfers
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Least transfers")
                    onClicked: Storage.setSetting('optimize', 'least_transfers')
                }
                Button {
                    id: lwalking
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Least walking")
                    onClicked: Storage.setSetting('optimize', 'least_walking')
                }
            }

            SectionHeader {
                text: qsTr("Walking speed")
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
                }

                anchors.right: parent.right
                Button {
                    id: walking
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Walking")
                    onClicked: Storage.setSetting('walking_speed', '70')
                }
                Button {
                    id: fwalking
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Fast walking")
                    onClicked: Storage.setSetting('walking_speed', '100')
                }
                Button {
                    id: vfwalking
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Very fast walking")
                    onClicked: Storage.setSetting('walking_speed', '120')
                }
                Button {
                    id: running
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Running")
                    onClicked: Storage.setSetting('walking_speed', '150')
                }
            }

            SectionHeader {
                text: qsTr("Optimize cycling route by")
            }

            ButtonColumn {
                id: optimize_cycling
                function set_value(value) {
                    if(value == "kleroweighted")
                        cyclingDefault.checked = true
                    else if(value == "klerotarmac")
                        cyclingTarmac.checked = true
                    else if(value == "klerosand")
                        cyclingGravel.checked = true
                    else if(value == "kleroshortest")
                        cyclingShortest.checked = true
                }

                anchors.right: parent.right
                Button {
                    id: cyclingDefault
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Default")
                    onClicked: Storage.setSetting('optimize_cycling', 'kleroweighted')
                }
                Button {
                    id: cyclingTarmac
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Tarmac")
                    onClicked: Storage.setSetting('optimize_cycling', 'klerotarmac')
                }
                Button {
                    id: cyclingGravel
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Gravel")
                    onClicked: Storage.setSetting('optimize_cycling', 'klerosand')
                }
                Button {
                    id: cyclingShortest
                    font.pixelSize: UIConstants.FONT_LSMALL * appWindow.scaling_factor
                    text: qsTr("Shortest")
                    onClicked: Storage.setSetting('optimize_cycling', 'kleroshortest')
                }
            }
        }
    }
}
