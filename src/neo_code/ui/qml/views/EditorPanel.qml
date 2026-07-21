// Code editor: QML TextArea + reused PythonHighlighter + virtualized gutter.
// Validated in docs/specs/spike/. Exposes `text` so it drops in for the
// temporary plain TextArea with no rewiring. Qt 6.4-compatible.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    color: Theme.editor_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border
    clip: true

    property alias text: editor.text
    property int fontSize: settings.fontSize
    property int tabWidth: settings.tabWidth

    // Uniform line height holds because wrapMode is NoWrap + monospace font.
    readonly property real lineH: editor.lineCount > 0
        ? editor.contentHeight / editor.lineCount : editor.font.pixelSize * 1.4

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header — VS Code-style tab bar. The active tab is the same color as
        // the editor body below it and its bottom is square, so it reads as
        // snapped onto the editor rather than a separate floating chip.
        Rectangle {
            id: headerBar
            Layout.fillWidth: true
            implicitHeight: 36
            radius: Theme.radius_card
            color: Theme.editor_bg_alt

            // Square off the bottom — Qt 6.4 has no per-corner radius, so a
            // same-color rect over the bottom half fakes "rounded top only".
            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }

            Rectangle {
                id: fileTab
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                height: parent.height
                width: tabLabel.implicitWidth + 2 * Theme.space_base
                radius: Theme.radius_chip
                color: Theme.editor_bg

                Rectangle {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                    height: parent.radius
                    color: parent.color
                }

                Label {
                    id: tabLabel
                    anchors.centerIn: parent
                    text: files.hasFile ? files.currentPath.split("/").pop() : "Chưa đặt tên"
                    font.pixelSize: Theme.font_body
                    color: Theme.editor_text
                }
            }
        }

        Row {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ── Gutter (virtualized ListView, never a Repeater) ────────────
            // Bottom-left is the panel's real outer corner (rounded); the
            // other three corners are internal seams and stay square.
            Rectangle {
                id: gutter
                width: Math.max(46, digits.width + 20)
                height: parent.height
                radius: Theme.radius_card
                color: Theme.editor_bg
                clip: true

                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: parent.radius
                    color: parent.color
                }
                Rectangle {
                    anchors.top: parent.top; anchors.right: parent.right; anchors.bottom: parent.bottom
                    width: parent.radius
                    color: parent.color
                }

                TextMetrics {
                    id: digits
                    font: editor.font
                    text: String(Math.max(100, editor.lineCount))
                }

                ListView {
                    id: gutterView
                    anchors.fill: parent
                    anchors.topMargin: editor.topPadding
                    interactive: false
                    boundsBehavior: Flickable.StopAtBounds
                    contentY: flick.contentY
                    cacheBuffer: 0
                    model: editor.lineCount
                    delegate: Text {
                        required property int index
                        width: gutter.width - 10
                        height: panel.lineH
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font: editor.font
                        text: index + 1
                        color: index === editor.currentLine ? Theme.primary : Theme.terminal_text_secondary
                    }
                }
                Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.terminal_border }
            }

            // ── Text area ────────────────────────────────────────────────
            Flickable {
                id: flick
                width: parent.width - gutter.width
                height: parent.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {}
                ScrollBar.horizontal: ScrollBar {}

                TextArea.flickable: TextArea {
                    id: editor
                    wrapMode: TextEdit.NoWrap
                    selectByMouse: true
                    persistentSelection: true
                    color: Theme.editor_text
                    selectionColor: Theme.editor_selection
                    selectedTextColor: Theme.editor_text
                    leftPadding: 8
                    topPadding: 6
                    background: null
                    font.family: Theme.mono_family
                    font.pixelSize: panel.fontSize

                    readonly property int currentLine:
                        text.substring(0, cursorPosition).split("\n").length - 1

                    // Current-line highlight under the text
                    Rectangle {
                        z: -1
                        x: 0
                        y: editor.cursorRectangle.y
                        width: Math.max(flick.width, editor.contentWidth)
                        height: editor.cursorRectangle.height
                        color: Theme.editor_line_hl
                        visible: !editor.selectedText
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Tab) {
                            editor.insert(editor.cursorPosition, " ".repeat(panel.tabWidth))
                            event.accepted = true
                        }
                    }

                    Component.onCompleted: editorBridge.attach(editor.textDocument)
                }
            }
        }
    }
}
