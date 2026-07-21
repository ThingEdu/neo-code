// Console — dark, integrated output panel with a header + clear action.
// Bounded, colour-coded, driven by the signal bridge.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: term
    color: Theme.terminal_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border
    clip: true

    property alias maxLines: out.maxLines

    function append(text, kind) { out.append(text, kind) }
    function clear() { out.clear() }

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
                Icon { name: "code_tags"; size: 15; color: Theme.terminal_text_secondary }
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
            bottomRadius: term.radius
            placeholderText: execution.running ? "Nhập câu trả lời rồi nhấn Enter…"
                                               : "Chạy chương trình để nhập"
            onSubmitted: function(text) { execution.sendInput(text) }
        }
    }

    Connections {
        target: signalBus
        function onExecutionStarted() { out.clear(); out.append("Đang chạy…", "info") }
        function onStdoutReceived(line) { out.append(line, "out") }
        // An unterminated line means the program is asking for something.
        function onStdoutPartial(text) { out.appendPartial(text); out.focusInput() }
        function onStderrReceived(line) { out.append(line, "err") }
        function onExecutionFinished(code) {
            out.append(code === 0 ? "✓ Hoàn thành" : "✕ Kết thúc (mã " + code + ")",
                       code === 0 ? "info" : "err")
        }
    }
}
