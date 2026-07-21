// Top toolbar: file ops + Run/Stop + REPL toggle + Settings.
// Neo Play design: MDI icons, generous padding, tactile AppButtons.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bar
    implicitHeight: 60
    color: Theme.toolbar_bg

    property bool running: false
    property bool replActive: false

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

        AppButton { variant: "utility"; iconName: "arrow_left"; text: "Quay lại"; onClicked: bar.backRequested() }

        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 26; color: Theme.border }

        AppButton { variant: "utility"; iconName: "file_plus";   text: "Mới"; onClicked: bar.newRequested() }
        AppButton { variant: "utility"; iconName: "folder_open"; text: "Mở";  onClicked: bar.openRequested() }
        AppButton { variant: "utility"; iconName: "save";        text: "Lưu"; onClicked: bar.saveRequested() }

        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 26; color: Theme.border }

        AppButton {
            variant: "primary"; iconName: "play"; text: "Chạy"
            enabled: !bar.running
            onClicked: bar.runRequested()
        }
        AppButton {
            variant: "destructive"; iconName: "stop"; text: "Dừng"
            enabled: bar.running
            onClicked: bar.stopRequested()
        }

        Item { Layout.fillWidth: true }

        // REPL toggle — secondary (blue) when active
        Button {
            id: replBtn
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
                           color: replBtn.checked ? Theme.secondary_text : Theme.text }
                }
            }
            background: Rectangle {
                radius: Theme.radius_chip
                color: replBtn.checked ? Theme.secondary
                       : replBtn.hovered ? Theme.border_strong : Theme.surface_alt
            }
        }

        // Settings — icon only
        Button {
            id: cogBtn
            implicitHeight: Theme.control_base; implicitWidth: Theme.control_base
            onClicked: bar.settingsRequested()
            scale: down ? 0.97 : 1.0
            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
            contentItem: Icon { name: "cog"; size: 20; color: Theme.text }
            background: Rectangle {
                radius: Theme.radius_chip
                color: cogBtn.hovered ? Theme.surface_alt : "transparent"
            }
        }
    }

    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }
}
