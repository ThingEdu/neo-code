// REPL — dark Python console: header, output, input row with send.
// Driven by replController (owns the QProcess).
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: repl
    color: Theme.terminal_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border
    clip: true

    property int maxLines: 2000

    function append(text, kind) {
        var parts = String(text).split("\n")
        for (var i = 0; i < parts.length; ++i) {
            if (parts[i].length === 0 && i === parts.length - 1) continue
            lines.append({ "line": parts[i], "kind": kind })
        }
        while (lines.count > repl.maxLines) lines.remove(0)
        view.positionViewAtEnd()
    }
    function send() {
        if (input.text.length > 0) { replController.submit(input.text); input.text = "" }
    }

    ListModel { id: lines }

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
                    onClicked: lines.clear()
                    contentItem: Icon { name: "broom"; size: 15; color: Theme.terminal_text_secondary
                                        anchors.centerIn: parent }
                    background: Rectangle { radius: Theme.radius_chip
                        color: clearBtn.hovered ? Theme.terminal_border : "transparent" }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
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
                wrapMode: Text.Wrap
                font.family: Theme.mono_family
                font.pixelSize: settings.fontSize
                text: line
                color: kind === "echo" ? Theme.primary
                       : kind === "err" ? Theme.terminal_error
                       : kind === "info" ? Theme.terminal_text_secondary
                       : Theme.terminal_text
            }
        }

        // Input row — rounded bottom only (matches the panel's own bottom
        // corners); square top so it sits flush against the output above.
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: Theme.radius_card
            color: Theme.terminal_bg_alt

            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                height: parent.radius
                color: parent.color
            }

            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Theme.terminal_border }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.space_base
                anchors.rightMargin: Theme.space_base
                spacing: Theme.space_sm

                // Prompt + field, in a recessed well
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: Theme.radius_chip
                    color: Theme.terminal_well_bg
                    border.color: input.activeFocus ? Theme.primary : Theme.terminal_border
                    border.width: 1
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.space_md
                        anchors.rightMargin: Theme.space_sm
                        spacing: Theme.space_xs
                        Icon { name: "chevron_right"; size: 16; color: Theme.primary }
                        TextField {
                            id: input
                            Layout.fillWidth: true
                            color: Theme.terminal_text
                            background: null
                            font.family: Theme.mono_family
                            font.pixelSize: settings.fontSize
                            placeholderText: "Gõ lệnh Python…"
                            placeholderTextColor: Theme.terminal_text_disabled
                            onAccepted: repl.send()
                        }
                    }
                }
                // Send
                Button {
                    id: sendBtn
                    implicitWidth: Theme.control_base; implicitHeight: 36
                    enabled: input.text.length > 0
                    scale: down ? 0.94 : 1.0
                    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                    onClicked: repl.send()
                    contentItem: Icon { name: "chevron_right"; size: 20
                                        color: sendBtn.enabled ? Theme.run_text : Theme.text_disabled
                                        anchors.centerIn: parent }
                    background: Rectangle {
                        radius: Theme.radius_chip
                        color: !sendBtn.enabled ? Theme.primary_dim
                               : sendBtn.hovered ? Theme.primary_hover : Theme.primary
                    }
                }
            }
        }
    }

    Connections {
        target: replController
        function onOutput(text, kind) { repl.append(text, kind) }
        function onCleared() { lines.clear() }
    }

    onVisibleChanged: if (visible) input.forceActiveFocus()
}
