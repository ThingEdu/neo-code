// Học-mode console — Expected/Result panes stacked in a vertical SplitView so
// they drag-resize against each other, same mechanic as the editor|terminal
// split. Pure UI shell: the Result pane mirrors live execution output via
// signalBus (the same generic wiring TerminalPanel uses); the Expected pane
// is just a bindable `expectedText` with no backend behind it yet.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

SplitView {
    id: root
    orientation: Qt.Vertical

    property string expectedText: ""
    property string state: "none"   // none | running | success | fail

    function stateColor(s) {
        return s === "success" ? Theme.terminal_success
             : s === "fail" ? Theme.terminal_error
             : Theme.terminal_border
    }

    handle: Item {
        implicitWidth: Theme.space_sm
        implicitHeight: Theme.space_sm
    }

    // ── Expected pane ────────────────────────────────────────────────────
    Rectangle {
        SplitView.preferredHeight: 160
        SplitView.minimumHeight: 90
        color: Theme.terminal_bg
        radius: Theme.radius_card
        border.width: 1
        border.color: Theme.terminal_border
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: Theme.radius_card
                color: Theme.terminal_bg_alt
                Rectangle {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                    height: parent.radius; color: parent.color
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space_base
                    anchors.rightMargin: Theme.space_sm
                    Icon {
                        name: "target"; size: 15; color: Theme.terminal_text_secondary
                        ToolTip.text: "Kết quả mong đợi"; ToolTip.visible: hoverHandler.hovered; ToolTip.delay: 500
                        HoverHandler { id: hoverHandler }
                    }
                }
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
            }
            ScrollView {
                id: expectedScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                // Pin the content to the viewport width so there is no
                // horizontal scrolling for wrapping to fight with. Sizing off
                // `parent` here would be circular — the ScrollView derives its
                // contentWidth from this Text.
                contentWidth: availableWidth
                Text {
                    width: expectedScroll.availableWidth - 2 * Theme.space_base
                    x: Theme.space_base; topPadding: Theme.space_sm; bottomPadding: Theme.space_sm
                    text: root.expectedText
                    wrapMode: Text.Wrap
                    font.family: Theme.mono_family
                    font.pixelSize: settings.fontSize
                    color: Theme.terminal_text
                }
            }
        }
    }

    // ── Result pane ─────────────────────────────────────────────────────
    Rectangle {
        id: resultConsole
        SplitView.fillHeight: true
        SplitView.minimumHeight: 90
        color: Theme.terminal_bg
        radius: Theme.radius_card
        border.width: root.state === "none" ? 1 : 2
        border.color: root.stateColor(root.state)
        clip: true

        function append(text, kind) { out.append(text, kind) }
        function clear() { out.clear() }

        ColumnLayout {
            anchors.fill: parent
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 38
                radius: Theme.radius_card
                color: Theme.terminal_bg_alt
                Rectangle {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                    height: parent.radius; color: parent.color
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space_base
                    anchors.rightMargin: Theme.space_sm
                    spacing: Theme.space_xs
                    Icon {
                        name: "code_tags"; size: 15; color: root.stateColor(root.state)
                        ToolTip.text: "Kết quả của bạn"; ToolTip.visible: hoverHandler2.hovered; ToolTip.delay: 500
                        HoverHandler { id: hoverHandler2 }
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        id: clearResultBtn
                        implicitWidth: 30; implicitHeight: 30
                        ToolTip.text: "Xoá kết quả"; ToolTip.visible: hovered; ToolTip.delay: 500
                        onClicked: resultConsole.clear()
                        contentItem: Icon { name: "broom"; size: 15; color: Theme.terminal_text_secondary
                                            anchors.centerIn: parent }
                        background: Rectangle { radius: Theme.radius_chip
                            color: clearResultBtn.hovered ? Theme.terminal_border : "transparent" }
                    }
                }
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
            }
            ConsoleView {
                id: out
                Layout.fillWidth: true
                Layout.fillHeight: true
                maxLines: 1000
                showInput: true
                inputEnabled: execution.running
                bottomRadius: resultConsole.radius
                placeholderText: execution.running ? "Nhập câu trả lời rồi nhấn Enter…"
                                                   : "Chạy chương trình để nhập"
                onSubmitted: function(text) { execution.sendInput(text) }
            }
        }
    }

    Connections {
        target: signalBus
        function onExecutionStarted() { out.clear(); root.state = "running" }
        function onStdoutReceived(line) { out.append(line, "out") }
        function onStdoutPartial(text) { out.appendPartial(text); out.focusInput() }
        function onStderrReceived(line) { out.append(line, "err") }
        function onExecutionFinished(code) { root.state = code === 0 ? "success" : "fail" }
    }
}
