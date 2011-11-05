import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

PageStackWindow {
    id: appWindow
    initialPage: mainPage
    property alias banner : banner
    property variant scaling_factor : 1

    platformStyle: PageStackWindowStyle {
        id: defaultStyle
        background: theme.inverted?'image://theme/meegotouch-video-background':null
        backgroundFillMode: Image.Stretch
    }

    MainPage{id: mainPage}
    AboutDialog { id: about }

    InfoBanner {
        id: banner
        property bool success : false
        visible: true
        iconSource: success ? '../../images/banner_green.png':'../../images/banner_red.png'
        z: 500
        y: 40
    }

    ToolBarLayout {
        id: commonTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: qsTr("Manage favorites"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem { text: qsTr("About"); onClicked: about.open() }
        }
    }
}
