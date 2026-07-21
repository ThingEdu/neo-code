// NEO Code — main window. A single focused canvas: toolbar, file header,
// editor/terminal (or REPL). No sidebar — there is nothing left to navigate to.
// Qt 6.4-compatible.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import "components" as C
import "views" as V

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: "NEO Code" + (files.hasFile ? " — " + files.currentPath.split("/").pop() : "")
    color: Theme.background

    property bool replActive: false
    property bool homeActive: true

    // ── File dialogs (QtQuick.Dialogs) ─────────────────────────────────────
    FileDialog {
        id: openDialog
        title: "Mở tệp Python"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Tệp Python (*.py)", "Tất cả tệp (*)"]
        currentFolder: files.lastOpenFolder
        onAccepted: files.openFile(selectedFile)
    }
    FileDialog {
        id: saveDialog
        title: "Lưu tệp Python"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Tệp Python (*.py)", "Tất cả tệp (*)"]
        currentFolder: files.lastOpenFolder
        onAccepted: files.saveAs(selectedFile, editor.text)
    }

    C.SettingsDialog {
        id: settingsDialog
        objectName: "settingsDialog"
        anchors.centerIn: Overlay.overlay
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Toolbar — persistent across the home screen and the IDE.
        // Rounded corners so it reads as a floating bar; the same margin is
        // used everywhere (matches the editor↔console gap in IDE mode). ──
        C.ToolBar {
            Layout.fillWidth: true
            Layout.margins: Theme.space_sm
            homeMode: root.homeActive
            running: execution.running
            replActive: root.replActive
            onBackRequested: root.homeActive = true
            onNewRequested: files.newFile()
            onOpenRequested: openDialog.open()
            onSaveRequested: files.hasFile ? files.save(editor.text) : saveDialog.open()
            onRunRequested: execution.run(editor.text)
            onStopRequested: execution.stop()
            onReplToggled: function(active) { root.replActive = active; execution.setReplMode(active) }
            onSettingsRequested: settingsDialog.open()
        }

        V.HomePanel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // No top margin — the toolbar's own bottom margin already
            // supplies that gap (see the matching main-area Item below).
            Layout.leftMargin: Theme.space_sm
            Layout.rightMargin: Theme.space_sm
            Layout.bottomMargin: Theme.space_sm
            visible: root.homeActive
            onCreateRequested: root.homeActive = false
        }

        // ── Main area: editor (with its own file-tab header) beside the
        // terminal, or REPL full — the file tab lives inside EditorPanel now,
        // snapped to the editor it names instead of floating separately. ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // No top margin — the toolbar's own bottom margin already supplies
            // that gap; adding one here would double it (see IDE screenshot).
            Layout.leftMargin: Theme.space_sm
            Layout.rightMargin: Theme.space_sm
            Layout.bottomMargin: Theme.space_sm
            visible: !root.homeActive

            // Editor beside terminal (script mode) — each pane floats as its
            // own rounded card; the handle's gap is transparent so the two
            // cards read as separate, not one panel with a divider.
            SplitView {
                anchors.fill: parent
                visible: !root.replActive
                orientation: Qt.Horizontal

                handle: Item {
                    implicitWidth: Theme.space_sm
                    implicitHeight: Theme.space_sm
                }

                V.EditorPanel {
                    id: editor
                    SplitView.fillWidth: true
                    SplitView.minimumWidth: 300
                    text: "# NEO Code\nfor i in range(3):\n    print(\"Xin chào\", i)\n"
                }

                V.TerminalPanel {
                    SplitView.preferredWidth: 380
                    SplitView.minimumWidth: 220
                }
            }

            // REPL takes over the whole area (interactive mode)
            V.ReplPanel {
                anchors.fill: parent
                visible: root.replActive
            }
        }
    }

    // Editor content follows file lifecycle
    Connections {
        target: signalBus
        function onFileOpened(path, content) { editor.text = content }
        function onFileNew() { editor.text = "" }
    }
}
