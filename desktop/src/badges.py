from __future__ import annotations

from collections import OrderedDict
from dataclasses import dataclass
from typing import Any

from PyQt6.QtCore import QMarginsF, QSizeF, Qt, pyqtSignal
from PyQt6.QtGui import QColor, QFont, QPageLayout, QPageSize, QPainter
from PyQt6.QtPrintSupport import QPrintDialog, QPrinter
from PyQt6.QtWidgets import (
    QCheckBox,
    QFrame,
    QGraphicsDropShadowEffect,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QScrollArea,
    QSizePolicy,
    QVBoxLayout,
    QWidget,
)

from theme import Palette, button_style


@dataclass(frozen=True)
class BadgeConfig:
    width_mm: float = 58
    height_mm: float = 77
    width_px: int = 200
    height_px: int = 300
    font_header: int = 8
    font_title: int = 10
    font_row: int = 7
    font_seq: int = 8
    font_tracking: int = 6
    font_main: str = "Segoe UI"
    font_barcode_family: str = "Courier New"
    color_bg: str = "#ffffff"
    color_text: str = "#000000"
    color_muted: str = "#4a4a4a"
    color_border: str = "#e0e0e0"
    color_divider: str = "#dcdcdc"
    color_accent: str = "#1d4ed8"
    padding: int = 8


ORDER_STATUS_LABELS = {
    "PENDING": "در انتظار",
    "IN_TRANSIT": "در مسیر ارسال",
    "DELIVERED": "تحویل شده",
    "CANCELLED": "لغو شده",
}


def short_order_id(order_id: str) -> str:
    return f"MA-{order_id[:8].upper().replace('-', '')}"


def group_badges_by_order(badges: list[dict]) -> OrderedDict[str, list[dict]]:
    groups: OrderedDict[str, list[dict]] = OrderedDict()
    for badge in badges:
        order_id = badge.get("orderId") or "بدون سفارش"
        groups.setdefault(order_id, []).append(badge)
    for items in groups.values():
        items.sort(key=lambda item: item.get("sequence") or 0)
    return groups


