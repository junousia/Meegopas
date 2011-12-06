import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants

Page {
    tools: exceptionTools

    Component.onCompleted: {
        exceptionModel.reload()
    }
    ToolBarLayout {
        id: exceptionTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { pageStack.pop(); } }
        ToolButton {
            text: qsTr("Update")
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: { exceptionModel.reload() }
        }
    }
    XmlListModel {
        id: exceptionModel
        source: "http://www.poikkeusinfo.fi/xml/v2"
        query: "/exceptionS/exception"
        XmlRole { name: "time"; query: "VALIDITY/@from/string()" }
        XmlRole { name: "info_fi"; query: "INFO/TEXT[1]/string()" }
        XmlRole { name: "info_sv"; query: "INFO/TEXT[2]/string()" }
        XmlRole { name: "info_en"; query: "INFO/TEXT[3]/string()" }
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: UIConstants.DEFAULT_MARGIN * appWindow.scaling_factor
        model: exceptionModel
        delegate: ExceptionDelegate {}

        header: Header {
            text: qsTr("Traffic exception info")
        }
    }

    ScrollDecorator {
        id: scrolldecorator
        flickableItem: list
    }

    Text {
        anchors.centerIn: parent
        visible: (!busyIndicator.visible && exceptionModel.count == 0)
        width: parent.width
        text: qsTr("No current traffic exceptions")
        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: MyConstants.FONT_XXXLARGE * appWindow.scaling_factor
        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
    }

    BusyIndicator {
        id: busyIndicator
        visible: (exceptionModel.status != XmlListModel.Ready)
        running: true
        anchors.centerIn: parent
        platformStyle: BusyIndicatorStyle { size: 'large' }
    }
}
