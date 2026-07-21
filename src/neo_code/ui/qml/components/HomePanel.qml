// Home — mode-select landing screen shown before the IDE canvas.
// Only "Sáng tạo" (Create) is implemented in this repo; "Học" and "Chơi" are
// being migrated to a separate app (see AGENTS.md) and show as coming soon.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: home
    color: Theme.background

    // Scales type/icons up on screens wider than the 1280px baseline so the
    // hero mode cards stay legible on larger displays. 1.22 floor bumps the
    // whole page up a little regardless of window size.
    readonly property real textScale: Math.max(1.22, width / 1280)

    signal createRequested()
    signal settingsRequested()

    component ModeCard: Button {
        id: card
        required property string modeTitle
        required property string modeSub
        required property string iconName
        required property color bgColor
        required property color fgColor
        required property color badgeBg
        required property color iconBg
        property bool available: false

        Layout.fillWidth: true
        Layout.fillHeight: true
        enabled: card.available

        scale: down ? 0.98 : 1.0
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

        onClicked: if (card.available) home.createRequested()

        // Two solid, opaque layers rather than a translucent Rectangle.border —
        // a translucent border color does not render on this Qt build.
        background: Item {
            opacity: card.available ? 1.0 : 0.55

            Rectangle {
                anchors.fill: parent
                radius: Theme.radius_card
                color: card.available ? Qt.lighter(card.bgColor, 1.35) : card.bgColor
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: card.available ? 3 : 0
                radius: Theme.radius_card - (card.available ? 3 : 0)
                color: card.bgColor
            }
        }

        contentItem: Item {
            implicitWidth: 240

            // Single padded region — badge and content share the same inset
            // so nothing sits flush against the card's edges.
            Item {
                anchors.fill: parent
                anchors.margins: Theme.space_lg

                Rectangle {
                    visible: !card.available
                    anchors.top: parent.top
                    anchors.right: parent.right
                    height: 28 * home.textScale
                    radius: height / 2
                    color: card.badgeBg
                    width: soonLabel.implicitWidth + Theme.space_sm * 2 * home.textScale
                    Label {
                        id: soonLabel
                        anchors.centerIn: parent
                        text: "Sắp ra mắt"
                        font.pixelSize: 13 * home.textScale
                        font.bold: true
                        color: card.fgColor
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.space_sm

                    Rectangle {
                        Layout.preferredWidth: 60 * home.textScale
                        Layout.preferredHeight: 60 * home.textScale
                        radius: width / 2
                        color: card.iconBg
                        Icon { anchors.centerIn: parent; name: card.iconName; size: 30 * home.textScale; color: card.fgColor }
                    }

                    Label {
                        text: card.modeTitle
                        font.bold: true
                        font.pixelSize: 26 * home.textScale
                        color: card.fgColor
                    }

                    Label {
                        text: card.modeSub
                        font.pixelSize: 17 * home.textScale
                        font.weight: Font.DemiBold
                        color: card.fgColor
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        visible: card.available
                        spacing: Theme.space_xs
                        Label { text: "Bắt đầu"; font.bold: true; font.pixelSize: 17 * home.textScale; color: card.fgColor }
                        Icon { name: "chevron_right"; size: 18 * home.textScale; color: card.fgColor }
                    }
                }
            }
        }
    }

    // Single bordered panel holding the header (logo + settings) and the mode
    // cards together, instead of the two floating loose on the bare canvas.
    Rectangle {
        anchors.fill: parent
        anchors.margins: Theme.space_xl
        radius: Theme.radius_lg
        color: Theme.surface
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.space_xl
            spacing: Theme.space_xl

            // ── Header: brand lockup (left) + settings (right), one shared row
            // so both sit the same distance from their edge. ────────────────
            RowLayout {
                Layout.fillWidth: true

                RowLayout {
                    spacing: Theme.space_sm
                    Rectangle {
                        width: 40 * home.textScale; height: 40 * home.textScale
                        radius: width * 0.26
                        color: Theme.background
                        border.width: 1
                        border.color: Theme.border
                        Icon { anchors.centerIn: parent; name: "code_tags"; size: 20 * home.textScale; color: Theme.primary }
                    }
                    Label {
                        text: "NEO Code"
                        font.bold: true
                        font.pixelSize: 18 * home.textScale
                        color: Theme.text
                    }
                }

                Item { Layout.fillWidth: true }

                Button {
                    id: gearBtn
                    implicitWidth: 40 * home.textScale; implicitHeight: 40 * home.textScale
                    onClicked: home.settingsRequested()
                    scale: down ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                    contentItem: Icon { anchors.centerIn: parent; name: "cog"; size: 20 * home.textScale; color: Theme.text_secondary }
                    background: Rectangle {
                        radius: width / 2
                        color: Theme.background
                        border.width: 1
                        border.color: Theme.border
                    }
                }
            }

            // ── Body: mode row — same left/right edges as the header above,
            // only vertically centered/height-capped. ───────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    id: modeRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space_lg
                    // Each card is 4:3, portrait (taller than wide): height
                    // follows from the per-card width the 3 equal columns get.
                    height: Math.min((width - spacing * 2) / 3 * 4 / 3, parent.height)

                    ModeCard {
                        modeTitle: "Chơi"
                        modeSub: "Khám phá và điều khiển robot"
                        iconName: "play"
                        bgColor: Theme.secondary
                        fgColor: Theme.secondary_text
                        badgeBg: Qt.rgba(1, 1, 1, 0.28)
                        iconBg: Qt.rgba(1, 1, 1, 0.28)
                        available: false
                    }
                    ModeCard {
                        modeTitle: "Học"
                        modeSub: "Học lập trình qua các bài học từng bước"
                        iconName: "book_open"
                        bgColor: Theme.primary
                        fgColor: Theme.primary_text
                        badgeBg: Qt.rgba(0, 0, 0, 0.14)
                        iconBg: Qt.rgba(0, 0, 0, 0.12)
                        available: false
                    }
                    ModeCard {
                        modeTitle: "Sáng tạo"
                        modeSub: "Tự viết và chạy code Python của mình"
                        iconName: "code_tags"
                        bgColor: Theme.tertiary
                        fgColor: Theme.tertiary_text
                        badgeBg: Qt.rgba(1, 1, 1, 0.28)
                        iconBg: Qt.rgba(1, 1, 1, 0.28)
                        available: true
                    }
                }
            }
        }
    }
}
