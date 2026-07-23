// REPL — dark Python console: header, output, input row with send.
// Driven by replController (owns the QProcess).
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: repl
    color: Theme.terminal_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border
    clip: true

    property alias maxLines: out.maxLines

    function append(text, kind) { out.append(text, kind) }
    function insertAtInput(text) { out.insertAtInput(text) }

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
                Icon { name: "python"; size: 16; color: Theme.primary }
                Label { text: "Python REPL"; font.bold: true; font.pixelSize: Theme.font_caption
                        color: Theme.terminal_text_secondary }
                Item { Layout.fillWidth: true }
                Button {
                    id: clearBtn
                    implicitWidth: 30; implicitHeight: 30
                    ToolTip.text: "Xoá"; ToolTip.visible: hovered; ToolTip.delay: 500
                    onClicked: out.clear()
                    contentItem: Icon { name: "broom"; size: 15; color: Theme.terminal_text_secondary
                                        anchors.centerIn: parent }
                    background: Rectangle { radius: Theme.radius_chip
                        color: clearBtn.hovered ? Theme.terminal_border : "transparent" }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
        }

        // Output + input row (the REPL controller echoes ">>> …" itself)
        ConsoleView {
            id: out
            Layout.fillWidth: true
            Layout.fillHeight: true
            maxLines: 2000
            showInput: true
            echoOnSubmit: false
            bottomRadius: repl.radius
            placeholderText: "Gõ lệnh Python…"
            onSubmitted: function(text) { replController.submit(text) }
        }
    }

    Connections {
        target: replController
        function onOutput(text, kind) { repl.append(text, kind) }
        function onCleared() { out.clear() }
    }

    onVisibleChanged: if (visible) out.focusInput()
}
