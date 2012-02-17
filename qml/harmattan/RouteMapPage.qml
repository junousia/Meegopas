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
import "reittiopas.js" as Reittiopas
import "UIConstants.js" as UIConstants

Page {
    id: page
    tools: mapTools
    anchors.fill: parent
    property bool follow : false

    ToolBarLayout {
        id: mapTools
        ToolIcon { iconId: "toolbar-back"
            onClicked: {
                pageStack.pop();
            }
        }
        ToolButtonRow {
            ToolIcon { iconId: "toolbar-mediacontrol-previous"; enabled: !follow; onClicked: { map.previous_station(); } }
            ToolIcon { iconId: "toolbar-mediacontrol-next"; enabled: !follow; onClicked: { map.next_station(); } }
            //ToolIcon { iconSource: "qrc:/images/gps-icon-inverted.png"; onClicked: { follow = follow?false:true } }
        }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    MapElement {
        id: map
        anchors.fill: parent
    }
}

