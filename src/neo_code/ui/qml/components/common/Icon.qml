// Material Design Icon glyph. Usage: C.Icon { name: "play"; size: 18; color: … }
import QtQuick

Text {
    property string name: ""
    property int size: 18
    text: name ? (Mdi[name] || "") : ""
    font.family: mdiFont
    font.pixelSize: size
    color: Theme.text
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
