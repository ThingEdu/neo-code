// Robot sidebar panel: module/mission list ↔ mission detail.
// Neo Play design: airy padding, surface trays, 16px cards, tactile buttons.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: panel
    color: Theme.background

    signal insertCode(string code)

    property bool detailShown: false
    property var detail: ({})
    property string status: "Chưa tìm kiếm board."

    Connections {
        target: robotController
        function onMissionChanged(d) {
            if (d === null || d === undefined) panel.detailShown = false
            else { panel.detail = d; panel.detailShown = true }
        }
        function onStatusChanged(text) { panel.status = text }
    }

    // ── List view ────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space_base
        spacing: Theme.space_base
        visible: !panel.detailShown

        Label { text: "Robot"; font.bold: true; color: Theme.text; font.pixelSize: Theme.font_heading }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ColumnLayout {
                width: parent.parent.width
                spacing: Theme.space_md
                Repeater {
                    model: robotController.modules
                    delegate: Rectangle {
                        id: modItem
                        required property var modelData
                        Layout.fillWidth: true
                        color: Theme.surface
                        border.color: Theme.border; border.width: 1
                        radius: Theme.radius_lg
                        implicitHeight: mcol.implicitHeight + 2 * Theme.space_md
                        ColumnLayout {
                            id: mcol
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: Theme.space_md
                            spacing: Theme.space_xs
                            Label {
                                text: modItem.modelData.title
                                color: Theme.text_secondary; font.pixelSize: Theme.font_caption; font.bold: true
                                leftPadding: Theme.space_xs
                            }
                            Repeater {
                                model: modItem.modelData.missions
                                delegate: Rectangle {
                                    id: mrow
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: Theme.row_height
                                    radius: Theme.radius_chip
                                    color: mrowHover.hovered ? Theme.surface_alt : "transparent"
                                    Label {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.space_sm
                                        anchors.rightMargin: Theme.space_sm
                                        verticalAlignment: Text.AlignVCenter
                                        text: mrow.modelData.title; color: Theme.text
                                        font.pixelSize: Theme.font_body; elide: Text.ElideRight
                                    }
                                    HoverHandler { id: mrowHover }
                                    TapHandler { onTapped: robotController.selectMission(mrow.modelData.id) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Detail view ──────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space_base
        spacing: Theme.space_md
        visible: panel.detailShown

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space_sm
            AppButton {
                variant: "utility"; iconName: "arrow_left"
                leftPadding: Theme.space_sm; rightPadding: Theme.space_sm
                implicitWidth: Theme.control_base
                onClicked: robotController.back()
            }
            Icon { name: "robot"; size: 18; color: Theme.primary }
            Label {
                text: panel.detail.title || ""
                font.bold: true; color: Theme.text; font.pixelSize: Theme.font_title
                Layout.fillWidth: true; elide: Text.ElideRight
            }
        }
        Label { text: "Trạng thái: " + panel.status; wrapMode: Text.Wrap; Layout.fillWidth: true
                color: Theme.text_secondary; font.pixelSize: Theme.font_body }

        // Goal
        Rectangle {
            Layout.fillWidth: true; implicitHeight: goalCol.implicitHeight + 2 * Theme.space_base
            color: Theme.surface; border.color: Theme.border; border.width: 1; radius: Theme.radius_card
            ColumnLayout {
                id: goalCol
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: Theme.space_base; spacing: Theme.space_sm
                RowLayout {
                    spacing: Theme.space_xs
                    Icon { name: "target"; size: 16; color: Theme.primary }
                    Label { text: "Mục tiêu"; font.bold: true; color: Theme.text; font.pixelSize: Theme.font_title }
                }
                Label { text: panel.detail.goal || ""; wrapMode: Text.Wrap; Layout.fillWidth: true
                        color: Theme.text_secondary; font.pixelSize: Theme.font_body }
            }
        }

        // API hint (monospace)
        Rectangle {
            Layout.fillWidth: true; implicitHeight: apiCol.implicitHeight + 2 * Theme.space_base
            color: Theme.surface; border.color: Theme.border; border.width: 1; radius: Theme.radius_card
            ColumnLayout {
                id: apiCol
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: Theme.space_base; spacing: Theme.space_sm
                RowLayout {
                    spacing: Theme.space_xs
                    Icon { name: "flask"; size: 16; color: Theme.secondary }
                    Label { text: "API thingbot-telemetrix"; font.bold: true; color: Theme.text; font.pixelSize: Theme.font_title }
                }
                Text { text: panel.detail.api_hint || ""; wrapMode: Text.WrapAnywhere
                       Layout.fillWidth: true
                       font.family: Theme.mono_family; font.pixelSize: Theme.font_caption; color: Theme.text_secondary }
            }
        }

        AppButton {
            variant: "secondary"; text: "Nạp mã mẫu vào Editor"; Layout.fillWidth: true
            onClicked: panel.insertCode(panel.detail.starter_code || "")
        }
        AppButton {
            variant: "utility"; iconName: "usb"; text: "Tìm board USB"; Layout.fillWidth: true
            onClicked: robotController.scanPorts()
            background: Rectangle {
                radius: Theme.radius_chip
                border.color: Theme.border; border.width: 1
                color: parent.hovered ? Theme.surface_alt : Theme.surface
            }
        }

        Item { Layout.fillHeight: true }
    }
}
