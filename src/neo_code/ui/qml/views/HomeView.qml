// Home — mode-select landing screen shown before the IDE canvas.
// All three modes are implemented: "Chơi" (robot arm), "Học" (curriculum) and
// "Sáng tạo" (free coding). The "Sắp ra mắt" badge stays for future cards.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/common"

Rectangle {
    id: home
    color: Theme.background

    // Scales type/icons up on screens wider than the 1280px baseline so the
    // hero mode cards stay legible on larger displays. 1.22 floor bumps the
    // whole page up a little regardless of window size.
    readonly property real textScale: Math.max(1.22, width / 1280)

    signal createRequested()
    signal learnRequested()
    signal playRequested()

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
        property string targetMode: "create"

        Layout.fillWidth: true
        Layout.fillHeight: true
        enabled: card.available

        scale: down ? 0.98 : 1.0
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

        onClicked: {
            if (!card.available) return
            if (card.targetMode === "learn") home.learnRequested()
            else if (card.targetMode === "play") home.playRequested()
            else home.createRequested()
        }

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

    // Mode cards sit directly on the canvas — no wrapping panel. No top
    // margin here: HomeView's own top edge is already 8px below the
    // toolbar (from the toolbar's own bottom margin, MainWindow.qml) —
    // adding one here would double that gap, same as the editor's Item.
    RowLayout {
        id: modeRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: Theme.space_sm

        ModeCard {
            modeTitle: "Chơi"
            modeSub: "Khám phá và điều khiển cánh tay robot"
            iconName: "robot_industrial"
            bgColor: Theme.secondary
            fgColor: Theme.secondary_text
            badgeBg: Qt.rgba(1, 1, 1, 0.28)
            iconBg: Qt.rgba(1, 1, 1, 0.28)
            available: true
            targetMode: "play"
        }
        ModeCard {
            modeTitle: "Học"
            modeSub: "Học lập trình qua các bài học từng bước"
            iconName: "book_open"
            bgColor: Theme.primary
            fgColor: Theme.primary_text
            badgeBg: Qt.rgba(0, 0, 0, 0.14)
            iconBg: Qt.rgba(0, 0, 0, 0.12)
            available: true
            targetMode: "learn"
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
            targetMode: "create"
        }
    }
}
