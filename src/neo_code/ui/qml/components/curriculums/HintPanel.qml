// Brilliant's "ask, don't tell" model. Hints are ordered weakest → strongest
// and revealed one at a time on request; there is deliberately no
// "show the answer" affordance, so scaffolding fades but never becomes the
// solution. Bare component — no card chrome; the host panel supplies that.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

ColumnLayout {
    id: panel
    spacing: Theme.space_sm

    property var hints: []           // ordered weakest → strongest
    property int revealed: 0         // how many are currently shown

    signal hintRevealed(int level)

    onHintsChanged: revealed = 0

    Label {
        visible: panel.hints.length === 0
        Layout.fillWidth: true
        text: "Chưa có gợi ý cho bước này"
        color: Theme.terminal_text_disabled
        font.pixelSize: Theme.font_body
        horizontalAlignment: Text.AlignHCenter
    }

    Repeater {
        model: panel.revealed
        delegate: RowLayout {
            required property int index
            Layout.fillWidth: true
            spacing: Theme.space_sm
            Label {
                text: (index + 1) + "."
                color: Theme.primary
                font.bold: true
                font.pixelSize: Theme.font_body
            }
            Label {
                Layout.fillWidth: true
                text: panel.hints[index]
                color: Theme.terminal_text
                font.pixelSize: Theme.font_body
                wrapMode: Text.Wrap
            }
        }
    }

    RowLayout {
        visible: panel.hints.length > 0 && panel.revealed < panel.hints.length
        Layout.fillWidth: true
        spacing: Theme.space_sm
        AppButton {
            variant: "secondary"
            iconName: "lightbulb"
            text: panel.revealed === 0 ? "Xem gợi ý" : "Xem gợi ý tiếp theo"
            Layout.fillWidth: true
            onClicked: { panel.revealed += 1; panel.hintRevealed(panel.revealed) }
        }
        Label {
            text: panel.revealed + "/" + panel.hints.length
            color: Theme.terminal_text_disabled
            font.pixelSize: Theme.font_caption
        }
    }

    Label {
        visible: panel.hints.length > 0 && panel.revealed >= panel.hints.length
        Layout.fillWidth: true
        text: "Bạn đã xem hết gợi ý cho bài này — cùng thử lại nhé!"
        color: Theme.terminal_text_secondary
        font.pixelSize: Theme.font_caption
        wrapMode: Text.Wrap
    }
}
