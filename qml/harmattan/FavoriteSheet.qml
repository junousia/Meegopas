import QtQuick 1.1
import com.nokia.meego 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/favorites.js" as Favorites

Sheet {
    visualParent: pageStack

    acceptButtonText: qsTr("Save")
    rejectButtonText: qsTr("Cancel")

    property alias text : sheetTextfield.text
    property string coords
    property bool is_add_favorites : false

    content: Item {
         anchors.fill: parent
         anchors.margins: UIConstants.DEFAULT_MARGIN

         Column {
             width: parent.width
             Header {
                 text: qsTr("Add to favorites")
             }

             Spacing {}

             Label {
                 text: qsTr("Enter name")
                 font.pixelSize: MyConstants.FONT_XXLARGE
                 anchors.left: parent.left
             }
             TextField {
                 id: sheetTextfield
                 width: parent.width

                 Image {
                     anchors.right: parent.right
                     anchors.verticalCenter: parent.verticalCenter
                     source: 'image://theme/icon-m-input-clear'
                     visible: (sheetTextfield.activeFocus)
                     opacity: 0.8
                     MouseArea {
                         anchors.fill: parent
                         onClicked: {
                             sheetTextfield.text = ''
                         }
                     }
                 }

                 Keys.onReturnPressed: {
                     sheetTextfield.platformCloseSoftwareInputPanel()
                     parent.focus = true
                 }
             }
         }
     }
     onAccepted: {
         if(sheetTextfield.text != '') {
             if(("OK" == Favorites.addFavorite(sheetTextfield.text, coords))) {
                 favoritesModel.clear()
                 Favorites.getFavorites(favoritesModel)
                 sheetTextfield.text = ''

                 if(is_add_favorites)
                     favorites_page.textfield.clear()

                 appWindow.banner.success = true
                 appWindow.banner.text = qsTr("Location added to favorites")
                 appWindow.banner.show()
             } else {
                 appWindow.banner.success = false
                 appWindow.banner.text = qsTr("Location already in the favorites")
                 appWindow.banner.show()
             }
         }
         else {
             appWindow.banner.success = false
             appWindow.banner.text = qsTr("Name cannot be empty")
             appWindow.banner.show()
         }
     }
     onRejected: {
         sheetTextfield.text = ''
     }
}
