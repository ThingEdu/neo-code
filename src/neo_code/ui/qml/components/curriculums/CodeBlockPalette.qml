// Grasshopper's tap-to-insert mechanic, combined with (not replacing) free
// typing: tapping a chip inserts its snippet at the cursor in whichever
// editor is listening; the learner can keep typing normally around it.
// Chips are colored by `kind` to match the editor's own syntax highlighting.
// Bare component — no card chrome; the host panel (LessonSidebar) supplies that.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Flow {
    id: root
    spacing: Theme.space_sm

    // [{ label: "print()", insert: "print()", kind: "builtin" }, ...]
    property var blocks: []

    signal blockTapped(string insertText)

    function kindColor(kind) {
        switch (kind) {
            case "keyword": return Theme.syn_keyword
            case "builtin": return Theme.syn_builtin
            case "string": return Theme.syn_string
            case "number": return Theme.syn_number
            default: return Theme.terminal_text
        }
    }

    // Short cue that the chips below are tappable, not just labels.
    Label {
        visible: root.blocks.length > 0
        width: root.width
        text: "Nhấn để chèn"
        color: Theme.terminal_text_disabled
        font.pixelSize: Theme.font_caption
        font.bold: true
    }

    Label {
        visible: root.blocks.length === 0
        width: root.width
        text: "Chưa có khối lệnh cho bước này"
        color: Theme.terminal_text_disabled
        font.pixelSize: Theme.font_body
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        model: root.blocks
        delegate: Button {
            id: chip
            required property var modelData
            implicitHeight: Theme.control_sm
            leftPadding: Theme.space_base; rightPadding: Theme.space_base
            onClicked: root.blockTapped(chip.modelData.insert)
            scale: down ? 0.95 : 1.0
            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            contentItem: Label {
                text: chip.modelData.label
                color: root.kindColor(chip.modelData.kind)
                font.family: Theme.mono_family
                font.pixelSize: Theme.font_body
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                readonly property color kindColor: root.kindColor(chip.modelData.kind)
                radius: Theme.radius_pill
                color: Qt.rgba(kindColor.r, kindColor.g, kindColor.b, chip.hovered ? 0.22 : 0.12)
                border.width: 1
                border.color: kindColor
            }
        }
    }
}
