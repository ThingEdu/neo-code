// Chơi (Play) mode — arm panel, its own editor, and the telemetry/output
// column. Structurally Học's layout with the Expected pane swapped for where
// the arm actually is.
//
// The REPL swap here is narrower than Sáng tạo's full-area takeover: the panel
// and the status pane stay, because typing `arm.turn_left(30)` and watching the
// gauge move is the point of the mode. Only the editor and the result console
// give up their space.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/common" as Common
import "../components/play" as Play

Item {
    id: root

    property bool replActive: false
    property alias currentText: editor.text

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Item {
            implicitWidth: Theme.space_sm
            implicitHeight: Theme.space_sm
        }

        Play.ArmPanel {
            id: armPanel
            SplitView.preferredWidth: collapsed ? 56 : 300
            SplitView.minimumWidth: collapsed ? 56 : 220
            SplitView.maximumWidth: collapsed ? 56 : 420
            activity: playController.activity
            // Inserts land wherever the kid is typing — the editor in script
            // mode, the REPL's input row in interactive mode.
            onEntryTapped: function(insertText) {
                if (root.replActive) repl.insertAtInput(insertText.replace(/\n$/, ""))
                else editor.insertAtCursor(insertText)
            }
        }

        Common.EditorPanel {
            id: editor
            visible: !root.replActive
            SplitView.fillWidth: !root.replActive
            SplitView.minimumWidth: 260
            text: "# Điều khiển cánh tay robot\narm.turn_left(30)\narm.grab()\n"
        }

        Common.ReplPanel {
            id: repl
            visible: root.replActive
            SplitView.fillWidth: root.replActive
            SplitView.minimumWidth: 260
        }

        Play.PlayConsole {
            SplitView.preferredWidth: 340
            SplitView.minimumWidth: 260
        }
    }

    // Editor content follows the file lifecycle, same as the other modes, so
    // New/Open/Save in the toolbar work here too.
    Connections {
        target: signalBus
        function onFileOpened(path, content) { editor.text = content }
        function onFileNew() { editor.text = "" }
    }
}
