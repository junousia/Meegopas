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
import QtMobility.location 1.2
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas
import "storage.js" as Storage
import "theme.js" as Theme

Page {
    id: cyclingPage
    tools: mapTools

    signal configChanged
    signal positionChanged

    property variant search_parameters : 0
    property bool initDone : false
    property bool routeDone : (doneIndicator.done && map_loader.status == Loader.Ready)

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: appWindow.positioningActive
    }

    onRouteDoneChanged: {
        if(routeDone) {
            map_loader.item.initialize_cycling()
        }
    }

    onStatusChanged: {
        if(status == Component.Ready && !initDone) {
            initDone = true
            map_loader.sourceComponent = map_component
            Reittiopas.new_cycling_instance(search_parameters, doneIndicator)
        }
    }

    onConfigChanged: {
        map_loader.item.removeAll()
        Reittiopas.new_cycling_instance(search_parameters, doneIndicator)
    }

    onPositionChanged: {
        map_loader.item.removeAll()
        Reittiopas.new_cycling_instance(search_parameters, doneIndicator)
    }

    Connections {
        target: map_loader.item
        onNewCycling: length >= 1000?
                          title.title = qsTr("Route length: ") + Math.floor(length/100)/10 + " km" :
                          title.title = qsTr("Route length: ") + length + " m"
    }

    ListModel {
        id: surfaceOptions
        ListElement { name: QT_TR_NOOP("Default"); value: "kleroweighted" }
        ListElement { name: QT_TR_NOOP("Tarmac"); value: "klerotarmac" }
        ListElement { name: QT_TR_NOOP("Gravel"); value: "klerosand" }
        ListElement { name: QT_TR_NOOP("Shortest"); value: "kleroshortest" }
    }

    SelectionDialog {
        id: surfaceSelection
        model: surfaceOptions
        titleText: qsTr("Optimize route by")
        delegate: SelectionDialogDelegate {}
        onAccepted: {
            var temp_parameters = search_parameters
            temp_parameters.profile = surfaceOptions.get(selectedIndex).value
            search_parameters = temp_parameters
            configChanged()
        }
        Component.onCompleted: {
            /* mark pre-configured value as selected */
            var optimize = Storage.getSetting("optimize_cycling")
            switch(optimize) {
            case "kleroweighted":
            case "Unknown":
                surfaceSelection.selectedIndex = 0
                break;
            case "klerotarmac":
                surfaceSelection.selectedIndex = 1
                break;
            case "klerosand":
                surfaceSelection.selectedIndex = 2
                break;
            case "kleroshortest":
                surfaceSelection.selectedIndex = 3
                break;
            default:
                break;
            }
        }
    }

    ListModel {
        id: mapTypeModel
        ListElement { name: "Street"; value: Map.MobileStreetMap }
        ListElement { name: "Satellite"; value: Map.SatelliteMapDay }
        ListElement { name: "Hybrid"; value: Map.MobileHybridMap }
        ListElement { name: "Terrain"; value: Map.MobileTerrainMap }
        ListElement { name: "Transit"; value: Map.MobileTransitMap }
    }

    SelectionDialog {
        id: mapTypeSelection
        model: mapTypeModel
        delegate: SelectionDialogDelegate {}
        selectedIndex: 0
        titleText: qsTr("Map type")
        onAccepted: {
            map_loader.item.flickable_map.map.mapType = mapTypeModel.get(selectedIndex).value
        }
    }

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: surface.width + UIConstants.DEFAULT_MARGIN * 2
        spacing: UIConstants.DEFAULT_MARGIN
        z: 500
        MapButton {
            id: surface
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/surface.png"
            z: 500
            mouseArea.onClicked: {
                surfaceSelection.open()
            }
        }
        MapButton {
            id: mapMode
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/maptype.png"
            z: 500
            mouseArea.onClicked: {
                mapTypeSelection.open()
            }
        }
        MapButton {
            id: followMode
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/images/current.png"
            z: 500
            selected: appWindow.followMode
            mouseArea.onClicked: {
                appWindow.followMode = appWindow.followMode? false : true
            }
        }
    }

    ToolBarLayout {
        id: mapTools
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: { menu.close(); pageStack.pop(); }
        }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (menu.status == DialogStatus.Closed) ? menu.open() : menu.close()
        }
    }

    Item {
        id: doneIndicator
        property bool done : false
    }

    ApplicationHeader {
        id: title
        title: qsTr("")
        color: Theme.theme[appWindow.colorscheme].COLOR_MAPHEADER_BACKGROUND
        title_color: Theme.theme[appWindow.colorscheme].COLOR_MAPHEADER_FOREGROUND
        anchors.top: parent.top
        MyButton {
            imageSize: 40
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: UIConstants.DEFAULT_MARGIN
            image.source: 'qrc:/images/switch.png'
            mouseArea.onClicked: {
                var temp_parameters = search_parameters
                temp_parameters.from = positionSource.position.coordinate.longitude + "," + positionSource.position.coordinate.latitude
                search_parameters = temp_parameters
                positionChanged()
            }
        }
    }

    Loader {
        id: map_loader
        anchors.fill: cyclingPage
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Component {
        id: map_component
        MapElement {
            anchors.fill: cyclingPage
        }
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && false)
        width: parent.width
        text: qsTr("No results")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: UIConstants.FONT_XXXLARGE * appWindow.scalingFactor
        color: Theme.theme[appWindow.colorscheme].COLOR_SECONDARY_FOREGROUND
    }

    MyBusyIndicator {
        id: busyIndicator
        visible: !(doneIndicator.done)
        running: true
        indicatorSize: "large"
        anchors.centerIn: parent
    }
}
