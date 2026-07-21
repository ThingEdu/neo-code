// Học-mode topic list — the entry screen before any path map. Topics are
// never locked (unlike lessons within one), so this stays a flat tappable
// list rather than reusing LessonPathMap's trail. Bare component — no card
// chrome; the host panel supplies that.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ColumnLayout {
    id: root
    spacing: Theme.space_xs

    property var topics: []   // [{ id, title, icon }]
    signal topicSelected(string topicId)

    Label {
        visible: root.topics.length === 0
        Layout.fillWidth: true
        Layout.margins: Theme.space_base
        text: "Chưa có chủ đề nào"
        color: Theme.terminal_text_disabled
        font.pixelSize: Theme.font_body
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        model: root.topics
        delegate: AbstractButton {
            id: row
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: Theme.control_base
            onClicked: root.topicSelected(row.modelData.id)
            scale: down ? 0.98 : 1.0
            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

            background: Rectangle {
                radius: Theme.radius_chip
                color: row.hovered ? Theme.editor_bg_alt : "transparent"
            }
            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.space_sm
                anchors.rightMargin: Theme.space_sm
                spacing: Theme.space_sm
                Icon { name: row.modelData.icon || "puzzle"; size: 18; color: Theme.primary }
                Label {
                    Layout.fillWidth: true
                    text: row.modelData.title
                    color: Theme.editor_text
                    font.pixelSize: Theme.font_body
                    font.bold: true
                    elide: Text.ElideRight
                }
                Icon { name: "chevron_right"; size: 16; color: Theme.terminal_text_disabled }
            }
        }
    }
}
