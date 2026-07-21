// Settings — kid-friendly modal. Big +/- steppers, generous padding,
// double-bezel rows. word_wrap intentionally absent (gutter needs NoWrap).
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: dlg
    modal: true
    width: 440
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Theme.editor_bg
        radius: Theme.radius_card
        border.color: Theme.terminal_border
        border.width: 1
    }

    // Round stepper button — pill, tactile.
    component RoundBtn: Button {
        id: rb
        property string glyph: ""
        implicitWidth: Theme.control_base
        implicitHeight: Theme.control_base
        scale: down ? 0.94 : 1.0
        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
        contentItem: Icon { name: rb.glyph; size: 18
                            color: rb.enabled ? Theme.editor_text : Theme.terminal_text_disabled
                            anchors.centerIn: parent }
        background: Rectangle {
            radius: Theme.radius_pill
            color: !rb.enabled ? Theme.editor_bg_alt
                   : rb.hovered ? Theme.terminal_border : Theme.editor_bg_alt
            border.color: Theme.terminal_border; border.width: 1
        }
    }

    // A setting row: icon + title + description on the left, stepper on the right.
    component SettingRow: Rectangle {
        id: srow
        property string iconName: ""
        property string title: ""
        property string description: ""
        property int value: 0
        property int minValue: 0
        property int maxValue: 100
        property string suffix: ""
        signal changed(int value)
        Layout.fillWidth: true
        implicitHeight: rowLay.implicitHeight + 2 * Theme.space_base
        color: Theme.editor_bg_alt
        border.color: Theme.terminal_border; border.width: 1
        radius: Theme.radius_card
        RowLayout {
            id: rowLay
            anchors.fill: parent
            anchors.margins: Theme.space_base
            spacing: Theme.space_md
            Rectangle {
                Layout.preferredWidth: 36; Layout.preferredHeight: 36
                radius: Theme.radius_chip; color: Theme.editor_selection
                Icon { anchors.centerIn: parent; name: srow.iconName; size: 18; color: Theme.primary }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: srow.title; color: Theme.editor_text
                        font.bold: true; font.pixelSize: Theme.font_title }
                Label { text: srow.description; color: Theme.terminal_text_secondary
                        font.pixelSize: Theme.font_caption; wrapMode: Text.Wrap; Layout.fillWidth: true }
            }
            RoundBtn {
                glyph: "minus"; enabled: srow.value > srow.minValue
                onClicked: srow.changed(srow.value - 1)
            }
            Label {
                text: srow.value + srow.suffix
                color: Theme.editor_text; font.bold: true; font.pixelSize: Theme.font_title
                font.family: Theme.mono_family; horizontalAlignment: Text.AlignHCenter
                Layout.minimumWidth: 44
            }
            RoundBtn {
                glyph: "plus"; enabled: srow.value < srow.maxValue
                onClicked: srow.changed(srow.value + 1)
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.space_lg
            Layout.bottomMargin: Theme.space_md
            spacing: Theme.space_sm
            Icon { name: "cog"; size: 22; color: Theme.primary }
            Label { text: "Cài đặt"; color: Theme.editor_text; font.bold: true; font.pixelSize: Theme.font_heading }
            Item { Layout.fillWidth: true }
            Button {
                id: closeBtn
                implicitWidth: 32; implicitHeight: 32
                scale: down ? 0.94 : 1.0
                Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                onClicked: dlg.close()
                contentItem: Icon { name: "close"; size: 18; color: Theme.terminal_text_secondary; anchors.centerIn: parent }
                background: Rectangle { radius: Theme.radius_pill
                    color: closeBtn.hovered ? Theme.editor_bg_alt : "transparent" }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.terminal_border }

        // Setting rows
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.space_lg
            spacing: Theme.space_md

            SettingRow {
                iconName: "format_size"; title: "Cỡ chữ"
                description: "Kích thước chữ trong trình soạn thảo"
                value: settings.fontSize; minValue: 8; maxValue: 32; suffix: "px"
                onChanged: function(v) { settings.setFontSize(v) }
            }
            SettingRow {
                iconName: "keyboard_tab"; title: "Độ rộng Tab"
                description: "Số khoảng trắng cho mỗi lần nhấn Tab"
                value: settings.tabWidth; minValue: 2; maxValue: 8
                onChanged: function(v) { settings.setTabWidth(v) }
            }
        }

        // Footer
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Theme.space_lg
            Layout.topMargin: 0
            Item { Layout.fillWidth: true }
            AppButton { variant: "primary"; text: "Xong"; onClicked: dlg.close() }
        }
    }
}
