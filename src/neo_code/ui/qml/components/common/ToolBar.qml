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
    property bool learnMode: false

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
                font.weight: Font.Black
                font.pixelSize: 18
                color: Theme.editor_text
            }
        }

        AppButton {
            visible: !bar.homeMode; variant: "utility"; iconName: "arrow_left"
            tooltip: "Quay lại"
            onClicked: bar.backRequested()
        }

        Rectangle { visible: !bar.homeMode && !bar.learnMode; Layout.preferredWidth: 1; Layout.preferredHeight: 26; color: Theme.terminal_border }

        AppButton {
            visible: !bar.homeMode && !bar.learnMode; variant: "utility"; iconName: "file_plus"
            tooltip: "Mới"
            onClicked: bar.newRequested()
        }
        AppButton {
            visible: !bar.homeMode && !bar.learnMode; variant: "utility"; iconName: "folder_open"
            tooltip: "Mở"
            onClicked: bar.openRequested()
        }
        AppButton {
            visible: !bar.homeMode && !bar.learnMode; variant: "utility"; iconName: "save"
            tooltip: "Lưu"
            onClicked: bar.saveRequested()
        }

        Rectangle { visible: !bar.homeMode; Layout.preferredWidth: 1; Layout.preferredHeight: 26; color: Theme.terminal_border }

        AppButton {
            visible: !bar.homeMode
            variant: "primary"; iconName: "play"
            enabled: !bar.running
            tooltip: "Chạy"
            onClicked: bar.runRequested()
        }
        AppButton {
            visible: !bar.homeMode
            variant: "destructive"; iconName: "stop"
            enabled: bar.running
            tooltip: "Dừng"
            onClicked: bar.stopRequested()
        }

        Item { Layout.fillWidth: true }

        // REPL toggle — fills secondary (blue) while active
        AppButton {
            visible: !bar.homeMode && !bar.learnMode
            variant: "utility"; iconName: "console"
            checkable: true
            checked: bar.replActive
            tooltip: "Python REPL"
            onToggled: bar.replToggled(checked)
        }

        // Settings — icon only
        AppButton {
            variant: "utility"; iconName: "cog"
            tooltip: "Cài đặt"
            onClicked: bar.settingsRequested()
        }
    }
}
