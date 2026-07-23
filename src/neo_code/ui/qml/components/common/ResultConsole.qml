// The app's one output console: header bar, bounded scrollback, an input row
// that answers input() prompts, and the signalBus wiring that fills it.
//
// Sáng tạo, Học and Chơi all render their results through this. They used to be
// three near-identical copies, which is exactly how the wrapping and prompt
// handling drifted apart before ConsoleView was extracted; this is the same
// move one level up.
//
// Two knobs cover the differences between them:
//   showStatusLines — "Đang chạy…" / "✓ Hoàn thành" bookends (Sáng tạo, Chơi).
//                     Học leaves them off; its border already reports outcome.
//   stateBorder     — tint the frame by run outcome (Học).
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: Theme.terminal_bg
    radius: Theme.radius_card
    border.width: root.stateBorder && root.runState !== "none" ? 2 : 1
    border.color: root.stateBorder ? root.stateColor(root.runState) : Theme.terminal_border
    clip: true

    property alias maxLines: out.maxLines
    property bool showStatusLines: false
    property bool stateBorder: false
    property string headerIcon: "code_tags"
    property string headerTooltip: "Kết quả"
    // none | running | success | fail
    property string runState: "none"

    function append(text, kind) { out.append(text, kind) }
    function clear() { out.clear() }

    function stateColor(s) {
        return s === "success" ? Theme.terminal_success
             : s === "fail" ? Theme.terminal_error
             : Theme.terminal_border
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header — rounded top only (matches the panel's own top corners);
        // square bottom so it sits flush against the output list below.
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 38
            radius: Theme.radius_card
            color: Theme.terminal_bg_alt

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

                Icon {
                    name: root.headerIcon
                    size: 15
                    color: root.stateBorder ? root.stateColor(root.runState) : Theme.terminal_text_secondary
                    ToolTip.text: root.headerTooltip
                    ToolTip.visible: headerHover.hovered && root.headerTooltip !== ""
                    ToolTip.delay: 500
                    HoverHandler { id: headerHover }
                }
                Item { Layout.fillWidth: true }
                Button {
                    id: clearBtn
                    implicitWidth: 30; implicitHeight: 30
                    ToolTip.text: "Xoá kết quả"; ToolTip.visible: hovered; ToolTip.delay: 500
                    onClicked: out.clear()
                    contentItem: Icon { name: "broom"; size: 15; color: Theme.terminal_text_secondary
                                        anchors.centerIn: parent }
                    background: Rectangle { radius: Theme.radius_chip
                        color: clearBtn.hovered ? Theme.terminal_border : "transparent" }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
        }

        // Output + the input row that answers input() prompts
        ConsoleView {
            id: out
            Layout.fillWidth: true
            Layout.fillHeight: true
            maxLines: 1000
            showInput: true
            inputEnabled: execution.running
            bottomRadius: root.radius
            placeholderText: execution.running ? "Nhập câu trả lời rồi nhấn Enter…"
                                               : "Chạy chương trình để nhập"
            onSubmitted: function(text) { execution.sendInput(text) }
        }
    }

    Connections {
        target: signalBus
        function onExecutionStarted() {
            out.clear()
            root.runState = "running"
            if (root.showStatusLines) out.append("Đang chạy…", "info")
        }
        function onStdoutReceived(line) { out.append(line, "out") }
        // An unterminated line means the program is asking for something.
        function onStdoutPartial(text) { out.appendPartial(text); out.focusInput() }
        function onStderrReceived(line) { out.append(line, "err") }
        function onExecutionFinished(code) {
            root.runState = code === 0 ? "success" : "fail"
            if (root.showStatusLines)
                out.append(code === 0 ? "✓ Hoàn thành" : "✕ Kết thúc (mã " + code + ")",
                           code === 0 ? "info" : "err")
        }
    }
}
