// Sáng tạo (Create) mode — free-code editor beside terminal, or full REPL.
// The file tab lives inside EditorPanel, snapped to the editor it names
// instead of floating separately. Self-contained: reacts to signalBus for
// the file lifecycle directly rather than having MainWindow broker it.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/common" as Common

Item {
    id: root

    property bool replActive: false
    property alias currentText: editor.text

    // Editor beside terminal (script mode) — each pane floats as its own
    // rounded card; the handle's gap is transparent so the two cards read
    // as separate, not one panel with a divider.
    SplitView {
        anchors.fill: parent
        visible: !root.replActive
        orientation: Qt.Horizontal

        handle: Item {
            implicitWidth: Theme.space_sm
            implicitHeight: Theme.space_sm
        }

        Common.EditorPanel {
            id: editor
            SplitView.fillWidth: true
            SplitView.minimumWidth: 300
            text: "# NEO Code\nfor i in range(3):\n    print(\"Xin chào\", i)\n"
        }

        Common.ResultConsole {
            SplitView.preferredWidth: 380
            SplitView.minimumWidth: 220
            showStatusLines: true
        }
    }

    // REPL takes over the whole area (interactive mode)
    Common.ReplPanel {
        anchors.fill: parent
        visible: root.replActive
    }

    // Editor content follows file lifecycle
    Connections {
        target: signalBus
        function onFileOpened(path, content) { editor.text = content }
        function onFileNew() { editor.text = "" }
    }
}
