// Chơi-mode side panel — connection state, a one-line "what to do", and the
// API reference. No goal, no hints, no grading: this mode is a sandbox, so the
// panel's whole job is to say what the arm can do and then stay out of the way.
//
// Same card frame, header and collapse mechanic as LessonSidebar. It stays
// visible in REPL mode, where the API list is most useful.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Rectangle {
    id: panel
    color: Theme.editor_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border
    clip: true

    property bool collapsed: false
    property var activity: null

    signal entryTapped(string insertText)

    readonly property string _statusIcon:
          playController.status === "connected" ? "lan_connect"
        : playController.status === "connecting" ? "lan_pending"
        : "lan_disconnect"

    readonly property color _statusColor:
          playController.status === "connected" ? Theme.terminal_success
        : playController.status === "connecting" ? Theme.terminal_text_secondary
        : Theme.syn_string

    // ── Header — rounded top only (matches every other panel). ─────────────
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: 38
        radius: Theme.radius_card
        color: Theme.editor_bg_alt

        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            height: parent.radius
            color: parent.color
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.space_base
            anchors.rightMargin: Theme.space_sm
            spacing: Theme.space_xs

            Icon { name: "robot_industrial"; size: 15; color: Theme.terminal_text_secondary
                   visible: !panel.collapsed }
            Label {
                visible: !panel.collapsed
                Layout.fillWidth: true
                text: panel.activity ? panel.activity.title : "Cánh tay robot"
                elide: Text.ElideRight
                color: Theme.terminal_text_secondary
                font.pixelSize: Theme.font_caption
                font.bold: true
            }
            Button {
                id: collapseBtn
                implicitWidth: 30; implicitHeight: 30
                ToolTip.text: panel.collapsed ? "Mở rộng" : "Thu gọn"; ToolTip.visible: hovered; ToolTip.delay: 500
                onClicked: panel.collapsed = !panel.collapsed
                contentItem: Icon {
                    name: panel.collapsed ? "chevron_right" : "chevron_left"
                    size: 15; color: Theme.terminal_text_secondary
                    anchors.centerIn: parent
                }
                background: Rectangle { radius: Theme.radius_chip
                    color: collapseBtn.hovered ? Theme.terminal_border : "transparent" }
            }
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
    }

    // ── Collapsed rail — icon only, click anywhere to expand. ──────────────
    ColumnLayout {
        anchors.top: headerBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: Theme.space_base
        visible: panel.collapsed
        Icon { name: "robot_industrial"; size: 20; color: Theme.terminal_text_secondary
               Layout.alignment: Qt.AlignHCenter }
    }
    MouseArea { anchors.fill: parent; anchors.topMargin: headerBar.height; visible: panel.collapsed
                onClicked: panel.collapsed = false }

    // ── Body ───────────────────────────────────────────────────────────────
    ScrollView {
        id: body
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.space_base
        clip: true
        visible: !panel.collapsed

        ColumnLayout {
            // NOT `width: parent.width` — ScrollView derives its content width
            // from the child's implicit width, so that binding is circular.
            width: body.availableWidth
            spacing: Theme.space_base

            // Connection chip. "Chế độ mô phỏng" is a normal state, not an
            // error: with no board plugged in the code still runs and the
            // gauges still move.
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space_xs
                Icon { name: panel._statusIcon; size: 14; color: panel._statusColor }
                Label {
                    Layout.fillWidth: true
                    text: playController.statusDetail
                    color: panel._statusColor
                    font.pixelSize: Theme.font_caption
                    font.bold: true
                    elide: Text.ElideRight
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.terminal_border }

            Label {
                Layout.fillWidth: true
                text: panel.activity ? panel.activity.instruction : ""
                color: Theme.editor_text
                font.pixelSize: Theme.font_body
                wrapMode: Text.WordWrap
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.terminal_border }

            ApiReference {
                Layout.fillWidth: true
                groups: panel.activity ? panel.activity.api : []
                onEntryTapped: function(insertText) { panel.entryTapped(insertText) }
            }
        }
    }
}
