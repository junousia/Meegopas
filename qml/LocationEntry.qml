import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "reittiopas.js" as Reittiopas

Item {
    property string type : ""
    property variant destCoords : ''
    property bool destValid : (suggestionModel.count > 0)
    property alias model: suggestionModel
    property alias text : textfield.text
    property alias label : label.text

    height: textfield.height + label.height
    width: parent.width

    anchors.topMargin: UIConstants.DEFAULT_MARGIN
    anchors.bottomMargin: UIConstants.DEFAULT_MARGIN

    function clear() {
        textfield.text = ''
        destCoords = ''
    }

    function getCoords() {
        if(destCoords != '') {
            return { "name":text, "coords":destCoords }
        }
        else if(textfield.acceptableInput) {
            return { "name":suggestionModel.get(0).displayname, "coords":suggestionModel.get(0).coords}
        }
        else
            console.log("no acceptable input")
    }
    Timer {
        id: suggestionTimer
        interval: 1000
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            if(textfield.acceptableInput)
                Reittiopas.address_to_location(textfield.text,suggestionModel)
        }
    }
    Label {
        id: label
        font.pixelSize: UIConstants.FONT_XLARGE
        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: UIConstants.DEFAULT_MARGIN
        text: type
    }
    Row {
        width: parent.width
        spacing: UIConstants.BUTTON_SPACING
        anchors.rightMargin: UIConstants.DEFAULT_MARGIN
        anchors.leftMargin: UIConstants.DEFAULT_MARGIN
        anchors.top: label.bottom

        TextField {
            id: textfield
            anchors.left: parent.left
            width: parent.width - 70
            text: ""
            placeholderText: type
            validator: RegExpValidator { regExp: /^.{3,50}$/ }
            inputMethodHints: Qt.ImhNoPredictiveText

            onTextChanged: {
                suggestionModel.clear()
                if(acceptableInput)
                    suggestionTimer.restart()
            }

            Image {
                id: clearLocation
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: 'image://theme/icon-m-input-clear'
                visible: (textfield.activeFocus)
                opacity: 0.5
                MouseArea {
                    id: locationInputMouseArea
                    anchors.fill: parent
                    onClicked: {
                        clear()
                    }
                }
            }
        }
        Button {
            id: locationPicker
            anchors.right: parent.right
            height:parent.height
            width: height
            enabled: (suggestionModel.count > 1)
            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: 'image://theme/icon-m-calendar-location-picker'
            }
            CountBubble {
                largeSized: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                value: suggestionModel.count
                visible: (suggestionModel.count && (destCoords === ''))
            }
            onClicked: {
                if(suggestionModel.count) {
                    query.open()
                    textfield.platformCloseSoftwareInputPanel()
                }
            }
        }
    }

    ListModel { id: suggestionModel }

    SelectionDialog {
        id: query
        model: suggestionModel
        delegate: SuggestionDelegate {}
        titleText: type
        onAccepted: {
            textfield.text = suggestionModel.get(selectedIndex).name
            destCoords = suggestionModel.get(selectedIndex).coords
            suggestionModel.clear()
        }
        onRejected: {
            destCoords = ''
        }
    }
}
