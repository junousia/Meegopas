import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Page {
    tools: routeTools
    property string fromLoc : ''
    property string toLoc : ''
    property alias model : routeModel

    anchors.margins: UIConstants.DEFAULT_MARGIN

    // lock to portrait
    //orientationLock: PageOrientation.LockPortrait

    ToolBarLayout {
        id: routeTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
        ToolIcon { iconId: "icon-m-content-poi-inverse"; onClicked: { pageStack.push(Qt.resolvedUrl("RouteMapPage.qml")) } }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    ListModel {
        id: routeModel
        property bool updating : false
    }

    StopsPage { id: stopsPage }

    Component {
        id: routeDelegate
        Item {
            height: 100
            width: parent.width
            anchors.leftMargin: ExtrasConstants.LIST_ITEM_MARGIN
            anchors.rightMargin: ExtrasConstants.LIST_ITEM_MARGIN
            // do not show if from and to times or names match
            enabled: !(from.name == to.name || from.time == to.time)

            BorderImage {
                anchors.fill: parent
                visible: mouseArea.pressed
                source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
            }
            Column {
                anchors.left: parent.left
                anchors.right: transportColumn.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: UIConstants.DEFAULT_MARGIN

                Text {
                    text: Qt.formatTime(from.time, "hh:mm")
                    font.pixelSize: UIConstants.FONT_XLARGE
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                }
                Text {
                    text: (index === 0)? fromLoc : from.name
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                }
            }
            Column {
                id: transportColumn
                anchors.horizontalCenter: parent.horizontalCenter                
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../images/" + type + ".png"
                }
                Text {
                    text: type == "walk"? Math.floor(length/100)/10 + ' km' : code
                    font.pixelSize: UIConstants.FONT_LSMALL
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Column {
                anchors.right: parent.right
                anchors.left: transportColumn.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: UIConstants.DEFAULT_MARGIN
                Text {
                    text: Qt.formatTime(to.time, "hh:mm")
                    anchors.right: parent.right
                    horizontalAlignment: Qt.AlignRight
                    font.pixelSize: UIConstants.FONT_XLARGE
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                }
                Text {
                    text: index === routeModel.count - 1? toLoc : to.name
                    horizontalAlignment: Text.AlignRight
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: UIConstants.FONT_DEFAULT
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                }
            }
            MouseArea {
                id: mouseArea
                enabled: !(type == "walk")
                anchors.fill: parent
                onClicked: {
                    stopsPage.model.clear()
                    Reittiopas.dump_stops(index, stopsPage.model)
                    stopsPage.code = code
                    pageStack.push(stopsPage)
                }
            }
        }
    }

    ListView {
        id: routeList
        anchors.fill: parent
        model: routeModel
        delegate: routeDelegate
        header: Header {
            text: fromLoc + " - " + toLoc
        }
        anchors.topMargin: appWindow.inPortrait?UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_BOTTOM_SPACING_LANDSCAPE
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    BusyIndicator {
        id: busyIndicator
        visible: (routeModel.updating)
        running: true
        platformStyle: BusyIndicatorStyle { size: 'large' }
        anchors.centerIn: parent
    }
}
