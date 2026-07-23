// Shared console surface: bounded scrollback, colour-coded lines, an optional
// input row. ResultConsole and ReplPanel both render through this — wrapping
// and scrollback live here so the two cannot drift apart again.
//
// Prompt handling: a program that calls input() writes its prompt with no
// trailing newline, so the runner reports it via appendPartial(). That line
// stays "pending" until either the rest of it arrives or the child types an
// answer, at which point the two are merged into one finished line — the way a
// terminal shows it.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int maxLines: 1000
    property bool showInput: false
    property bool inputEnabled: true
    property string placeholderText: ""
    // Merge the submitted text into the pending prompt line. The REPL leaves
    // this off — its controller echoes ">>> …" itself.
    property bool echoOnSubmit: true
    property int bottomRadius: 0

    signal submitted(string text)

    // Index of the line still waiting for its newline, or -1 when there is none.
    property int _partialIndex: -1

    function append(text, kind) {
        var parts = String(text).split("\n")
        for (var i = 0; i < parts.length; ++i) {
            if (parts[i].length === 0 && i === parts.length - 1) continue
            _emit(parts[i], kind)
        }
        _trim()
    }

    // The current unterminated line is exactly `text` — replace rather than
    // append, so repeated flushes of a growing prompt don't stack up.
    function appendPartial(text) {
        if (_partialIndex >= 0) {
            lines.setProperty(_partialIndex, "line", text)
        } else {
            lines.append({ "line": text, "kind": "out" })
            _partialIndex = lines.count - 1
        }
        _trim()
        view.positionViewAtEnd()
    }

    function clear() { lines.clear(); _partialIndex = -1 }
    function focusInput() { if (showInput) input.forceActiveFocus() }

    // Tap-to-insert, for panels that offer snippets while the input row is the
    // thing being typed into (Chơi's API reference in REPL mode).
    function insertAtInput(text) {
        if (!showInput) return
        input.insert(input.cursorPosition, text)
        input.forceActiveFocus()
    }

    function _emit(text, kind) {
        if (_partialIndex >= 0) {
            // The pending line finally terminated; the runner reports it whole.
            lines.setProperty(_partialIndex, "line", text)
            lines.setProperty(_partialIndex, "kind", kind)
            _partialIndex = -1
        } else {
            lines.append({ "line": text, "kind": kind })
        }
        view.positionViewAtEnd()
    }

    function _trim() {
        while (lines.count > root.maxLines) {
            lines.remove(0)
            if (_partialIndex >= 0) _partialIndex -= 1
        }
    }

    function _send() {
        var text = input.text
        if (text.length === 0) return
        input.text = ""
        if (echoOnSubmit) {
            if (_partialIndex >= 0) {
                lines.setProperty(_partialIndex, "line",
                                  lines.get(_partialIndex).line + text)
                _partialIndex = -1
            } else {
                _emit(text, "echo")
            }
            view.positionViewAtEnd()
        }
        root.submitted(text)
    }

    ListModel { id: lines }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

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

        // Input row — rounded bottom only, so it sits flush under the output
        // and matches the host panel's own bottom corners.
        Rectangle {
            visible: root.showInput
            Layout.fillWidth: true
            implicitHeight: 52
            radius: root.bottomRadius
            color: Theme.terminal_bg_alt

            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                height: parent.radius
                color: parent.color
            }
            Rectangle { anchors.top: parent.top; width: parent.width; height: 1
                        color: Theme.terminal_border }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.space_base
                anchors.rightMargin: Theme.space_base
                spacing: Theme.space_sm

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: Theme.radius_chip
                    color: Theme.terminal_well_bg
                    border.color: input.activeFocus ? Theme.primary : Theme.terminal_border
                    border.width: 1
                    opacity: root.inputEnabled ? 1.0 : 0.5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.space_md
                        anchors.rightMargin: Theme.space_sm
                        spacing: Theme.space_xs
                        Icon { name: "chevron_right"; size: 16; color: Theme.primary }
                        TextField {
                            id: input
                            Layout.fillWidth: true
                            enabled: root.inputEnabled
                            color: Theme.terminal_text
                            background: null
                            font.family: Theme.mono_family
                            font.pixelSize: settings.fontSize
                            placeholderText: root.placeholderText
                            placeholderTextColor: Theme.terminal_text_disabled
                            onAccepted: root._send()
                        }
                    }
                }

                AppButton {
                    variant: "primary"
                    iconName: "chevron_right"
                    iconSize: 20
                    implicitHeight: 36
                    enabled: root.inputEnabled && input.text.length > 0
                    onClicked: root._send()
                }
            }
        }
    }
}
