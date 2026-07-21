// NEO Code — main window. Toolbar + one of three views: home (mode select),
// Sáng tạo (editor/terminal or REPL), or Học (curriculum sidebar + editor +
// Expected/Result console). Qt 6.4-compatible.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Dialogs
import "components/common" as Common
import "views" as V

ApplicationWindow {
    id: root
    width: 1280
    height: 800
    visible: true
    title: "NEO Code" + (files.hasFile ? " — " + files.currentPath.split("/").pop() : "")
    color: Theme.background

    property bool replActive: false
    property string mode: "home"   // home | create | learn
    readonly property bool homeActive: root.mode === "home"
    readonly property bool learnActive: root.mode === "learn"

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
        onAccepted: files.saveAs(selectedFile, root.learnActive ? learnView.currentText : createView.currentText)
    }

    Common.SettingsDialog {
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
        Common.ToolBar {
            Layout.fillWidth: true
            Layout.margins: Theme.space_sm
            homeMode: root.homeActive
            learnMode: root.learnActive
            running: execution.running
            replActive: root.replActive
            onBackRequested: root.mode = "home"
            onNewRequested: files.newFile()
            onOpenRequested: openDialog.open()
            onSaveRequested: files.hasFile ? files.save(root.learnActive ? learnView.currentText : createView.currentText) : saveDialog.open()
            onRunRequested: execution.run(root.learnActive ? learnView.currentText : createView.currentText)
            onStopRequested: execution.stop()
            onReplToggled: function(active) { root.replActive = active; execution.setReplMode(active) }
            onSettingsRequested: settingsDialog.open()
        }

        V.HomeView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // No top margin — the toolbar's own bottom margin already
            // supplies that gap (see the matching main-area views below).
            Layout.leftMargin: Theme.space_sm
            Layout.rightMargin: Theme.space_sm
            Layout.bottomMargin: Theme.space_sm
            visible: root.homeActive
            onCreateRequested: root.mode = "create"
            onLearnRequested: root.mode = "learn"
        }

        V.CreateView {
            id: createView
            Layout.fillWidth: true
            Layout.fillHeight: true
            // No top margin — the toolbar's own bottom margin already supplies
            // that gap; adding one here would double it (see IDE screenshot).
            Layout.leftMargin: Theme.space_sm
            Layout.rightMargin: Theme.space_sm
            Layout.bottomMargin: Theme.space_sm
            visible: root.mode === "create"
            replActive: root.replActive
        }

        V.LearnView {
            id: learnView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Theme.space_sm
            Layout.rightMargin: Theme.space_sm
            Layout.bottomMargin: Theme.space_sm
            visible: root.mode === "learn"
        }
    }
}
