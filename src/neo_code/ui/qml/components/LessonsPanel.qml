// Lessons sidebar panel: world/lesson list ↔ lesson detail.
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
    property string feedbackMsg: ""
    property string feedbackState: "none"

    function starsText(n) {
        n = Math.max(0, Math.min(3, n))
        return "★".repeat(n) + "☆".repeat(3 - n)
    }
    function feedbackColor(state) {
        return state === "success" ? Theme.primary
             : state === "fail" ? Theme.tertiary
             : Theme.text_secondary
    }

    // Titled card: white fill, whisper border, generous padding.
    component Card: Rectangle {
        id: card
        property string iconName: ""
        property string title: ""
        property string body: ""
        Layout.fillWidth: true
        implicitHeight: cardCol.implicitHeight + 2 * Theme.space_base
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radius_card
        ColumnLayout {
            id: cardCol
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
            anchors.margins: Theme.space_base
            spacing: Theme.space_sm
            RowLayout {
                spacing: Theme.space_xs
                Icon { name: card.iconName; size: 16; color: Theme.primary }
                Label { text: card.title; font.bold: true
                        color: Theme.text; font.pixelSize: Theme.font_title }
            }
            Label {
                text: card.body; wrapMode: Text.Wrap
                Layout.fillWidth: true; color: Theme.text_secondary; font.pixelSize: Theme.font_body
                lineHeight: 1.25
            }
        }
    }

    Connections {
        target: lessonsController
        function onLessonChanged(d) {
            if (d === null || d === undefined) panel.detailShown = false
            else { panel.detail = d; panel.detailShown = true }
        }
        function onFeedbackChanged(msg, state) { panel.feedbackMsg = msg; panel.feedbackState = state }
        function onProgressChanged(id, stars, attempts) {
            if (panel.detail && panel.detail.id === id) {
                var d = panel.detail
                d.stars = stars; d.attempts = attempts
                panel.detail = d
            }
        }
    }

    // ── List view ──────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space_base
        spacing: Theme.space_base
        visible: !panel.detailShown

        Label { text: "Bài học"; font.bold: true; color: Theme.text; font.pixelSize: Theme.font_heading }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ColumnLayout {
                width: parent.parent.width
                spacing: Theme.space_md
                Repeater {
                    model: lessonsController.worlds
                    // World group card (white on canvas).
                    delegate: Rectangle {
                        id: worldItem
                        required property var modelData
                        Layout.fillWidth: true
                        color: Theme.surface
                        border.color: Theme.border; border.width: 1
                        radius: Theme.radius_lg
                        implicitHeight: wcol.implicitHeight + 2 * Theme.space_md
                        ColumnLayout {
                            id: wcol
                            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                            anchors.margins: Theme.space_md
                            spacing: Theme.space_xs
                            Label {
                                text: worldItem.modelData.title
                                color: Theme.text_secondary; font.pixelSize: Theme.font_caption; font.bold: true
                                leftPadding: Theme.space_xs
                            }
                            Repeater {
                                model: worldItem.modelData.lessons
                                delegate: Rectangle {
                                    id: row
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: Theme.row_height
                                    radius: Theme.radius_chip
                                    color: rowHover.hovered ? Theme.surface_alt : "transparent"
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.space_sm
                                        anchors.rightMargin: Theme.space_sm
                                        spacing: Theme.space_sm
                                        Icon {
                                            name: row.modelData.completed ? "check_filled" : "circle_outline"
                                            size: 16
                                            color: row.modelData.completed ? Theme.primary : Theme.text_disabled
                                        }
                                        Label {
                                            text: row.modelData.title; color: Theme.text
                                            font.pixelSize: Theme.font_body; elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Label {
                                            text: row.modelData.attempts > 0 || row.modelData.completed
                                                  ? panel.starsText(row.modelData.stars) : ""
                                            color: Theme.primary; font.pixelSize: Theme.font_caption
                                        }
                                    }
                                    HoverHandler { id: rowHover }
                                    TapHandler { onTapped: lessonsController.selectLesson(row.modelData.id) }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Detail view ─────────────────────────────────────────────────────────
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
                onClicked: lessonsController.back()
            }
            Icon { name: "book_open"; size: 18; color: Theme.primary }
            Label {
                text: panel.detail.title || ""
                font.bold: true; color: Theme.text; font.pixelSize: Theme.font_title
                Layout.fillWidth: true; elide: Text.ElideRight
            }
        }
        Label {
            text: (panel.detail.attempts > 0 ? panel.starsText(panel.detail.stars)
                   + " • Lượt thử: " + panel.detail.attempts : "Chưa bắt đầu")
            color: Theme.text_secondary; font.pixelSize: Theme.font_body
        }

        Card { iconName: "target";    title: "Mục tiêu"; body: panel.detail.goal || "" }
        Card { iconName: "lightbulb"; title: "Gợi ý";    body: panel.detail.hint || "" }

        // Starter code + copy-to-editor
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: starterCol.implicitHeight + 2 * Theme.space_base
            color: Theme.surface; border.color: Theme.border; border.width: 1; radius: Theme.radius_card
            ColumnLayout {
                id: starterCol
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: Theme.space_base; spacing: Theme.space_sm
                RowLayout {
                    spacing: Theme.space_xs
                    Icon { name: "puzzle"; size: 16; color: Theme.primary }
                    Label { text: "Mã gợi ý"; font.bold: true; color: Theme.text; font.pixelSize: Theme.font_title }
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: starterText.implicitHeight + Theme.space_base
                    color: Theme.surface_2; border.color: Theme.border; border.width: 1; radius: Theme.radius_inner
                    Text {
                        id: starterText
                        anchors.fill: parent; anchors.margins: Theme.space_sm
                        text: panel.detail.starter_code || ""
                        font.family: Theme.mono_family; font.pixelSize: Theme.font_body; color: Theme.editor_text
                        wrapMode: Text.NoWrap
                    }
                }
                AppButton {
                    variant: "secondary"; text: "Chép vào trình soạn thảo"; Layout.fillWidth: true
                    onClicked: panel.insertCode(panel.detail.starter_code || "")
                }
            }
        }

        // Feedback
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: fbCol.implicitHeight + 2 * Theme.space_base
            color: Theme.surface; border.color: Theme.border; border.width: 1; radius: Theme.radius_card
            ColumnLayout {
                id: fbCol
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                anchors.margins: Theme.space_base; spacing: Theme.space_sm
                RowLayout {
                    spacing: Theme.space_xs
                    Icon { name: "check_circle"; size: 16; color: panel.feedbackColor(panel.feedbackState) }
                    Label { text: "Phản hồi"; font.bold: true; color: Theme.text; font.pixelSize: Theme.font_title }
                }
                Label {
                    text: panel.feedbackMsg; wrapMode: Text.Wrap; Layout.fillWidth: true
                    color: panel.feedbackColor(panel.feedbackState); font.pixelSize: Theme.font_body
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
