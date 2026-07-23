// Chơi's right column — arm telemetry above, program output below, in the same
// vertical SplitView Học uses for Expected/Result.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"

SplitView {
    id: root
    orientation: Qt.Vertical

    handle: Item {
        implicitWidth: Theme.space_sm
        implicitHeight: Theme.space_sm
    }

    ArmStatusPane {
        SplitView.preferredHeight: 190
        SplitView.minimumHeight: 140
    }

    ResultConsole {
        SplitView.fillHeight: true
        SplitView.minimumHeight: 90
        showStatusLines: true
    }
}
