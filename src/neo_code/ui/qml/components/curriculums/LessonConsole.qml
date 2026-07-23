// Học-mode console — Expected/Result panes stacked in a vertical SplitView so
// they drag-resize against each other, same mechanic as the editor|terminal
// split. The Result pane is the shared ResultConsole; only the Expected pane
// above it is specific to Học, and it is a bindable `expectedText` with no
// backend behind it yet.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

SplitView {
    id: root
    orientation: Qt.Vertical

    property string expectedText: ""

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
                id: expectedScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                // Pin the content to the viewport width so there is no
                // horizontal scrolling for wrapping to fight with. Sizing off
                // `parent` here would be circular — the ScrollView derives its
                // contentWidth from this Text.
                contentWidth: availableWidth
                Text {
                    width: expectedScroll.availableWidth - 2 * Theme.space_base
                    x: Theme.space_base; topPadding: Theme.space_sm; bottomPadding: Theme.space_sm
                    text: root.expectedText
                    wrapMode: Text.Wrap
                    font.family: Theme.mono_family
                    font.pixelSize: settings.fontSize
                    color: Theme.terminal_text
                }
            }
        }
    }

    // ── Result pane — the frame tints green/red with the run's outcome,
    // which is why Học needs no "✓ Hoàn thành" line saying the same thing. ──
    ResultConsole {
        SplitView.fillHeight: true
        SplitView.minimumHeight: 90
        stateBorder: true
        headerTooltip: "Kết quả của bạn"
    }
}
