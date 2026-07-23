// Where the arm actually is — the top half of Chơi's right column, in the slot
// Học gives to its Expected pane.
//
// This is the feedback loop of the whole mode: type a command, watch the bar
// move. It stays visible in REPL mode too, which is why the result console
// gives up the space instead.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

Rectangle {
    id: root
    color: Theme.terminal_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border
    clip: true

    component JointGauge: ColumnLayout {
        id: gauge
        required property string label
        required property string iconName
        required property int angle
        Layout.fillWidth: true
        spacing: Theme.space_xs

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space_xs
            Icon { name: gauge.iconName; size: 14; color: Theme.terminal_text_secondary }
            Label {
                Layout.fillWidth: true
                text: gauge.label
                color: Theme.terminal_text_secondary
                font.pixelSize: Theme.font_caption
                font.bold: true
            }
            Label {
                text: gauge.angle + "°"
                color: Theme.terminal_text
                font.family: Theme.mono_family
                font.pixelSize: Theme.font_body
            }
        }

        // 0–180 mapped across the full width.
        Rectangle {
            id: track
            Layout.fillWidth: true
            implicitHeight: 8
            radius: height / 2
            color: Theme.terminal_well_bg
            Rectangle {
                width: track.width * (gauge.angle / 180)
                height: track.height
                radius: track.radius
                color: Theme.primary
                Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header — rounded top only, square bottom, same as every other panel.
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
                spacing: Theme.space_xs
                Icon {
                    name: "robot_industrial"; size: 15; color: Theme.terminal_text_secondary
                    ToolTip.text: "Vị trí cánh tay"; ToolTip.visible: statusHover.hovered; ToolTip.delay: 500
                    HoverHandler { id: statusHover }
                }
                Item { Layout.fillWidth: true }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.terminal_border }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.space_base
            spacing: Theme.space_base

            JointGauge {
                label: "Xoay"; iconName: "rotate_left"
                angle: playController.yaw
            }
            JointGauge {
                label: "Nâng hạ"; iconName: "arrow_up_bold"
                angle: playController.pitch
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.space_xs
                Icon { name: "hand_back_left"; size: 14; color: Theme.terminal_text_secondary }
                Label {
                    Layout.fillWidth: true
                    text: "Kẹp"
                    color: Theme.terminal_text_secondary
                    font.pixelSize: Theme.font_caption
                    font.bold: true
                }
                Label {
                    text: playController.grabbed ? "đang kẹp" : "đang mở"
                    color: playController.grabbed ? Theme.primary : Theme.terminal_text
                    font.pixelSize: Theme.font_body
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
