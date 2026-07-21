// NEO Code — main window. A single focused canvas: toolbar, file header,
// editor/terminal (or REPL). No sidebar — there is nothing left to navigate to.
// Qt 6.4-compatible.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import "components" as C

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: "NEO Code" + (files.hasFile ? " — " + files.currentPath.split("/").pop() : "")
    color: Theme.background

    property bool replActive: false

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

        // ── Toolbar ────────────────────────────────────────────────────────
        C.ToolBar {
            Layout.fillWidth: true
            running: execution.running
            replActive: root.replActive
            onNewRequested: files.newFile()
            onOpenRequested: openDialog.open()
            onSaveRequested: files.hasFile ? files.save(editor.text) : saveDialog.open()
            onRunRequested: execution.run(editor.text)
            onStopRequested: execution.stop()
            onReplToggled: function(active) { root.replActive = active; execution.setReplMode(active) }
            onSettingsRequested: settingsDialog.open()
        }

        // ── File header (VS Code-style active file tab) ───────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            visible: !root.replActive
            color: Theme.surface_alt

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.border }

            Rectangle {
                id: fileTab
                height: parent.height
                width: tabRow.implicitWidth + 2 * Theme.space_base
                color: Theme.surface

                Rectangle { anchors.top: parent.top; width: parent.width; height: 2; color: Theme.primary }

                RowLayout {
                    id: tabRow
                    anchors.centerIn: parent
                    spacing: Theme.space_xs
                    C.Icon { name: "python"; size: 14; color: Theme.primary }
                    Label {
                        text: files.hasFile ? files.currentPath.split("/").pop() : "Chưa đặt tên"
                        font.pixelSize: Theme.font_body
                        color: Theme.text
                    }
                }
            }
        }

        // ── Main area: editor/terminal split, or REPL full ────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Editor over terminal (script mode)
            SplitView {
                anchors.fill: parent
                visible: !root.replActive
                orientation: Qt.Vertical

                C.EditorPanel {
                    id: editor
                    SplitView.fillHeight: true
                    SplitView.minimumHeight: 200
                    text: "# NEO Code\nfor i in range(3):\n    print(\"Xin chào\", i)\n"
                }

                C.TerminalPanel {
                    SplitView.preferredHeight: 180
                    SplitView.minimumHeight: 80
                }
            }

            // REPL takes over the whole area (interactive mode)
            C.ReplPanel {
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
