import QtQuick 1.1
import com.nokia.symbian 1.0
import "../common"
import "../common/UIConstants.js" as UIConstants
import "../common/ExtrasConstants.js" as ExtrasConstants
import "../common/MyConstants.js" as MyConstants
import "../common/reittiopas.js" as Reittiopas
import "../common/favorites.js" as Favorites

Sheet {
    id: sheet
    visualParent: pageStack

    acceptButtonText: qsTr("Save")
    rejectButtonText: qsTr("Cancel")

    property alias text : sheetTextfield.text
    property string coords

    content: Item {
         anchors.fill: parent
         anchors.margins: UIConstants.DEFAULT_MARGIN

         Column {
             width: parent.width
             Header {
                 text: qsTr("Add to favorites")
             }

             Text {
                 text: qsTr("Enter name")
                 font.family: ExtrasConstants.FONT_FAMILY_LIGHT
                 font.pixelSize: MyConstants.FONT_XXLARGE * appWindow.scaling_factor
                 anchors.left: parent.left
             }
             TextField {
                 id: sheetTextfield
                 width: parent.width

                 Image {
                     anchors.right: parent.right
                     anchors.verticalCenter: parent.verticalCenter
                     source: theme.inverted ? '../../images/background.png': '../../images/background.png'
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
                     textfield.platformCloseSoftwareInputPanel()
                     parent.focus = true
                 }
             }
         }
     }
     onAccepted: {
         if(("OK" == Favorites.addFavorite(sheetTextfield.text, coords))) {
             favoritesModel.clear()
             Favorites.getFavorites(favoritesModel)
             sheetTextfield.text = ''

             appWindow.banner.success = true
             appWindow.banner.text = qsTr("Location added to favorites")
             appWindow.banner.show()
         } else {
             appWindow.banner.success = false
             appWindow.banner.text = qsTr("Location already in the favorites")
             appWindow.banner.show()
         }
     }
     onRejected: {
         sheetTextfield.text = ''
     }
}
