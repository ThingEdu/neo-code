// Top toolbar — persistent across the home screen and the IDE canvas.
// homeMode: true shows the brand lockup; false shows file ops + Run/Stop +
// REPL toggle. Settings is always visible. Neo Play design: MDI icons,
// generous padding, tactile AppButtons.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bar
    implicitHeight: 60
    color: Theme.editor_bg
    radius: Theme.radius_card
    border.width: 1
    border.color: Theme.terminal_border

    property bool running: false
    property bool replActive: false
    property bool homeMode: false

    signal backRequested()
    signal newRequested()
    signal openRequested()
    signal saveRequested()
    signal runRequested()
    signal stopRequested()
    signal replToggled(bool active)
    signal settingsRequested()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.space_base
        anchors.rightMargin: Theme.space_base
        spacing: Theme.space_sm

        // Brand lockup — home screen only, replaces the editor's back/file/run controls
        RowLayout {
            visible: bar.homeMode
            spacing: Theme.space_sm
            Rectangle {
                width: 40; height: 40
                radius: width * 0.26
                color: Theme.editor_bg_alt
                border.width: 1
                border.color: Theme.terminal_border
                Icon { anchors.centerIn: parent; name: "code_tags"; size: 20; color: Theme.primary }
            }
            Label {
                text: "NEO Code"
                font.bold: true
                font.pixelSize: 18
                color: Theme.editor_text
            }
        }

        AppButton {
            visible: !bar.homeMode; variant: "utility"; iconName: "arrow_left"
            onClicked: bar.backRequested()
            ToolTip.text: "Quay lại"; ToolTip.visible: hovered; ToolTip.delay: 500
        }

        Rectangle { visible: !bar.homeMode; Layout.preferredWidth: 1; Layout.preferredHeight: 26; color: Theme.terminal_border }

        AppButton {
            visible: !bar.homeMode; variant: "utility"; iconName: "file_plus"
            onClicked: bar.newRequested()
            ToolTip.text: "Mới"; ToolTip.visible: hovered; ToolTip.delay: 500
        }
        AppButton {
            visible: !bar.homeMode; variant: "utility"; iconName: "folder_open"
            onClicked: bar.openRequested()
            ToolTip.text: "Mở"; ToolTip.visible: hovered; ToolTip.delay: 500
        }
        AppButton {
            visible: !bar.homeMode; variant: "utility"; iconName: "save"
            onClicked: bar.saveRequested()
            ToolTip.text: "Lưu"; ToolTip.visible: hovered; ToolTip.delay: 500
        }

        Rectangle { visible: !bar.homeMode; Layout.preferredWidth: 1; Layout.preferredHeight: 26; color: Theme.terminal_border }

        AppButton {
            visible: !bar.homeMode
            variant: "primary"; iconName: "play"
            enabled: !bar.running
            onClicked: bar.runRequested()
            ToolTip.text: "Chạy"; ToolTip.visible: hovered; ToolTip.delay: 500
        }
        AppButton {
            visible: !bar.homeMode
            variant: "destructive"; iconName: "stop"
            enabled: bar.running
            onClicked: bar.stopRequested()
            ToolTip.text: "Dừng"; ToolTip.visible: hovered; ToolTip.delay: 500
        }

        Item { Layout.fillWidth: true }

        // REPL toggle — secondary (blue) when active
        Button {
            id: replBtn
            visible: !bar.homeMode
            checkable: true
            checked: bar.replActive
            implicitHeight: Theme.control_base
            leftPadding: Theme.space_base; rightPadding: Theme.space_base
            onToggled: bar.replToggled(checked)
            scale: down ? 0.97 : 1.0
            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            contentItem: Item {
                implicitWidth: replRow.implicitWidth
                implicitHeight: replRow.implicitHeight
                RowLayout {
                    id: replRow
                    anchors.centerIn: parent
                    spacing: Theme.space_xs
                    Icon { name: "console"; size: Theme.icon_size
                           color: replBtn.checked ? Theme.secondary_text : Theme.editor_text }
                }
            }
            background: Rectangle {
                radius: Theme.radius_chip
                color: replBtn.checked ? Theme.secondary
                       : replBtn.hovered ? Theme.terminal_border : Theme.editor_bg_alt
            }
        }

        // Settings — icon only
        Button {
            id: cogBtn
            implicitHeight: Theme.control_base; implicitWidth: Theme.control_base
            onClicked: bar.settingsRequested()
            scale: down ? 0.97 : 1.0
            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            contentItem: Icon { name: "cog"; size: 20; color: Theme.editor_text }
            background: Rectangle {
                radius: Theme.radius_chip
                color: cogBtn.hovered ? Theme.editor_bg_alt : "transparent"
            }
        }
    }
}
