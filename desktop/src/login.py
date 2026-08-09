from __future__ import annotations

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QColor
from PyQt6.QtWidgets import (
    QApplication,
    QFrame,
    QGraphicsDropShadowEffect,
    QLabel,
    QLineEdit,
    QMessageBox,
    QPushButton,
    QVBoxLayout,
)

from api import API
from theme import Palette, button_style, card_style, input_style


class LoginScreen(QFrame):
    login_success = pyqtSignal(dict)

    def __init__(self, api: API):
        super().__init__()
        self.api = api
        self.setObjectName("LoginScreen")
        self._setup_ui()

    def _setup_ui(self) -> None:
        outer = QVBoxLayout(self)
        outer.setAlignment(Qt.AlignmentFlag.AlignCenter)
        outer.setContentsMargins(24, 24, 24, 24)

        card = QFrame()
        card.setObjectName("LoginCard")
        card.setFixedSize(420, 520)
        card.setStyleSheet(f"#LoginCard {{ {card_style()} }}")

        shadow = QGraphicsDropShadowEffect(self)
        shadow.setBlurRadius(40)
        shadow.setOffset(0, 8)
        shadow.setColor(QColor(0, 0, 0, 80))
        card.setGraphicsEffect(shadow)

        layout = QVBoxLayout(card)
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.setSpacing(14)
        layout.setContentsMargins(40, 40, 40, 40)

        logo = QLabel("MA")
        logo.setAlignment(Qt.AlignmentFlag.AlignCenter)
        logo.setStyleSheet(f"font-size: 30px; font-weight: bold; color: {Palette.PRIMARY};")
        layout.addWidget(logo)

        title = QLabel("پنل انباردار")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title.setStyleSheet(f"font-size: 20px; font-weight: bold; color: {Palette.PRIMARY};")
        layout.addWidget(title)

        subtitle = QLabel("ورود ایمن به نرم افزار مدیریت انبار")
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        subtitle.setStyleSheet(f"font-size: 12px; color: {Palette.TEXT_MUTED}; margin-bottom: 8px;")
        layout.addWidget(subtitle)

        self.phone_input = self._build_input("شماره موبایل (09xxxxxxxxx)")
        layout.addWidget(self.phone_input)

        self.pass_input = self._build_input("رمز عبور", password=True)
        self.pass_input.returnPressed.connect(self._login)
        layout.addWidget(self.pass_input)

        self.login_btn = QPushButton("ورود به پنل")
        self.login_btn.setMinimumHeight(48)
        self.login_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        self.login_btn.setStyleSheet(button_style())
        self.login_btn.clicked.connect(self._login)
        layout.addWidget(self.login_btn)

        self.status_label = QLabel("")
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.status_label.setStyleSheet(f"font-size: 11px; color: {Palette.TEXT_MUTED};")
        layout.addWidget(self.status_label)

        version_label = QLabel("Desktop v3.0")
        version_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        version_label.setStyleSheet("font-size: 10px; color: #555; margin-top: 8px;")
        layout.addWidget(version_label)

        outer.addWidget(card, alignment=Qt.AlignmentFlag.AlignCenter)

    def _build_input(self, placeholder: str, password: bool = False) -> QLineEdit:
        field = QLineEdit()
        field.setPlaceholderText(placeholder)
        field.setAlignment(Qt.AlignmentFlag.AlignCenter)
        field.setMinimumHeight(46)
        field.setStyleSheet(input_style())
        if password:
            field.setEchoMode(QLineEdit.EchoMode.Password)
        return field

    def _set_busy(self, busy: bool) -> None:
        self.login_btn.setEnabled(not busy)
        self.login_btn.setText("در حال ورود..." if busy else "ورود به پنل")
        self.status_label.setText("در حال اعتبارسنجی اطلاعات..." if busy else "")

    def reset_form(self) -> None:
        self.phone_input.clear()
        self.pass_input.clear()
        self.status_label.clear()
        self.phone_input.setFocus()

    def _login(self) -> None:
        phone = self.phone_input.text().strip()
        password = self.pass_input.text()
        if not phone or not password:
            QMessageBox.warning(self, "خطا", "شماره موبایل و رمز عبور الزامی است.")
            return

        self._set_busy(True)
        QApplication.processEvents()
        try:
            data = self.api.login(phone, password)
            if data.get("user", {}).get("role") != "WAREHOUSE_KEEPER":
                raise PermissionError("فقط انبارداران مجاز به ورود هستند.")
            self.login_success.emit(data)
        except Exception as exc:
            QMessageBox.critical(self, "خطا", str(exc))
        finally:
            self._set_busy(False)
