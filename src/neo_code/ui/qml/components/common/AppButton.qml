// Standard button. variant: primary | destructive | secondary | utility.
// Centered icon+label, kid-sized (≥40px), tactile press (transform-only).
//
//   • Text-less buttons (iconName only) render as a square pill — same width
//     as height, so a row of icon buttons lines up.
//   • `onDark` picks the neutral pair the utility variant borrows: true = the
//     dark IDE chrome (toolbar, sidebar, dialogs), false = the light Surface
//     canvas. Everything else is variant-driven and tone-independent.
//   • `checkable: true` turns it into a toggle; while checked it fills with
//     `checkedVariant` (secondary/blue by default).
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: ctrl
    property string variant: "utility"
    property string checkedVariant: "secondary"   // fill used while checked
    property bool onDark: true                    // host surface tone
    property string iconName: ""
    property int iconSize: Theme.icon_size
    property string tooltip: ""

    readonly property bool iconOnly: text === "" && iconName !== ""

    implicitHeight: Theme.control_base
    // Square when icon-only; otherwise Control's own default sizing rule.
    implicitWidth: iconOnly ? implicitHeight
                            : Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                       implicitContentWidth + leftPadding + rightPadding)

    leftPadding: iconOnly ? 0 : Theme.space_base
    rightPadding: iconOnly ? 0 : Theme.space_base
    topPadding: Theme.space_sm
    bottomPadding: Theme.space_sm

    readonly property var _variants: ({
        "primary":     { "bg": Theme.primary,   "hover": Theme.primary_hover,   "fg": Theme.primary_text,   "flat": false },
        "destructive": { "bg": Theme.error,     "hover": Theme.error_hover,     "fg": Theme.error_text,     "flat": false },
        "secondary":   { "bg": Theme.secondary, "hover": Theme.secondary_hover, "fg": Theme.secondary_text, "flat": false },
        "utility":     { "bg": "transparent",
                         "hover": ctrl.onDark ? Theme.editor_bg_alt : Theme.surface_alt,
                         "fg":    ctrl.onDark ? Theme.editor_text   : Theme.text,
                         "flat":  true }
    })
    // Unknown variant falls back to utility rather than yielding undefined.
    readonly property var _spec: _variants[(checkable && checked) ? checkedVariant : variant]
                                 || _variants.utility
    readonly property color _fg: enabled ? _spec.fg : Theme.text_disabled

    // Tactile press — GPU-cheap transform only.
    scale: down ? 0.97 : 1.0
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }

    ToolTip.text: tooltip
    ToolTip.visible: tooltip !== "" && hovered
    ToolTip.delay: 500
    Accessible.name: tooltip !== "" ? tooltip : text

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
                color: ctrl._fg
            }
            Label {
                visible: ctrl.text !== ""
                text: ctrl.text
                font.pixelSize: Theme.font_label
                font.weight: Font.Medium
                color: ctrl._fg
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    background: Rectangle {
        radius: ctrl.iconOnly ? Theme.radius_pill : Theme.radius_button
        color: !ctrl.enabled
               ? (ctrl._spec.flat ? "transparent"
                                  : (ctrl.onDark ? Theme.editor_bg_alt : Theme.surface_alt))
               : ctrl.hovered ? ctrl._spec.hover : ctrl._spec.bg
        border.width: ctrl.visualFocus ? 2 : 0
        border.color: Theme.primary

        // M3 pressed state layer — content colour at 12% over whatever fill is
        // showing, so it reads correctly on both tones and every variant.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: ctrl._fg
            opacity: ctrl.down ? 0.12 : 0
            Behavior on opacity { NumberAnimation { duration: 90 } }
        }
    }
}
