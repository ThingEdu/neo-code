// Học (Learn) mode — collapsible/resizable curriculum sidebar, its own
// editor instance (kept separate from Sáng tạo's so a lesson attempt never
// bleeds into freeform code or vice versa), and the stacked Expected/Result
// console. Self-contained: binds straight to the lessonsController context
// property rather than having MainWindow broker it.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/common" as Common
import "../components/curriculums" as Curriculums

Item {
    id: root

    property alias currentText: editor.text

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal

        handle: Item {
            implicitWidth: Theme.space_sm
            implicitHeight: Theme.space_sm
        }

        Curriculums.LessonSidebar {
            id: lessonSidebar
            SplitView.preferredWidth: collapsed ? 56 : 300
            SplitView.minimumWidth: collapsed ? 56 : 220
            SplitView.maximumWidth: collapsed ? 56 : 420
            view: lessonsController.view
            topics: lessonsController.topics
            topicTitle: lessonsController.topicTitle
            nodes: lessonsController.nodes
            currentChallenge: lessonsController.currentChallenge
            onTopicSelected: function(topicId) { lessonsController.selectTopic(topicId) }
            onNodeSelected: function(nodeId) { lessonsController.selectLesson(nodeId) }
            onBlockTapped: function(insertText) { editor.insertAtCursor(insertText) }
            onBackRequested: lessonsController.back()
        }

        Common.EditorPanel {
            id: editor
            SplitView.fillWidth: true
            SplitView.minimumWidth: 260
            text: "# Chọn một bài học ở bên trái để bắt đầu\n"
        }

        Curriculums.LessonConsole {
            SplitView.preferredWidth: 340
            SplitView.minimumWidth: 260
            expectedText: lessonsController.currentChallenge ? lessonsController.currentChallenge.expected : ""
        }
    }

    // Seed the editor with each lesson's starter code when opened.
    Connections {
        target: lessonsController
        function onLessonOpened(starter) { editor.text = starter }
    }

    // Editor content also follows the file lifecycle, same as Sáng tạo, so
    // New/Open/Save in the toolbar work here too.
    Connections {
        target: signalBus
        function onFileOpened(path, content) { editor.text = content }
        function onFileNew() { editor.text = "" }
    }
}
