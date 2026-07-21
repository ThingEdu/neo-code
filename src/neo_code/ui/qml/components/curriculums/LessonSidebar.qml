// Học-mode curriculum sidebar — the one container for the Học UI. Three
// views driven by an explicit `view` prop (not inferred from nullability,
// so it stays correct when bound to a real controller): topic list
// (Brilliant's course list) -> lesson path (Grasshopper) -> challenge detail
// (goal/hints/blocks, all bare sub-components sharing this one card frame,
// separated by hairlines instead of nested panels).
// Collapsible/resizable; styled to match the dark IDE canvas.
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
    property string view: "topics"        // topics | path | challenge
    property var topics: []               // [{ id, title, icon }] for TopicList
    property string topicTitle: ""        // header text while view === "path"
    property var nodes: []                // [{ id, title, state }] for LessonPathMap
    property var currentChallenge: null   // { title, goal, hints, blocks } or null

    signal topicSelected(string topicId)
    signal nodeSelected(string nodeId)
    signal blockTapped(string insertText)
    signal hintRevealed(int level)
    signal backRequested()

    readonly property string _headerTitle: panel.view === "challenge"
            ? (panel.currentChallenge ? panel.currentChallenge.title : "Bài học")
            : panel.view === "path" ? (panel.topicTitle || "Bài học")
            : "Bài học"

    // ── Header — rounded top only (matches TerminalPanel/EditorPanel). ─────
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

            AppButton {
                visible: !panel.collapsed && panel.view !== "topics"
                variant: "utility"; iconName: "arrow_left"
                implicitHeight: Theme.control_sm
                iconSize: 15
                onClicked: panel.backRequested()
            }
            Icon { name: "book_open"; size: 15; color: Theme.terminal_text_secondary; visible: !panel.collapsed }
            Label {
                visible: !panel.collapsed
                Layout.fillWidth: true
                text: panel._headerTitle
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
        Icon { name: "book_open"; size: 20; color: Theme.terminal_text_secondary; Layout.alignment: Qt.AlignHCenter }
    }
    MouseArea { anchors.fill: parent; anchors.topMargin: headerBar.height; visible: panel.collapsed
                onClicked: panel.collapsed = false }

    // ── Body — topic list, path view, or challenge detail. ─────────────────
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
            // from the child's implicit width, so that binding is circular and
            // settles on a near-arbitrary value. Bind to the ScrollView itself.
            width: body.availableWidth
            spacing: Theme.space_base

            TopicList {
                Layout.fillWidth: true
                visible: panel.view === "topics"
                topics: panel.topics
                onTopicSelected: function(topicId) { panel.topicSelected(topicId) }
            }

            LessonPathMap {
                Layout.fillWidth: true
                visible: panel.view === "path"
                nodes: panel.nodes
                onNodeSelected: function(nodeId) { panel.nodeSelected(nodeId) }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: panel.view === "challenge"
                spacing: Theme.space_base

                ChallengeCard {
                    Layout.fillWidth: true
                    lessonTitle: panel.currentChallenge ? panel.currentChallenge.title : ""
                    goal: panel.currentChallenge ? panel.currentChallenge.goal : ""
                    instruction: panel.currentChallenge ? panel.currentChallenge.instruction : ""
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.terminal_border }
                HintPanel {
                    Layout.fillWidth: true
                    hints: panel.currentChallenge ? panel.currentChallenge.hints : []
                    onHintRevealed: function(level) { panel.hintRevealed(level) }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.terminal_border }
                CodeBlockPalette {
                    Layout.fillWidth: true
                    blocks: panel.currentChallenge ? panel.currentChallenge.blocks : []
                    onBlockTapped: function(insertText) { panel.blockTapped(insertText) }
                }
            }
        }
    }
}
