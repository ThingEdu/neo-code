// Standard button. variant: primary | destructive | secondary | utility.
// Centered icon+label, kid-sized (≥40px), tactile press (transform-only).
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: ctrl
    property string variant: "utility"
    property string iconName: ""
    property int iconSize: Theme.icon_size

    implicitHeight: Theme.control_base
    leftPadding: Theme.space_base
    rightPadding: Theme.space_base
    topPadding: Theme.space_sm
    bottomPadding: Theme.space_sm

    readonly property var _spec: ({
        "primary":     { "bg": Theme.primary,   "hover": Theme.primary_hover,   "fg": Theme.primary_text },
        "destructive": { "bg": Theme.tertiary,  "hover": Theme.tertiary_hover,  "fg": Theme.tertiary_text },
        "secondary":   { "bg": Theme.secondary, "hover": Theme.secondary_hover, "fg": Theme.secondary_text },
        "utility":     { "bg": "transparent",   "hover": Theme.surface_alt,     "fg": Theme.text }
    })[ctrl.variant]

    // Tactile press — GPU-cheap transform only.
    scale: down ? 0.97 : 1.0
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight
        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Theme.space_xs
            Icon {
                visible: ctrl.iconName !== ""
                name: ctrl.iconName; size: ctrl.iconSize
                color: ctrl.enabled ? ctrl._spec.fg : Theme.text_disabled
            }
            Label {
                visible: ctrl.text !== ""
                text: ctrl.text
                font.bold: ctrl.variant !== "utility"
                font.pixelSize: Theme.font_body
                color: ctrl.enabled ? ctrl._spec.fg : Theme.text_disabled
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    background: Rectangle {
        radius: Theme.radius_chip
        color: !ctrl.enabled ? (ctrl.variant === "utility" ? "transparent" : Theme.surface_alt)
               : ctrl.hovered ? ctrl._spec.hover : ctrl._spec.bg
    }
}
