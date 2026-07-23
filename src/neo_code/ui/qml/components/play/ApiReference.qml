// The API reference that *is* the Chơi panel's content: what the arm can do,
// in the kid's language, tappable to insert.
//
// Rows rather than CodeBlockPalette's bare chips — a chip has nowhere to put
// the Vietnamese one-liner, and without it "arm.set_pitch(90)" tells a
// six-year-old nothing. Same tap-to-insert mechanic though: tapping inserts at
// the cursor and free typing still works around it.
//
// Bare component — no card chrome; the host panel (ArmPanel) supplies that.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ColumnLayout {
    id: root
    spacing: Theme.space_base

    // [{ group: "Xoay", entries: [{ label, doc, insert, kind }, …] }, …]
    property var groups: []

    signal entryTapped(string insertText)

    function kindColor(kind) {
        switch (kind) {
            case "keyword": return Theme.syn_keyword
            case "builtin": return Theme.syn_builtin
            case "string": return Theme.syn_string
            case "number": return Theme.syn_number
            default: return Theme.terminal_text
        }
    }

    // Short cue that the rows below are tappable, not just documentation.
    Label {
        Layout.fillWidth: true
        text: "Nhấn để chèn"
        color: Theme.terminal_text_disabled
        font.pixelSize: Theme.font_caption
        font.bold: true
    }

    Repeater {
        model: root.groups

        delegate: ColumnLayout {
            id: groupCol
            required property var modelData
            Layout.fillWidth: true
            spacing: Theme.space_xs

            Label {
                text: groupCol.modelData.group
                color: Theme.terminal_text_secondary
                font.pixelSize: Theme.font_caption
                font.bold: true
            }

            Repeater {
                model: groupCol.modelData.entries

                delegate: ItemDelegate {
                    id: row
                    required property var modelData
                    Layout.fillWidth: true
                    padding: Theme.space_sm
                    onClicked: root.entryTapped(row.modelData.insert)

                    scale: down ? 0.98 : 1.0
                    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

                    contentItem: ColumnLayout {
                        spacing: 2
                        Label {
                            Layout.fillWidth: true
                            text: row.modelData.label
                            color: root.kindColor(row.modelData.kind)
                            font.family: Theme.mono_family
                            font.pixelSize: Theme.font_body
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: row.modelData.doc
                            color: Theme.terminal_text_secondary
                            font.pixelSize: Theme.font_caption
                            wrapMode: Text.WordWrap
                        }
                    }

                    background: Rectangle {
                        radius: Theme.radius_chip
                        color: row.hovered ? Theme.terminal_border : "transparent"
                        border.width: 1
                        border.color: row.hovered ? root.kindColor(row.modelData.kind)
                                                  : Theme.terminal_border
                    }
                }
            }
        }
    }
}
