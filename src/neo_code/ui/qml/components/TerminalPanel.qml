// Console — light, integrated output panel with a header + clear action.
// Bounded, colour-coded, driven by the signal bridge.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: term
    color: Theme.terminal_bg

    property int maxLines: 2000

    function append(text, kind) {
        var parts = String(text).split("\n")
        for (var i = 0; i < parts.length; ++i) {
            if (parts[i].length === 0 && i === parts.length - 1) continue
            lines.append({ "line": parts[i], "kind": kind })
        }
        while (lines.count > term.maxLines) lines.remove(0)
        view.positionViewAtEnd()
    }
    function clear() { lines.clear() }

    ListModel { id: lines }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 38
            color: Theme.panel_bg
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.space_base
                anchors.rightMargin: Theme.space_sm
                spacing: Theme.space_xs
                Icon { name: "code_tags"; size: 15; color: Theme.text_secondary }
                Label { text: "Kết quả"; font.bold: true; font.pixelSize: Theme.font_caption
                        color: Theme.text_secondary }
                Item { Layout.fillWidth: true }
                Button {
                    id: clearBtn
                    implicitWidth: 30; implicitHeight: 30
                    ToolTip.text: "Xoá kết quả"; ToolTip.visible: hovered; ToolTip.delay: 500
                    onClicked: term.clear()
                    contentItem: Icon { name: "broom"; size: 15; color: Theme.text_secondary
                                        anchors.centerIn: parent }
                    background: Rectangle { radius: Theme.radius_chip
                        color: clearBtn.hovered ? Theme.surface_alt : "transparent" }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
        }

        // Output
        ListView {
            id: view
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
                width: view.width - 2 * Theme.space_base
                wrapMode: Text.NoWrap
                font.family: Theme.mono_family
                font.pixelSize: Theme.font_body
                text: line
                color: kind === "err" ? Theme.terminal_error
                       : kind === "info" ? Theme.text_secondary
                       : Theme.terminal_text
            }
        }
    }

    Connections {
        target: signalBus
        function onExecutionStarted() { term.clear(); term.append("Đang chạy…", "info") }
        function onStdoutReceived(line) { term.append(line, "out") }
        function onStderrReceived(line) { term.append(line, "err") }
        function onExecutionFinished(code) {
            term.append(code === 0 ? "✓ Hoàn thành" : "✕ Kết thúc (mã " + code + ")",
                        code === 0 ? "info" : "err")
        }
    }
}
