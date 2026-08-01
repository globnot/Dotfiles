import QtQuick 2.15

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#fbf1c7"
    focus: true

    property int sessionIndex: sessionModel.lastIndex

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorText.text = "Échec de connexion"
        }
    }

    // Ombre dure décalée (faux noir, pas de flou) derrière la carte
    Rectangle {
        width: card.width
        height: card.height
        x: card.x + 6
        y: card.y + 6
        radius: 4
        color: "#1d2021"
    }

    Rectangle {
        id: card
        width: 420
        height: 420
        anchors.centerIn: parent
        color: "#fbf1c7"
        border.width: 4
        border.color: "#e91e8c"
        radius: 4

        Column {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 14

            Text {
                text: Qt.formatDateTime(new Date(), "HH:mm")
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 44
                font.bold: true
                color: "#3c3836"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: Qt.formatDateTime(new Date(), "dddd d MMMM")
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 14
                color: "#504945"
                anchors.horizontalCenter: parent.horizontalCenter
                bottomPadding: 10
            }

            Rectangle {
                width: parent.width
                height: 46
                radius: 4
                color: "#ebdbb2"
                border.width: username.activeFocus ? 3 : 2
                border.color: username.activeFocus ? "#e91e8c" : "#1d2021"

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.margins: 12
                    text: userModel.lastUser
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 15
                    color: "#3c3836"
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    KeyNavigation.tab: password
                }
            }

            Rectangle {
                width: parent.width
                height: 46
                radius: 4
                color: "#ebdbb2"
                border.width: password.activeFocus ? 3 : 2
                border.color: password.activeFocus ? "#e91e8c" : "#1d2021"

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.margins: 12
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 15
                    color: "#3c3836"
                    echoMode: TextInput.Password
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    focus: true
                    Keys.onReturnPressed: sddm.login(username.text, password.text, root.sessionIndex)
                    KeyNavigation.tab: loginButton
                }
            }

            Text {
                id: errorText
                height: 16
                color: "#9d0006"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                width: parent.width
                height: 54

                Rectangle {
                    // ombre dure décalée, même principe que la carte
                    y: 4
                    width: parent.width
                    height: 50
                    radius: 4
                    color: "#1d2021"
                }

                Rectangle {
                    id: loginButton
                    width: parent.width
                    height: 50
                    radius: 4
                    color: (loginMouse.containsMouse || loginButton.activeFocus) ? "#e91e8c" : "#ebdbb2"
                    border.width: 3
                    border.color: "#1d2021"
                    activeFocusOnTab: true

                    Text {
                        anchors.centerIn: parent
                        text: "Login"
                        font.family: "JetBrainsMono Nerd Font Mono"
                        font.pixelSize: 16
                        font.bold: true
                        color: (loginMouse.containsMouse || loginButton.activeFocus) ? "#fbf1c7" : "#3c3836"
                    }

                    MouseArea {
                        id: loginMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: sddm.login(username.text, password.text, root.sessionIndex)
                    }

                    Keys.onReturnPressed: sddm.login(username.text, password.text, root.sessionIndex)
                }
            }
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 30
        spacing: 12

        Repeater {
            model: [
                { "icon": "", "fn": "poweroff" },
                { "icon": "", "fn": "reboot" },
                { "icon": "", "fn": "suspend" }
            ]
            delegate: Item {
                width: 58
                height: 58

                Rectangle {
                    // ombre dure décalée, même principe que la carte
                    x: 4
                    y: 4
                    width: 54
                    height: 54
                    radius: 4
                    color: "#1d2021"
                }

                Rectangle {
                    width: 54
                    height: 54
                    radius: 4
                    color: pbMouse.containsMouse ? "#e91e8c" : "#ebdbb2"
                    border.width: 3
                    border.color: "#1d2021"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.family: "JetBrainsMono Nerd Font Mono"
                        font.pixelSize: 20
                        color: pbMouse.containsMouse ? "#fbf1c7" : "#3c3836"
                    }

                    MouseArea {
                        id: pbMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.fn === "poweroff") sddm.powerOff()
                            else if (modelData.fn === "reboot") sddm.reboot()
                            else if (modelData.fn === "suspend") sddm.suspend()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: password.focus = true
}
