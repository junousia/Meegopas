import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants
import "MyConstants.js" as MyConstants
import "reittiopas.js" as Reittiopas
import "storage.js" as Storage

Page {
    id: root
    tools: mainTools

    // lock to portrait
    orientationLock: PageOrientation.LockPortrait

    property date myDate
    property date myTime

    Component.onCompleted: {
        theme.inverted = true
        myDate = new Date()
        myTime = new Date()
        Storage.initialize()
        Favorites.initialize()
    }

    ToolBarLayout {
        id: mainTools
        x: 0
        y: 0
        ToolButtonRow {
            ToolButton {
                text: qsTr("Search")
                enabled: ((from.destCoords != '' || from.destValid) && (to.destCoords != '' || to.destValid))
                onClicked: {
                    resu.routeModel.clear()
                    var walking_speed = Storage.getSetting("walking_speed")
                    var optimize = Storage.getSetting("optimize")
                    var change_margin = Storage.getSetting("change_margin")
                    Reittiopas.route(from.getCoords().coords,
                                     to.getCoords().coords,
                                     Qt.formatDate(root.myDate, "yyyyMMdd"),
                                     Qt.formatTime(root.myTime, "hhmm"),
                                     timeType.checked? "arrival" : "departure",
                                                                 walking_speed == "Unknown"?"70":walking_speed,
                                                                                                optimize == "Unknown"?"default":optimize,
                                                                                                                               change_margin == "Unknown"?"3":Math.floor(change_margin),
                                                                                                                                                             resu.routeModel)

                    resu.from = from.getCoords().name
                    resu.to = to.getCoords().name
                    pageStack.push(resu)
                }
            }
        }
        ToolIcon { iconId: "toolbar-view-menu" ; onClicked: myMenu.open(); }
    }

    ResultPage { id: resu }

    DatePickerDialog {
        id: datePicker
        onAccepted: {
            root.myDate = new Date(datePicker.year, datePicker.month-1, datePicker.day, 0)
            dateButton.text = Qt.formatDate(root.myDate, "dd. MMMM yyyy")
        }
        minimumYear: 2011

        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    TimePickerDialog {
        id: timePicker
        onAccepted: {
            root.myTime = new Date(0, 0, 0, timePicker.hour, timePicker.minute, 0, 0)
            timeButton.text = Qt.formatTime(root.myTime, "hh:mm")
        }
        hour: Qt.formatTime(root.myDate, "hh")
        minute: Qt.formatTime(root.myDate, "mm")

        fields: DateTime.Hours | DateTime.Minutes
        acceptButtonText: qsTr("Accept")
        rejectButtonText: qsTr("Reject")
    }

    Flickable {
        anchors.fill: parent
        anchors {
            topMargin: appWindow.inPortrait? UIConstants.HEADER_DEFAULT_TOP_SPACING_PORTRAIT : UIConstants.HEADER_DEFAULT_TOP_SPACING_LANDSCAPE
            margins: UIConstants.DEFAULT_MARGIN
        }
        width: parent.width
        interactive: false
        flickableDirection: Flickable.VerticalFlick
        Column {
            spacing: UIConstants.DEFAULT_MARGIN
            width: parent.width

            Item {
                width: parent.width
                height: from.height + to.height

                LocationEntry { id: from; type: qsTr("From") }

                Item {
                    id: locationSwitch
                    state: "normal"
                    anchors.right: parent.right
                    anchors.top: from.bottom
                    anchors.topMargin: 5
                    width: 50
                    height: 50

                    BorderImage {
                        anchors.fill: parent
                        visible: locationSwitchMouseArea.pressed
                        source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
                    }

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: !theme.inverted?'image://theme/icon-m-toolbar-refresh':'image://theme/icon-m-toolbar-refresh-selected'
                        opacity: locationSwitch.enabled ? 0.8 : 0.3
                    }
                    MouseArea {
                        id: locationSwitchMouseArea
                        anchors.fill: parent

                        onClicked: {
                            var templo = from.text
                            var tempcoord = from.destCoords
                            var tempindex = from.selected_favorite

                            if(from.destCoords != '') {
                                to.auto_update = true
                            }
                            if(to.destCoords != '') {
                                from.auto_update = true
                            }
                            from.model.clear()
                            from.destCoords = to.destCoords
                            from.text = to.text
                            from.selected_favorite = to.selected_favorite

                            to.model.clear()
                            to.destCoords = tempcoord
                            to.text = templo
                            to.selected_favorite = tempindex

                            locationSwitch.state = locationSwitch.state == "normal" ? "rotated" : "normal"
                        }
                    }
                    states: [
                        State {
                            name: "rotated"
                            PropertyChanges { target: locationSwitch; rotation: 180 }
                        },
                        State {
                            name: "normal"
                            PropertyChanges { target: locationSwitch; rotation: 0 }
                        }
                    ]
                    transitions: Transition {
                        RotationAnimation { duration: 300; direction: RotationAnimation.Counterclockwise }
                    }
                }

                LocationEntry { id: to; type: qsTr("To"); anchors.top: from.bottom }
            }

            Spacing {}

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Item {
                    id: timeContainer
                    height: timeButton.height
                    width: timeButton.width

                    BorderImage {
                        anchors.fill: parent
                        visible: timeMouseArea.pressed
                        source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
                    }

                    Text {
                        id: timeButton
                        font.pixelSize: MyConstants.FONT_XXXXLARGE
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                        color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
                        text: Qt.formatTime(root.myTime, "hh:mm")
                    }

                    MouseArea {
                        id: timeMouseArea
                        anchors.fill: parent
                        onClicked: {
                            timePicker.hour = Qt.formatTime(root.myTime, "hh")
                            timePicker.minute = Qt.formatTime(root.myTime, "mm")
                            timePicker.open()
                        }
                    }
                }
                SwitchStyle {
                    id: customswitch
                    switchOn: customswitch.switchOff
                }
                Item {
                    width: 150
                    height: timeType.height + timeTypeText.height
                    Switch {
                        id: timeType
                        platformStyle: customswitch
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: timeTypeText
                        anchors.top: timeType.bottom
                        anchors.horizontalCenter: timeType.horizontalCenter
                        font.pixelSize: UIConstants.FONT_LARGE
                        font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                        color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                        text: timeType.checked? qsTr("arrival") : qsTr("departure")

                        MouseArea {
                            anchors.fill: parent
                            onClicked: timeType.checked = timeType.checked? false : true
                        }
                    }
                }
            }
            Item {
                id: dateContainer
                width: dateButton.width
                height: dateButton.height
                anchors.horizontalCenter: parent.horizontalCenter

                BorderImage {
                    anchors.fill: parent
                    visible: dateMouseArea.pressed
                    source: theme.inverted ? 'image://theme/meegotouch-list-inverted-background-pressed-vertical-center': 'image://theme/meegotouch-list-background-pressed-vertical-center'
                }
                Text {
                    id: dateButton
                    height: ExtrasConstants.SIZE_BUTTON
                    font.pixelSize: MyConstants.FONT_XXLARGE
                    font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                    color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
                    text: Qt.formatDate(root.myDate, "dd. MMMM yyyy")
                }

                MouseArea {
                    id: dateMouseArea
                    anchors.fill: parent
                    onClicked: {
                        datePicker.day = Qt.formatDate(root.myDate, "dd")
                        datePicker.month = Qt.formatDate(root.myDate, "MM")
                        datePicker.year = Qt.formatDate(root.myDate, "yyyy")
                        datePicker.open()
                    }
                }
            }

            Button {
                id: timedate_now
                text: qsTr("Now")
                font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                font.pixelSize: UIConstants.FONT_SMALL
                anchors.horizontalCenter: parent.horizontalCenter
                width: 150
                height: 40
                onClicked: {
                    root.myTime = root.myDate = new Date()
                    timeButton.text = Qt.formatTime(root.myTime, "hh:mm")
                    dateButton.text = Qt.formatDate(root.myDate, "dd. MMMM yyyy")
                }
            }
        }
    }
}
