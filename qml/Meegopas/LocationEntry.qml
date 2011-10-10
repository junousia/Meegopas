import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import QtMobility.location 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "MyConstants.js" as MyConstants
import "reittiopas.js" as Reittiopas

Column {
    property string type : ""
    property variant destCoords : ''
    property bool destValid : (suggestionModel.count > 0)
    property alias model: suggestionModel
    property alias text : textfield.text
    property alias auto_update : textfield.auto_update

    height: textfield.height + labelContainer.height
    width: parent.width

    function clear() {
        suggestionModel.clear()
        textfield.text = ''
        destCoords = ''
    }

    Timer {
        id: updateTimer
        repeat: false
        interval: 100
        onTriggered: {
            if(suggestionModel.count == 1 && !suggestionModel.updating) {
                textfield.auto_update = true
                textfield.text = suggestionModel.get(0).name
                destCoords = suggestionModel.get(0).coords
            }
        }
    }

    ListView {
        id:dummyview
        visible: false
        delegate: Component {
            Text { text: "dummy" }
        }
        model: suggestionModel
        onCountChanged: { updateTimer.start() }
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
    PositionSource {
        id: positionSource
        updateInterval: 5000
        active: true
    }

    ListModel {
        id: suggestionModel
        property bool updating : false
    }

    SelectionDialog {
        id: query
        model: suggestionModel
        delegate: SuggestionDelegate {}
        titleText: qsTr("Choose location")
        onAccepted: {
            textfield.auto_update = true
            textfield.text = suggestionModel.get(selectedIndex).name
            destCoords = suggestionModel.get(selectedIndex).coords
            suggestionModel.clear()
        }
        onRejected: {
            destCoords = ''
        }
    }

    Timer {
        id: suggestionTimer
        interval: 1000
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            if(textfield.acceptableInput)
                suggestionModel.clear()
                Reittiopas.address_to_location(textfield.text,suggestionModel)
        }
    }

    Item {
        id: labelContainer
        anchors.top: parent.top
        height: 60
        width: label.width + count.width
        BorderImage {
            anchors.fill: parent
            visible: labelMouseArea.pressed
            source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
        }
        Label {
            id: label
            font.pixelSize: MyConstants.FONT_XXLARGE
            font.family: ExtrasConstants.FONT_FAMILY_LIGHT
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: UIConstants.DEFAULT_MARGIN
            text: type
        }
        CountBubble {
            id: count
            largeSized: true
            value: suggestionModel.count
            visible: (suggestionModel.count > 1 && (destCoords === ''))
            anchors.left: label.right
            anchors.bottom: label.bottom
        }

        BusyIndicator {
            id: busyIndicator
            visible: suggestionModel.updating
            running: suggestionModel.updating
            anchors.left: label.right
            anchors.verticalCenter: label.verticalCenter
            platformStyle: BusyIndicatorStyle { size: 'medium' }
        }

        MouseArea {
            id: labelMouseArea
            anchors.fill: parent
            onClicked: {
                if(suggestionModel.count > 1) {
                    query.open()
                    textfield.platformCloseSoftwareInputPanel()
                }
            }
        }
    }
    Row {
        width: parent.width

        TextField {
            id: textfield
            property bool auto_update : false
            anchors.left: parent.left
            anchors.right: locationPicker.left
            text: ""
            placeholderText: qsTr("Type a location")
            validator: RegExpValidator { regExp: /^.{3,50}$/ }
            inputMethodHints: Qt.ImhNoPredictiveText

            onTextChanged: {
                if(auto_update)
                    auto_update = false
                else {
                    suggestionModel.clear()
                    if(acceptableInput)
                        suggestionTimer.restart()
                }
            }

            Image {
                id: clearLocation
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: 'image://theme/icon-m-input-clear'
                visible: ((textfield.activeFocus) && !busyIndicator.running)
                opacity: 0.5
                MouseArea {
                    id: locationInputMouseArea
                    anchors.fill: parent
                    onClicked: {
                        clear()
                    }
                }
            }

            Keys.onReturnPressed: {
                textfield.platformCloseSoftwareInputPanel()
            }
        }
        Button {
            id: locationPicker
            anchors.right: parent.right
            anchors.margins: UIConstants.BUTTON_SPACING
            width: 50
            enabled: (positionSource.position.latitudeValid && positionSource.position.longitudeValid)
            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: !theme.inverted?'../../images/gps-icon.png':'../../images/gps-icon-inverted.png'
                opacity: locationPicker.enabled? 0.8 : 0.3
            }
            onClicked: {
                clear()
                Reittiopas.location_to_address(positionSource.position.coordinate.latitude.toString(),
                                               positionSource.position.coordinate.longitude.toString(),suggestionModel)
            }
        }
    }
}
