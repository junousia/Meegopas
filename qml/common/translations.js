var translation = {}
translation['Tarmac'] = qsTr("Tarmac")
translation['Default'] = qsTr("Default")
translation['Gravel'] = qsTr("Gravel")
translation['Shortest'] = qsTr("Shortest")

translation['Satellite'] = qsTr("Satellite")
translation['Street'] = qsTr("Street")
translation['Terrain'] = qsTr("Terrain")
translation['Hybrid'] = qsTr("Hybrid")
translation['Transit'] = qsTr("Transit")

function translate(name) {
    return translation[name]
}
