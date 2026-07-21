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
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                Text {
                    width: parent.width - 2 * Theme.space_base
                    x: Theme.space_base; topPadding: Theme.space_sm; bottomPadding: Theme.space_sm
                    text: root.expectedText
                    wrapMode: Text.NoWrap
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

        property int maxLines: 2000
        function append(text, kind) {
            var parts = String(text).split("\n")
            for (var i = 0; i < parts.length; ++i) {
                if (parts[i].length === 0 && i === parts.length - 1) continue
                lines.append({ "line": parts[i], "kind": kind })
            }
            while (lines.count > maxLines) lines.remove(0)
            resultView.positionViewAtEnd()
        }
        function clear() { lines.clear() }
        ListModel { id: lines }

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
                    Icon {
                        name: "code_tags"; size: 15; color: root.stateColor(root.state)
                        ToolTip.text: "Kết quả của bạn"; ToolTip.visible: hoverHandler2.hovered; ToolTip.delay: 500
                        HoverHandler { id: hoverHandler2 }
                    }
                }
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
            }
            ListView {
                id: resultView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: lines
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                leftMargin: Theme.space_base
                topMargin: Theme.space_sm
                bottomMargin: Theme.space_sm
                delegate: Text {
                    required property string line
                    required property string kind
                    width: resultView.width - 2 * Theme.space_base
                    wrapMode: Text.NoWrap
                    font.family: Theme.mono_family
                    font.pixelSize: settings.fontSize
                    text: line
                    color: kind === "err" ? Theme.terminal_error
                           : kind === "info" ? Theme.terminal_text_secondary
                           : Theme.terminal_text
                }
            }
        }
    }

    Connections {
        target: signalBus
        function onExecutionStarted() { resultConsole.clear(); root.state = "running" }
        function onStdoutReceived(line) { resultConsole.append(line, "out") }
        function onStderrReceived(line) { resultConsole.append(line, "err") }
        function onExecutionFinished(code) { root.state = code === 0 ? "success" : "fail" }
    }
}
