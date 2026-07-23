// NEO Code — main window. Toolbar + one of four views: home (mode select),
// Sáng tạo (editor/terminal or REPL), Học (curriculum sidebar + editor +
// Expected/Result console), or Chơi (arm panel + editor/REPL + arm status +
// console). Qt 6.4-compatible.
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
    property string mode: "home"   // home | create | learn | play
    readonly property bool homeActive: root.mode === "home"
    readonly property bool learnActive: root.mode === "learn"
    readonly property bool playActive: root.mode === "play"

    // Which editor the toolbar's Save/Run act on. A three-way ternary at every
    // call site was unreadable once Chơi arrived.
    function currentText() {
        if (root.learnActive) return learnView.currentText
        if (root.playActive) return playView.currentText
        return createView.currentText
    }

    // Chơi runs code through play_bootstrap so scripts get an `arm` object.
    function currentMode() { return root.playActive ? "arm" : "plain" }

    // A REPL is bound to the mode that started it — its namespace, and whether
    // it holds an `arm`, are both fixed at launch. Rather than reason about a
    // session outliving its mode, end it at the boundary.
    //
    // Tests `mode` directly, not the `playActive` binding: a change handler is
    // not ordered against the re-evaluation of bindings that derive from the
    // same property, so `playActive` can still read false in here.
    onModeChanged: {
        if (root.replActive) {
            root.replActive = false
            execution.setReplMode(false, "plain")
        }
        if (root.mode === "play") playController.open()
    }

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
        onAccepted: files.saveAs(selectedFile, root.currentText())
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
            playMode: root.playActive
            running: execution.running
            replActive: root.replActive
            onBackRequested: root.mode = "home"
            onNewRequested: files.newFile()
            onOpenRequested: openDialog.open()
            onSaveRequested: files.hasFile ? files.save(root.currentText()) : saveDialog.open()
            onRunRequested: execution.run(root.currentText(), root.currentMode())
            onStopRequested: execution.stop()
            onReplToggled: function(active) {
                root.replActive = active
                execution.setReplMode(active, root.currentMode())
            }
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
            onPlayRequested: root.mode = "play"
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

        V.PlayView {
            id: playView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Theme.space_sm
            Layout.rightMargin: Theme.space_sm
            Layout.bottomMargin: Theme.space_sm
            visible: root.playActive
            replActive: root.replActive
        }
    }
}
