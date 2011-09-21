import QtQuick 1.1
import com.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UI
import "reittiopas.js" as Reittiopas

Rectangle {
    color: "transparent"
    property string type : ""
    property variant destCoords : ''
    property bool destValid : (suggestionModel.count > 0)
    property alias model: suggestionModel
    property alias text : textfield.text

    height: textfield.height
    width: parent.width

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

    TextField {
        id: textfield

        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: ""
        placeholderText: type
        validator: RegExpValidator { regExp: /^.{3,50}$/ }

        onTextChanged: {
            suggestionModel.clear()
            Reittiopas.address_to_location(textfield.text,suggestionModel)
        }

        CountBubble {
            id: suggestionCount
            largeSized: true
            anchors.right: parent.right
            value: suggestionModel.count

            MouseArea {
                anchors.fill: parent
                onClicked: {
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
        titleText: type
        onAccepted: {
            textfield.text = suggestionModel.get(selectedIndex).displayname
            destCoords = suggestionModel.get(selectedIndex).coords
            suggestionModel.clear()
        }
        onRejected: {
            destCoords = ''
        }
    }
}
