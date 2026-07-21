// Học-mode lesson list for the current topic — a flat list of tappable rows
// (state icon + title). Kept deliberately plain: no connector trail/circles —
// that added visual complexity without helping the student navigate any
// better than a list does. Revisit only if a real need shows up.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ColumnLayout {
    id: root
    spacing: Theme.space_xs

    // [{ id, title, state }] — state: "completed" | "current" | "available" | "locked"
    property var nodes: []

    signal nodeSelected(string nodeId)

    function nodeIcon(state) {
        switch (state) {
            case "completed": return "check_filled"
            case "current": return "play"
            case "locked": return "lock"
            default: return "circle_outline"
        }
    }
    function nodeColor(state) {
        switch (state) {
            case "completed": return Theme.primary
            case "current": return Theme.primary
            case "locked": return Theme.terminal_text_disabled
            default: return Theme.terminal_text_secondary
        }
    }

    Label {
        visible: root.nodes.length === 0
        Layout.fillWidth: true
        Layout.margins: Theme.space_base
        text: "Chưa có bài học nào trên lộ trình này"
        color: Theme.terminal_text_disabled
        font.pixelSize: Theme.font_body
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        model: root.nodes
        delegate: AbstractButton {
            id: row
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: Theme.control_base
            enabled: row.modelData.state !== "locked"
            onClicked: root.nodeSelected(row.modelData.id)

            background: Rectangle {
                radius: Theme.radius_chip
                color: row.hovered ? Theme.editor_bg_alt : "transparent"
            }
            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.space_sm
                anchors.rightMargin: Theme.space_sm
                spacing: Theme.space_sm
                Icon {
                    name: root.nodeIcon(row.modelData.state)
                    size: 18
                    color: root.nodeColor(row.modelData.state)
                }
                Label {
                    Layout.fillWidth: true
                    text: row.modelData.title
                    color: row.modelData.state === "locked" ? Theme.terminal_text_disabled : Theme.editor_text
                    font.pixelSize: Theme.font_body
                    font.bold: row.modelData.state === "current"
                    elide: Text.ElideRight
                }
            }
        }
    }
}
