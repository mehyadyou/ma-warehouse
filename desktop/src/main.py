from __future__ import annotations

import sys

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QFont
from PyQt6.QtWidgets import (
    QApplication,
    QFrame,
    QHBoxLayout,
    QLabel,
    QListWidget,
    QListWidgetItem,
    QMainWindow,
    QPushButton,
    QStackedWidget,
    QVBoxLayout,
    QWidget,
)

from api import API
from dashboard import Dashboard
from login import LoginScreen
from socket_client import SocketClient
from theme import Palette, app_stylesheet, button_style, sidebar_list_style, sidebar_style


class Sidebar(QFrame):
    nav_changed = pyqtSignal(int)
    logout_requested = pyqtSignal()

    def __init__(self, user_name: str = ""):
        super().__init__()
        self.setFixedWidth(240)
        self.setStyleSheet(sidebar_style())
        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 22, 16, 16)
        layout.setSpacing(10)

        logo = QLabel("MA WAREHOUSE")
        logo.setStyleSheet(f"color: {Palette.PRIMARY}; font-size: 16px; font-weight: bold;")
        logo.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(logo)

        self.user_label = QLabel(user_name or "انباردار")
        self.user_label.setStyleSheet(f"color: {Palette.TEXT_MUTED}; font-size: 11px;")
        self.user_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.user_label)

        separator = QFrame()
        separator.setFrameShape(QFrame.Shape.HLine)
        separator.setStyleSheet(f"border: 0.5px solid {Palette.BORDER}; margin: 8px 0;")
        layout.addWidget(separator)

        self.nav_list = QListWidget()
        self.nav_list.setStyleSheet(sidebar_list_style())
        for item in ["ورودی‌های اخیر", "تکمیل شده‌ها", "تاریخچه تراکنش‌ها", "بیجک"]:
            self.nav_list.addItem(QListWidgetItem(item))
        self.nav_list.setCurrentRow(0)
        self.nav_list.currentRowChanged.connect(self.nav_changed.emit)
        layout.addWidget(self.nav_list)
        layout.addStretch()

        logout_btn = QPushButton("خروج از حساب")
        logout_btn.setStyleSheet(button_style("danger"))
        logout_btn.clicked.connect(self.logout_requested.emit)
        layout.addWidget(logout_btn)


class WorkspaceScreen(QWidget):
    def __init__(self, api: API, socket_client: SocketClient, user_name: str):
        super().__init__()
        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        self.dashboard = Dashboard(api, socket_client)
        self.sidebar = Sidebar(user_name)
        self.sidebar.nav_changed.connect(self.dashboard.tabs.setCurrentIndex)

        layout.addWidget(self.dashboard, 1)
        layout.addWidget(self.sidebar)

    def load(self) -> None:
        self.dashboard.load_data()


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.api = API()
        self.socket_client = SocketClient(self.api.base_url)
        self.workspace: WorkspaceScreen | None = None

        self.setWindowTitle("پنل انباردار — MA Warehouse")
        self.setMinimumSize(1180, 720)
        self.setStyleSheet(app_stylesheet())

        self.stack = QStackedWidget()
        self.setCentralWidget(self.stack)

        self.login_screen = LoginScreen(self.api)
        self.login_screen.login_success.connect(self._show_dashboard)
        self.stack.addWidget(self.login_screen)

    def _show_dashboard(self, user_data: dict) -> None:
        user = user_data.get("user", {})
        user_name = user.get("name", "انباردار")

        # Connect to Socket.IO with the authentication token
        token = user_data.get("token")
        if token:
            self.socket_client.connect(token)

        if self.workspace is not None:
            self.stack.removeWidget(self.workspace)
            self.workspace.deleteLater()

        self.workspace = WorkspaceScreen(self.api, self.socket_client, user_name)
        self.workspace.sidebar.logout_requested.connect(self._logout)
        self.stack.addWidget(self.workspace)
        self.stack.setCurrentWidget(self.workspace)
        self.workspace.load()

    def _logout(self) -> None:
        self.api.logout()
        self.socket_client.disconnect()
        self.login_screen.reset_form()
        self.stack.setCurrentWidget(self.login_screen)
        if self.workspace is not None:
            self.stack.removeWidget(self.workspace)
            self.workspace.deleteLater()
            self.workspace = None

    def closeEvent(self, event) -> None:
        """Clean up Socket.IO connection on window close."""
        self.socket_client.disconnect()
        event.accept()


def run() -> int:
    app = QApplication(sys.argv)
    app.setStyle("Fusion")
    app.setFont(QFont("Tahoma", 10))
    window = MainWindow()
    window.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(run())
