import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "../common/UIConstants.js" as UIConstants

Window {
    id: appWindow
    property alias banner : banner
    property variant scaling_factor : 0.75

    Item {
        id: theme
        property bool inverted : true
    }

    InfoBanner {
        id: banner
        property bool success : false
        text: "testbanner"
        iconSource: success?"../../images/banner_green.png":"../../images/banner_red.png"
    }

    PageStack {
        id: pageStack
        toolBar: toolBar
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: toolBar.top }
    }

    ToolBar {
        id: toolBar
        anchors.bottom: appWindow.bottom
        tools: ToolBarLayout {
            id: commonTools
            ToolButton {
                flat: true
                iconSource: "toolbar-back"
                onClicked: pageStack.depth <= 1 ? Qt.quit() : pageStack.pop()
            }
        }
    }

    AboutDialog { id: about }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: qsTr("Manage favorites"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem { text: qsTr("Exception info"); onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
            MenuItem { text: qsTr("About"); onClicked: about.open() }
        }
    }

    Component.onCompleted: {
        pageStack.push(Qt.resolvedUrl("MainPage.qml"))
    }
}
