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

/* Modified from the example by Clovis Scotti <scotti@ieee.org>, http://cpscotti.com/blog/?p=52, released with GPL 3.0 */

import QtQuick 1.1
import QtMobility.location 1.2
import Qt.labs.gestures 1.0

Flickable {
    id: mapFlickable
    property alias map: map
    property double defaultLatitude: 60.1687069096
    property double defaultLongitude: 24.9407379411
    property int  defaultZoomLevel: 16

    property double centeredContentX: map.size.width*0.75
    property double centeredContentY: map.size.height*0.75

    interactive: !appWindow.follow_mode

    contentWidth: map.size.width * 2
    contentHeight: map.size.height * 2
    flickableDirection: Flickable.HorizontalAndVerticalFlick
    boundsBehavior: Flickable.DragAndOvershootBounds
    flickDeceleration: 4000
    maximumFlickVelocity: 1000

    pressDelay: 500
    clip: true
    function updateSizes()
    {
        centeredContentY = map.size.height*0.75
        centeredContentX = map.size.width*0.75
        map.pos.x = map.size.width/2
        map.pos.y = map.size.height/2
        map.transformOrigin = Item.Center
        map.scenter.x = map.width/2.0
        map.scenter.y = map.height/2.0
    }

    function updateViewPort() {
        map.pan((contentX-centeredContentX)/map.getScale,(contentY-centeredContentY)/map.getScale)

        contentX = centeredContentX
        contentY = centeredContentY
    }

    onMovementEnded: {
        updateSizes()
        updateViewPort()
    }

    Map {
        id: map
        size.width: mapFlickable.width * 2
        size.height: mapFlickable.height * 2
        zoomLevel: defaultZoomLevel
        plugin: Plugin {
            name: "nokia"
            parameters: [
                PluginParameter {
                    name: "mapping.token"
                    value: "QYpeZ4z7gwhQr7iW0hOTUQ%3D%3D"
                },
                PluginParameter {
                    name: "mapping.appid"
                    value: "ETjZnV1eZZ5o0JmN320V"
                }
            ]
        }
        mapType: Map.StreetMap
        connectivityMode: Map.OnlineMode
        center: Coordinate {
            latitude: defaultLatitude
            longitude:defaultLongitude
        }
        property alias scenter: tform.origin
        property alias getScale: tform.xScale
        function setScale(v) {
            tform.xScale = v
            tform.yScale = v
        }
        transform: Scale {
            id: tform
        }

        Component.onCompleted: {
            mapFlickable.updateSizes()
            mapFlickable.updateViewPort()
        }
    }

    function panToCoordinate(coordinate) {
        updateSizes()
        updateViewPort()
        map.center.latitude = coordinate.latitude
        map.center.longitude = coordinate.longitude
    }

    function panToLatLong(latitude,longitude) {
        updateSizes()
        updateViewPort()
        map.center.latitude = latitude
        map.center.longitude = longitude
    }

    PinchArea {
        id: pincharea
        anchors.fill: parent
        property double initScale
        property double p1toC_X
        property double p1toC_Y
        property double contentInitX
        property double contentInitY
        onPinchStarted: {
            initScale = map.getScale
            p1toC_X = (pinch.center.x-map.size.width)
            p1toC_Y = (pinch.center.y-map.size.height)
            contentInitX = mapFlickable.contentX
            contentInitY = mapFlickable.contentY
        }
        onPinchFinished: {
            mapFlickable.updateViewPort()
        }
        onPinchUpdated: {
            var contentDriftX = ((1-pinch.scale)*p1toC_X)
            var contentDriftY = ((1-pinch.scale)*p1toC_Y)
            //pinch.center.(x|y) drifts from to content, term in parenthesis offsets this back
            //startCenter does not drift.
            var tCenterDriftX = (pinch.center.x-(mapFlickable.contentX-contentInitX) - pinch.startCenter.x)
            var tCenterDriftY = (pinch.center.y-(mapFlickable.contentY-contentInitY) - pinch.startCenter.y)
            //test all two!
            mapFlickable.contentX = contentInitX-contentDriftX-tCenterDriftX
            mapFlickable.contentY = contentInitY-contentDriftY-tCenterDriftY
            if(initScale*pinch.scale <= 0.75 && map.zoomLevel > 2) {
                map.zoomLevel -= 1
                map.setScale(1.5)
                initScale = map.getScale/pinch.scale
            } else if(initScale*pinch.scale >= 1.5 && map.zoomLevel < 18) {
                map.zoomLevel += 1
                map.setScale(0.75)
                initScale = map.getScale/pinch.scale
            } else {
                if(! ((map.zoomLevel == 18 && (initScale*pinch.scale) > 2.0)
                      || (map.zoomLevel == 2 && (initScale*pinch.scale) < 0.85))) {
                    map.setScale(initScale*pinch.scale)
                }
            }
        }
    }
}
