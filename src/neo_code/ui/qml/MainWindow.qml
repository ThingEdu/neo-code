// NEO Code — main window (Phase 3: toolbar + execution + terminal).
// The editor is a temporary plain TextArea; Phase 3 step 4 swaps in the real
// EditorPanel (spike: highlighter + gutter) behind the same `.text` contract.
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

    readonly property var navEntries: [
        { key: "lessons", icon: "book_open", label: "Bài học" },
        { key: "robot",   icon: "robot",     label: "Robot" }
    ]
    property string activeNav: "lessons"
    property bool sidebarCollapsed: false
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

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ── Activity bar ──────────────────────────────────────────────
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 68
                color: Theme.activity_bar_bg

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: Theme.space_sm
                    spacing: Theme.space_xs

                    Repeater {
                        model: root.navEntries
                        delegate: Rectangle {
                            id: navItem
                            required property var modelData
                            readonly property bool active: root.activeNav === navItem.modelData.key
                            Layout.preferredWidth: 68
                            Layout.preferredHeight: 60
                            color: "transparent"

                            // Rounded selection pill
                            Rectangle {
                                anchors.centerIn: parent
                                width: 52; height: 52
                                radius: Theme.radius_card
                                color: navItem.active ? Theme.primary_soft
                                       : navHover.hovered ? Theme.surface_alt : "transparent"
                            }
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 3
                                C.Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    name: navItem.modelData.icon; size: 23
                                    color: navItem.active ? Theme.primary : Theme.activity_bar_icon
                                }
                                Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: navItem.modelData.label; font.pixelSize: 9
                                    font.bold: navItem.active
                                    color: navItem.active ? Theme.primary : Theme.activity_bar_icon
                                }
                            }
                            HoverHandler { id: navHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.activeNav === navItem.modelData.key)
                                        root.sidebarCollapsed = !root.sidebarCollapsed
                                    else { root.activeNav = navItem.modelData.key; root.sidebarCollapsed = false }
                                }
                            }
                        }
                    }
                }
                Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.border }
            }

            // ── Sidebar content panel (collapsible) ───────────────────────
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: root.sidebarCollapsed ? 0 : 272
                visible: !root.sidebarCollapsed
                clip: true
                color: Theme.background

                C.LessonsPanel {
                    anchors.fill: parent
                    visible: root.activeNav === "lessons"
                    onInsertCode: function(code) { editor.text = code; root.replActive = false }
                }
                C.RobotPanel {
                    anchors.fill: parent
                    visible: root.activeNav === "robot"
                    onInsertCode: function(code) { editor.text = code; root.replActive = false }
                }
                Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.border }
            }

            // ── Main area: editor/terminal split, or REPL full ────────────
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

        // ── Status bar ──────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: Theme.surface
            Rectangle { width: parent.width; height: 1; color: Theme.border }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12
                text: (execution.running ? "Đang chạy… · " : "Sẵn sàng · ")
                      + (files.hasFile ? files.currentPath.split("/").pop() : "Chưa đặt tên")
                color: Theme.text_secondary
                font.pixelSize: 12
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
