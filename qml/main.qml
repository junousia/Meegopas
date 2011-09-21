import QtQuick 1.1
import com.meego 1.0

PageStackWindow {
    id: appWindow
    initialPage: mainPage

    platformStyle: PageStackWindowStyle {
        id: defaultStyle
        background: 'image://theme/meegotouch-video-background'
        backgroundFillMode: Image.Stretch
    }

    MainPage{id: mainPage}

    ToolBarLayout {
        id: commonTools
        visible: true
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
            MenuItem { text: "About" }
        }
    }

}
