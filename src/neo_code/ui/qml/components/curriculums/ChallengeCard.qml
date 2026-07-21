// Brilliant's "problem before procedure": states the goal first, boldest.
// `instruction` is supporting context (how the underlying concept works),
// always visible but visually secondary — not a hint, and not the answer.
// Bare component — no card chrome; the host panel supplies that.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ColumnLayout {
    id: card
    spacing: Theme.space_xs

    property string lessonTitle: ""
    property string goal: ""
    property string instruction: ""

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.space_xs
        Icon { name: "target"; size: 16; color: Theme.primary }
        Label {
            text: card.lessonTitle || "Thử thách"
            color: Theme.terminal_text_secondary
            font.pixelSize: Theme.font_caption
            font.bold: true
        }
    }

    Label {
        Layout.fillWidth: true
        text: card.goal || "Chọn một bài học để bắt đầu thử thách."
        color: Theme.editor_text
        font.pixelSize: Theme.font_title
        font.bold: true
        wrapMode: Text.Wrap
        lineHeight: 1.25
    }

    Label {
        Layout.fillWidth: true
        visible: card.instruction !== ""
        text: card.instruction
        color: Theme.terminal_text_secondary
        font.pixelSize: Theme.font_body
        wrapMode: Text.Wrap
    }
}