class BadgeSheetWidget(QFrame):
    def __init__(self, badge: dict[str, Any], config: BadgeConfig | None = None, parent: QWidget | None = None):
        super().__init__(parent)
        self.config = config or BadgeConfig()
        self.badge = badge

        self.setObjectName("BadgeSheetWidget")
        self.setFixedSize(self.config.width_px, self.config.height_px)
        self.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        self.setStyleSheet(
            f"""
            QFrame#BadgeSheetWidget {{
                background: {self.config.color_bg};
                border: 1px solid {self.config.color_border};
                border-radius: 10px;
            }}
            QFrame#BadgeSheetWidget * {{
                background: transparent;
            }}
            """
        )

        shadow = QGraphicsDropShadowEffect(self)
        shadow.setBlurRadius(10)
        shadow.setOffset(0, 2)
        shadow.setColor(QColor(0, 0, 0, 30))
        self.setGraphicsEffect(shadow)

        layout = QVBoxLayout(self)
        layout.setSpacing(2)
        layout.setContentsMargins(
            self.config.padding,
            self.config.padding,
            self.config.padding,
            self.config.padding,
        )

        header_font = QFont(self.config.font_main, self.config.font_header)
        header_font.setBold(True)
        header = QLabel("MA WAREHOUSE")
        header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        header.setFont(header_font)
        header.setStyleSheet(
            f"color: {self.config.color_text}; border-bottom: 2px solid {self.config.color_text}; padding-bottom: 1px;"
        )
        header.setFixedHeight(18)
        layout.addWidget(header)

        title_font = QFont(self.config.font_main, self.config.font_title)
        title_font.setBold(True)
        sequence = int(badge.get("sequence") or 1)
        total = int(badge.get("total") or sequence)
        title = QLabel(f"بیجک سفارش {sequence} از {total}")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title.setFont(title_font)
        title.setStyleSheet(f"color: {self.config.color_text};")
        title.setFixedHeight(20)
        layout.addWidget(title)

        subtitle = QLabel("برگه بیجک")
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        subtitle.setFont(QFont(self.config.font_main, 7))
        subtitle.setStyleSheet(f"color: {self.config.color_muted};")
        subtitle.setFixedHeight(14)
        layout.addWidget(subtitle)

        layout.addWidget(self._make_divider())

        order = badge.get("order") or {}
        rows = [
            ("فرستنده", badge.get("senderName")),
            ("گیرنده", badge.get("receiverName")),
            ("شهر", order.get("city")),
            ("آدرس", order.get("address")),
            ("کد پستی", order.get("postalCode")),
            ("شیوه ارسال", order.get("shippingMethod")),
            ("باربری", order.get("carrier")),
        ]
        for label_text, value in rows:
            layout.addWidget(self._make_info_row(label_text, value))

        layout.addWidget(self._make_divider())

        order_ref = short_order_id(str(badge.get("orderId") or ""))
        ref_font = QFont(self.config.font_barcode_family, self.config.font_seq)
        ref_font.setBold(True)
        ref_label = QLabel(order_ref)
        ref_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        ref_label.setFont(ref_font)
        ref_label.setStyleSheet(f"color: {self.config.color_text}; letter-spacing: 1px;")
        ref_label.setFixedHeight(16)
        layout.addWidget(ref_label)

        created = str(badge.get("createdAt", ""))[:10] or "—"
        tracking_label = QLabel(f"MA-BADGE  |  {created}")
        tracking_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        tracking_label.setFont(QFont(self.config.font_main, self.config.font_tracking))
        tracking_label.setStyleSheet(f"color: {self.config.color_muted}; letter-spacing: 1px;")
        tracking_label.setFixedHeight(12)
        layout.addWidget(tracking_label)

    def _make_divider(self) -> QFrame:
        divider = QFrame()
        divider.setFrameShape(QFrame.Shape.HLine)
        divider.setStyleSheet(
            f"border: 0.5px dashed {self.config.color_divider}; margin: 2px 0;"
        )
        divider.setFixedHeight(5)
        return divider

    def _make_info_row(self, label_text: str, value_text: Any) -> QWidget:
        text = str(value_text or "—")
        row = QWidget()
        row_layout = QHBoxLayout(row)
        row_layout.setContentsMargins(0, 0, 0, 0)
        row_layout.setSpacing(4)

        label = QLabel(f"▸ {label_text}")
        label.setFont(QFont(self.config.font_main, self.config.font_row))
        label.setStyleSheet(f"color: {self.config.color_muted};")
        label.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)

        value = QLabel(text)
        value_font = QFont(self.config.font_main, self.config.font_row)
        value_font.setBold(True)
        value.setFont(value_font)
        value.setAlignment(Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
        value.setStyleSheet(f"color: {self.config.color_text};")
        value.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        value.setWordWrap(True)

        row_layout.addWidget(label)
        row_layout.addWidget(value, 1)

        metrics = value.fontMetrics()
        available_width = self.config.width_px - 2 * self.config.padding - label.sizeHint().width() - row_layout.spacing() - 4
        lines = max(1, -(-metrics.horizontalAdvance(text) // max(available_width, 1)))
        row.setFixedHeight(max(18, lines * (metrics.height() + 2) + 6))
        return row


def configure_badge_printer(printer: QPrinter, config: BadgeConfig) -> None:
    page_size = QPageSize(
        QSizeF(config.width_mm, config.height_mm),
        QPageSize.Unit.Millimeter,
        "WarehouseBadge",
    )
    page_layout = QPageLayout(
        page_size,
        QPageLayout.Orientation.Portrait,
        QMarginsF(0, 0, 0, 0),
    )
    printer.setPageLayout(page_layout)
    printer.setResolution(300)


def print_badge_batch(badge_widgets: list[BadgeSheetWidget], parent: QWidget | None = None) -> bool:
    if not badge_widgets:
        return False

    printer = QPrinter(QPrinter.PrinterMode.HighResolution)
    configure_badge_printer(printer, badge_widgets[0].config)

    dialog = QPrintDialog(printer, parent)
    if dialog.exec() != QPrintDialog.DialogCode.Accepted:
        return False

    painter = QPainter(printer)
    for index, badge_widget in enumerate(badge_widgets):
        if index > 0:
            printer.newPage()
        badge_widget.render(painter)
    painter.end()
    return True


class BadgeSheetCard(QWidget):
    selection_changed = pyqtSignal()

    def __init__(self, badge: dict[str, Any]):
        super().__init__()
        self.badge = badge
        self.sheet_widget = BadgeSheetWidget(badge)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        action_row = QHBoxLayout()
        action_row.setContentsMargins(4, 0, 4, 0)
        self.checkbox = QCheckBox("انتخاب برای چاپ")
        self.checkbox.setStyleSheet(f"color: {Palette.TEXT};")
        self.checkbox.stateChanged.connect(lambda _state: self.selection_changed.emit())
        action_row.addWidget(self.checkbox)
        action_row.addStretch()

        print_btn = QPushButton("چاپ تکی")
        print_btn.setStyleSheet(button_style("secondary"))
        print_btn.clicked.connect(self.print_single)
        action_row.addWidget(print_btn)
        layout.addLayout(action_row)

        layout.addWidget(self.sheet_widget, alignment=Qt.AlignmentFlag.AlignCenter)

    def set_selected(self, selected: bool) -> None:
        self.checkbox.setChecked(selected)

    def is_selected(self) -> bool:
        return self.checkbox.isChecked()

    def print_single(self) -> bool:
        if not self.sheet_widget.badge.get("receiverName"):
            QMessageBox.information(
                self, "چاپ بیجک", "اطلاعات گیرنده این بیجک کامل نیست."
            )
            return False
        return print_badge_batch([self.sheet_widget], self)


class BadgeGridWidget(QWidget):
    selection_changed = pyqtSignal()

    def __init__(self, columns: int = 3):
        super().__init__()
        self.columns = columns
        self.cards: list[BadgeSheetCard] = []
        self._layout = QGridLayout(self)
        self._layout.setAlignment(Qt.AlignmentFlag.AlignTop | Qt.AlignmentFlag.AlignLeft)
        self._layout.setContentsMargins(0, 0, 0, 0)
        self._layout.setHorizontalSpacing(12)
        self._layout.setVerticalSpacing(12)

    def clear(self) -> None:
        self.cards.clear()
        while self._layout.count():
            child = self._layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

    def set_badges(self, badges: list[dict]) -> None:
        self.clear()
        for index, badge in enumerate(badges):
            row = index // self.columns
            col = index % self.columns
            card = BadgeSheetCard(badge)
            card.selection_changed.connect(self.selection_changed.emit)
            self.cards.append(card)
            self._layout.addWidget(card, row, col)
        self.selection_changed.emit()

    def set_all_selected(self, selected: bool) -> None:
        for card in self.cards:
            card.set_selected(selected)
        self.selection_changed.emit()

    def selected_widgets(self) -> list[BadgeSheetWidget]:
        return [card.sheet_widget for card in self.cards if card.is_selected()]

    def selected_count(self) -> int:
        return len(self.selected_widgets())

    def total_count(self) -> int:
        return len(self.cards)


class BadgeGroupCard(QFrame):
    def __init__(self, order_id: str, badges: list[dict]):
        super().__init__()
        self.badges = badges
        self.total = len(badges)
        for index, badge in enumerate(badges):
            badge["total"] = self.total

        self.setStyleSheet(
            f"""
            QFrame {{
                background: {Palette.SURFACE_ALT};
                border: 1px solid {Palette.BORDER};
                border-radius: 12px;
            }}
            """
        )

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 12, 16, 16)
        layout.setSpacing(12)

        header = QHBoxLayout()
        title_box = QVBoxLayout()
        title_box.setSpacing(2)

        order = (badges[0].get("order") or {}) if badges else {}
        warehouse = (order.get("warehouse") or {})
        warehouse_name = warehouse.get("name") or "انبار نامشخص"
        status = order.get("status") or "PENDING"
        status_label = ORDER_STATUS_LABELS.get(status, status)

        title = QLabel(f"{short_order_id(order_id)} — سفارش {warehouse_name}")
        title.setStyleSheet(f"color: {Palette.TEXT}; font-size: 14px; font-weight: bold;")
        title_box.addWidget(title)

        subtitle = QLabel(
            f"وضعیت: {status_label} | تاریخ ثبت: {str(badges[0].get('createdAt', ''))[:10] or 'نامشخص'}"
        )
        subtitle.setStyleSheet(f"color: {Palette.TEXT_MUTED}; font-size: 11px;")
        title_box.addWidget(subtitle)

        header.addLayout(title_box, 1)

        count_badge = QLabel(f"{self.total} بیجک")
        count_badge.setStyleSheet(
            f"""
            background: rgba(74, 222, 128, 0.15);
            color: {Palette.PRIMARY};
            border-radius: 12px;
            padding: 4px 12px;
            font-size: 12px;
            font-weight: bold;
            """
        )
        header.addWidget(count_badge)
        layout.addLayout(header)

        action_row = QHBoxLayout()
        self.select_all_btn = QPushButton("انتخاب همه")
        self.select_all_btn.setStyleSheet(button_style("secondary"))
        self.select_all_btn.clicked.connect(lambda: self.grid.set_all_selected(True))
        action_row.addWidget(self.select_all_btn)

        self.clear_selection_btn = QPushButton("لغو انتخاب")
        self.clear_selection_btn.setStyleSheet(button_style("secondary"))
        self.clear_selection_btn.clicked.connect(lambda: self.grid.set_all_selected(False))
        action_row.addWidget(self.clear_selection_btn)

        self.print_selected_btn = QPushButton("چاپ انتخاب‌شده‌ها")
        self.print_selected_btn.setStyleSheet(button_style())
        self.print_selected_btn.clicked.connect(self._print_selected)
        action_row.addWidget(self.print_selected_btn)
        action_row.addStretch()
        layout.addLayout(action_row)

        self.selection_label = QLabel("0 مورد انتخاب شده")
        self.selection_label.setStyleSheet(f"font-size: 12px; color: {Palette.TEXT_MUTED};")
        layout.addWidget(self.selection_label)

        self.grid = BadgeGridWidget()
        self.grid.selection_changed.connect(self._update_selection_status)
        self.grid.set_badges(badges)
        layout.addWidget(self.grid)

    def _update_selection_status(self) -> None:
        selected_count = self.grid.selected_count()
        self.selection_label.setText(f"{selected_count} از {self.total} بیجک انتخاب شده")

    def _print_selected(self) -> None:
        selected_widgets = self.grid.selected_widgets()
        if not selected_widgets:
            QMessageBox.information(self, "چاپ بیجک", "ابتدا حداقل یک بیجک را انتخاب کنید.")
            return
        print_badge_batch(selected_widgets, self)


class BadgesTab(QWidget):
    def __init__(self, api):
        super().__init__()
        self.api = api

        layout = QVBoxLayout(self)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        toolbar = QHBoxLayout()
        self.summary_label = QLabel("بیجک‌های ثبت‌شده برای سفارش‌ها")
        self.summary_label.setStyleSheet(f"font-size: 13px; color: {Palette.TEXT_MUTED};")
        toolbar.addWidget(self.summary_label)
        toolbar.addStretch()

        refresh_btn = QPushButton("بارگذاری مجدد")
        refresh_btn.setStyleSheet(button_style("secondary"))
        refresh_btn.clicked.connect(self.load)
        toolbar.addWidget(refresh_btn)
        layout.addLayout(toolbar)

        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        self.scroll.setFrameShape(QFrame.Shape.NoFrame)

        self.container = QWidget()
        self.container_layout = QVBoxLayout(self.container)
        self.container_layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.container_layout.setSpacing(12)
        self.scroll.setWidget(self.container)
        layout.addWidget(self.scroll)

    def _build_state_label(self, text: str) -> QLabel:
        label = QLabel(text)
        label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        label.setStyleSheet(f"color: {Palette.TEXT_MUTED}; font-size: 15px; padding: 40px;")
        return label

    def load(self) -> None:
        while self.container_layout.count():
            child = self.container_layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

        try:
            badges = self.api.get_badges()
            groups = group_badges_by_order(badges)
            if not groups:
                self.summary_label.setText("هیچ بیجکی ثبت نشده است.")
                self.container_layout.addWidget(self._build_state_label("هنوز بیجکی برای سفارش‌ها ساخته نشده است."))
                return

            total = sum(len(items) for items in groups.values())
            self.summary_label.setText(
                f"{len(groups)} سفارش | {total} بیجک آماده چاپ"
            )
            for order_id, items in groups.items():
                self.container_layout.addWidget(BadgeGroupCard(order_id, items))
            self.container_layout.addStretch()
        except Exception as exc:
            self.summary_label.setText("خطا در دریافت اطلاعات")
            self.container_layout.addWidget(self._build_state_label(str(exc)))
