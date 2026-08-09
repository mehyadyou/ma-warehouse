from __future__ import annotations

from collections import OrderedDict

from PyQt6.QtCore import QDate, Qt, pyqtSignal
from PyQt6.QtWidgets import (
    QAbstractItemView,
    QCheckBox,
    QDateEdit,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMessageBox,
    QPushButton,
    QScrollArea,
    QTableWidget,
    QTableWidgetItem,
    QTabWidget,
    QVBoxLayout,
    QWidget,
    QHeaderView,
)

from qr_renderer import QRLabelWidget, print_label_batch
from badges import BadgesTab
from theme import (
    Palette,
    button_style,
    header_bar_style,
    tab_style,
    table_style,
)
from socket_client import SocketClient


def extract_entry_date(carton: dict) -> str:
    created_at = str(carton.get("createdAt", "") or "")
    return created_at[:10] or "نامشخص"


def build_group_label(carton: dict) -> tuple[str, str]:
    model_name = (carton.get("model") or {}).get("name") or "بدون مدل"
    product_name = (carton.get("product") or {}).get("name") or "بدون محصول"
    entry_date = extract_entry_date(carton)
    title = model_name
    subtitle = f"{product_name} | تاریخ ورود: {entry_date}"
    return title, subtitle


def group_cartons_by_label(cartons: list[dict]) -> OrderedDict[tuple[str, str], list[dict]]:
    groups: OrderedDict[tuple[str, str], list[dict]] = OrderedDict()
    for carton in cartons:
        key = build_group_label(carton)
        groups.setdefault(key, []).append(carton)
    return groups


class SelectableLabelCard(QWidget):
    selection_changed = pyqtSignal()

    def __init__(self, carton: dict):
        super().__init__()
        self.carton = carton
        self.label_widget = QRLabelWidget(carton)

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

        layout.addWidget(self.label_widget, alignment=Qt.AlignmentFlag.AlignCenter)

    def set_selected(self, selected: bool) -> None:
        self.checkbox.setChecked(selected)

    def is_selected(self) -> bool:
        return self.checkbox.isChecked()

    def print_single(self) -> bool:
        return self.label_widget.print_label()


class LabelGridWidget(QWidget):
    selection_changed = pyqtSignal()

    def __init__(self, columns: int = 3):
        super().__init__()
        self.columns = columns
        self.cards: list[SelectableLabelCard] = []
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

    def set_labels(self, cartons: list[dict]) -> None:
        self.clear()
        for index, carton in enumerate(cartons):
            row = index // self.columns
            col = index % self.columns
            card = SelectableLabelCard(carton)
            card.selection_changed.connect(self.selection_changed.emit)
            self.cards.append(card)
            self._layout.addWidget(card, row, col)
        self.selection_changed.emit()

    def set_all_selected(self, selected: bool) -> None:
        for card in self.cards:
            card.set_selected(selected)
        self.selection_changed.emit()

    def selected_labels(self) -> list[QRLabelWidget]:
        return [card.label_widget for card in self.cards if card.is_selected()]

    def selected_count(self) -> int:
        return len(self.selected_labels())

    def total_count(self) -> int:
        return len(self.cards)


class AccordionItem(QFrame):
    def __init__(self, title: str, subtitle: str, cartons: list[dict]):
        super().__init__()
        self.title = title
        self.subtitle = subtitle
        self.cartons = cartons
        self.is_open = False
        self.content_loaded = False

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
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        self.header_btn = QFrame()
        self.header_btn.setCursor(Qt.CursorShape.PointingHandCursor)
        self.header_btn.setStyleSheet(
            f"""
            QFrame {{
                background: transparent;
            }}
            QFrame:hover {{
                background: {Palette.SURFACE_HOVER};
                border-radius: 12px;
            }}
            """
        )
        self.header_btn.mousePressEvent = lambda _event: self.toggle()

        header_layout = QHBoxLayout(self.header_btn)
        header_layout.setContentsMargins(16, 12, 16, 12)

        self.chevron = QLabel("▶")
        self.chevron.setStyleSheet(f"color: {Palette.TEXT_MUTED}; font-size: 12px;")
        self.chevron.setFixedWidth(20)
        header_layout.addWidget(self.chevron)

        title_box = QVBoxLayout()
        title_box.setContentsMargins(0, 0, 0, 0)
        title_box.setSpacing(2)

        title_label = QLabel(title)
        title_label.setStyleSheet(f"color: {Palette.TEXT}; font-size: 14px; font-weight: bold;")
        title_box.addWidget(title_label)

        subtitle_label = QLabel(subtitle)
        subtitle_label.setStyleSheet(f"color: {Palette.TEXT_MUTED}; font-size: 11px;")
        title_box.addWidget(subtitle_label)

        header_layout.addLayout(title_box, 1)

        count_badge = QLabel(str(len(cartons)))
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
        header_layout.addWidget(count_badge)
        layout.addWidget(self.header_btn)

        self.content = QWidget()
        self.content.setVisible(False)
        self.content.setStyleSheet("background: transparent; border: none;")
        content_layout = QVBoxLayout(self.content)
        content_layout.setContentsMargins(16, 8, 16, 16)
        content_layout.setSpacing(12)

        action_row = QHBoxLayout()
        self.select_all_btn = QPushButton("انتخاب همه")
        self.select_all_btn.setStyleSheet(button_style("secondary"))
        self.select_all_btn.clicked.connect(lambda: self.label_grid.set_all_selected(True))
        action_row.addWidget(self.select_all_btn)

        self.clear_selection_btn = QPushButton("لغو انتخاب")
        self.clear_selection_btn.setStyleSheet(button_style("secondary"))
        self.clear_selection_btn.clicked.connect(lambda: self.label_grid.set_all_selected(False))
        action_row.addWidget(self.clear_selection_btn)

        self.print_selected_btn = QPushButton("چاپ انتخاب‌شده‌ها")
        self.print_selected_btn.setStyleSheet(button_style())
        self.print_selected_btn.clicked.connect(self._print_selected)
        action_row.addWidget(self.print_selected_btn)
        action_row.addStretch()
        content_layout.addLayout(action_row)

        self.selection_label = QLabel("0 مورد انتخاب شده")
        self.selection_label.setStyleSheet(f"font-size: 12px; color: {Palette.TEXT_MUTED};")
        content_layout.addWidget(self.selection_label)

        self.label_grid = LabelGridWidget()
        self.label_grid.selection_changed.connect(self._update_selection_status)
        content_layout.addWidget(self.label_grid)
        layout.addWidget(self.content)

    def toggle(self) -> None:
        self.is_open = not self.is_open
        self.chevron.setText("▼" if self.is_open else "▶")
        self.content.setVisible(self.is_open)
        if self.is_open and not self.content_loaded:
            self.label_grid.set_labels(self.cartons)
            self._update_selection_status()
            self.content_loaded = True

    def _update_selection_status(self) -> None:
        selected_count = self.label_grid.selected_count()
        total_count = self.label_grid.total_count()
        self.selection_label.setText(f"{selected_count} از {total_count} لیبل انتخاب شده")

    def _print_selected(self) -> None:
        selected_labels = self.label_grid.selected_labels()
        if not selected_labels:
            QMessageBox.information(self, "چاپ لیبل", "ابتدا حداقل یک لیبل را انتخاب کنید.")
            return
        print_label_batch(selected_labels, self)


class Dashboard(QWidget):
    def __init__(self, api, socket_client: SocketClient | None = None):
        super().__init__()
        self.api = api
        self.socket_client = socket_client
        self.warehouse_name = "نامشخص"

        # Connect socket events if socket client is provided
        if self.socket_client:
            self.socket_client.scanout_done.connect(self._on_scanout_done)
            self.socket_client.checkin_completed.connect(self._on_checkin_completed)
            self.socket_client.inventory_updated.connect(self._on_inventory_updated)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(0)

        layout.addWidget(self._build_header())

        self.tabs = QTabWidget()
        self.tabs.setStyleSheet(tab_style())
        layout.addWidget(self.tabs)

        self.today_tab = QWidget()
        self.history_tab = QWidget()
        self.shipped_tab = QWidget()
        self.badges_tab = BadgesTab(api)
        self.tabs.addTab(self.today_tab, "ورودی‌های اخیر")
        self.tabs.addTab(self.shipped_tab, "تکمیل شده‌ها")
        self.tabs.addTab(self.history_tab, "تاریخچه تراکنش‌ها")
        self.tabs.addTab(self.badges_tab, "بیجک")

        self._setup_today_tab()
        self._setup_shipped_tab()
        self._setup_history_tab()

    def _build_header(self) -> QWidget:
        header = QWidget()
        header.setStyleSheet(header_bar_style())
        layout = QHBoxLayout(header)
        layout.setContentsMargins(24, 18, 24, 18)

        text_layout = QVBoxLayout()
        text_layout.setSpacing(2)
        self.title_label = QLabel("داشبورد انبار")
        self.title_label.setStyleSheet(f"font-size: 16px; font-weight: bold; color: {Palette.PRIMARY};")
        text_layout.addWidget(self.title_label)

        self.subtitle_label = QLabel("در حال بارگذاری اطلاعات...")
        self.subtitle_label.setStyleSheet(f"font-size: 12px; color: {Palette.TEXT_MUTED};")
        text_layout.addWidget(self.subtitle_label)

        layout.addLayout(text_layout)
        layout.addStretch()

        refresh_btn = QPushButton("بروزرسانی")
        refresh_btn.setStyleSheet(button_style("secondary"))
        refresh_btn.clicked.connect(self.load_data)
        layout.addWidget(refresh_btn)
        return header

    def _setup_today_tab(self) -> None:
        layout = QVBoxLayout(self.today_tab)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        toolbar = QHBoxLayout()
        self.today_summary_label = QLabel("آخرین برچسب‌های ثبت شده")
        self.today_summary_label.setStyleSheet(f"font-size: 13px; color: {Palette.TEXT_MUTED};")
        toolbar.addWidget(self.today_summary_label)
        toolbar.addStretch()

        refresh_btn = QPushButton("بارگذاری مجدد")
        refresh_btn.setStyleSheet(button_style("secondary"))
        refresh_btn.clicked.connect(self._load_today)
        toolbar.addWidget(refresh_btn)
        layout.addLayout(toolbar)

        self.today_scroll = QScrollArea()
        self.today_scroll.setWidgetResizable(True)
        self.today_scroll.setFrameShape(QFrame.Shape.NoFrame)

        self.today_container = QWidget()
        self.today_container_layout = QVBoxLayout(self.today_container)
        self.today_container_layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.today_container_layout.setSpacing(8)
        self.today_scroll.setWidget(self.today_container)
        layout.addWidget(self.today_scroll)

    def _setup_shipped_tab(self) -> None:
        layout = QVBoxLayout(self.shipped_tab)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        toolbar = QHBoxLayout()
        self.shipped_summary_label = QLabel("کارتن‌های تکمیل شده و ارسال شده")
        self.shipped_summary_label.setStyleSheet(f"font-size: 13px; color: {Palette.TEXT_MUTED};")
        toolbar.addWidget(self.shipped_summary_label)
        toolbar.addStretch()

        refresh_btn = QPushButton("بارگذاری مجدد")
        refresh_btn.setStyleSheet(button_style("secondary"))
        refresh_btn.clicked.connect(self._load_shipped)
        toolbar.addWidget(refresh_btn)
        layout.addLayout(toolbar)

        self.shipped_scroll = QScrollArea()
        self.shipped_scroll.setWidgetResizable(True)
        self.shipped_scroll.setFrameShape(QFrame.Shape.NoFrame)

        self.shipped_container = QWidget()
        self.shipped_container_layout = QVBoxLayout(self.shipped_container)
        self.shipped_container_layout.setAlignment(Qt.AlignmentFlag.AlignTop)
        self.shipped_container_layout.setSpacing(8)
        self.shipped_scroll.setWidget(self.shipped_container)
        layout.addWidget(self.shipped_scroll)

    def _setup_history_tab(self) -> None:
        layout = QVBoxLayout(self.history_tab)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        filter_row = QHBoxLayout()
        date_label = QLabel("تاریخ:")
        date_label.setStyleSheet(f"color: {Palette.TEXT_MUTED};")
        filter_row.addWidget(date_label)

        self.history_date = QDateEdit()
        self.history_date.setCalendarPopup(True)
        self.history_date.setDate(QDate.currentDate())
        self.history_date.setStyleSheet(
            f"""
            QDateEdit {{
                background: {Palette.SURFACE_ALT};
                border: 1px solid {Palette.BORDER};
                border-radius: 8px;
                padding: 8px 10px;
                color: {Palette.TEXT};
            }}
            """
        )
        filter_row.addWidget(self.history_date)

        search_btn = QPushButton("جستجو")
        search_btn.setStyleSheet(button_style())
        search_btn.clicked.connect(self._load_history)
        filter_row.addWidget(search_btn)

        refresh_btn = QPushButton("آخرین 50 تراکنش")
        refresh_btn.setStyleSheet(button_style("secondary"))
        refresh_btn.clicked.connect(self._load_history_without_filter)
        filter_row.addWidget(refresh_btn)
        filter_row.addStretch()
        layout.addLayout(filter_row)

        self.history_status_label = QLabel("")
        self.history_status_label.setStyleSheet(f"font-size: 12px; color: {Palette.TEXT_MUTED};")
        layout.addWidget(self.history_status_label)

        self.history_table = QTableWidget()
        self.history_table.setColumnCount(5)
        self.history_table.setHorizontalHeaderLabels(["نوع", "محصول", "تعداد", "توسط", "تاریخ"])
        self.history_table.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        self.history_table.verticalHeader().setVisible(False)
        self.history_table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self.history_table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self.history_table.setAlternatingRowColors(True)
        self.history_table.setStyleSheet(table_style())
        layout.addWidget(self.history_table)

    def load_data(self) -> None:
        self._load_warehouse()
        self._load_today()
        self._load_shipped()
        self._load_history()
        self.badges_tab.load()

    def _load_warehouse(self) -> None:
        try:
            warehouse = self.api.get_my_warehouse()
            self.warehouse_name = warehouse.get("name") or "انبار نامشخص"
            keeper_name = warehouse.get("keeperName") or "انباردار"
            self.title_label.setText(f"داشبورد {self.warehouse_name}")
            self.subtitle_label.setText(f"کاربر فعال: {keeper_name}")
        except Exception as exc:
            self.title_label.setText("داشبورد انبار")
            self.subtitle_label.setText(f"عدم دریافت اطلاعات انبار: {exc}")

    def _clear_layout(self, layout: QVBoxLayout) -> None:
        while layout.count():
            child = layout.takeAt(0)
            if child.widget():
                child.widget().deleteLater()

    def _build_state_label(self, text: str) -> QLabel:
        label = QLabel(text)
        label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        label.setStyleSheet(f"color: {Palette.TEXT_MUTED}; font-size: 15px; padding: 40px;")
        return label

    def _load_today(self) -> None:
        self._clear_layout(self.today_container_layout)
        try:
            cartons = self.api.get_cartons()
            groups = group_cartons_by_label(cartons)
            if not groups:
                self.today_summary_label.setText("هیچ کارتنی برای امروز ثبت نشده است.")
                self.today_container_layout.addWidget(self._build_state_label("هیچ ورودی جدیدی ثبت نشده است."))
                return

            total_cartons = sum(len(items) for items in groups.values())
            self.today_summary_label.setText(
                f"{len(groups)} گروه کالا | {total_cartons} برچسب آماده چاپ"
            )
            for (title, subtitle), items in groups.items():
                self.today_container_layout.addWidget(AccordionItem(title, subtitle, items))
            self.today_container_layout.addStretch()
        except Exception as exc:
            self.today_summary_label.setText("خطا در دریافت اطلاعات")
            self.today_container_layout.addWidget(self._build_state_label(str(exc)))

    def _load_shipped(self) -> None:
        self._clear_layout(self.shipped_container_layout)
        try:
            cartons = self.api.get_shipped_cartons()
            groups = group_cartons_by_label(cartons)
            if not groups:
                self.shipped_summary_label.setText("هیچ کارتن ارسال شده‌ای موجود نیست.")
                self.shipped_container_layout.addWidget(self._build_state_label("هیچ کارتن ارسالی ثبت نشده است."))
                return

            total_cartons = sum(len(items) for items in groups.values())
            self.shipped_summary_label.setText(
                f"{len(groups)} گروه کالا | {total_cartons} کارتن ارسال شده"
            )
            for (title, subtitle), items in groups.items():
                self.shipped_container_layout.addWidget(AccordionItem(title, subtitle, items))
            self.shipped_container_layout.addStretch()
        except Exception as exc:
            self.shipped_summary_label.setText("خطا در دریافت اطلاعات")
            self.shipped_container_layout.addWidget(self._build_state_label(str(exc)))

    def _load_history_without_filter(self) -> None:
        self._populate_history(None)

    def _load_history(self) -> None:
        selected_date = self.history_date.date().toString("yyyy-MM-dd")
        self._populate_history(selected_date)

    def _populate_history(self, date_filter: str | None) -> None:
        try:
            transactions = self.api.get_transactions(date_filter)
            self.history_table.setRowCount(len(transactions))
            for row_index, transaction in enumerate(transactions):
                values = [
                    "ورود" if transaction.get("type") == "IN" else "خروج",
                    transaction.get("productName", "—"),
                    str(transaction.get("quantity", 0)),
                    transaction.get("userName", "—"),
                    str(transaction.get("createdAt", ""))[:10] or "—",
                ]
                for column_index, value in enumerate(values):
                    item = QTableWidgetItem(value)
                    item.setTextAlignment(Qt.AlignmentFlag.AlignCenter)
                    self.history_table.setItem(row_index, column_index, item)

            if date_filter:
                self.history_status_label.setText(
                    f"{len(transactions)} تراکنش برای تاریخ {date_filter} نمایش داده شد."
                )
            else:
                self.history_status_label.setText(
                    f"{len(transactions)} تراکنش اخیر نمایش داده شد."
                )
        except Exception as exc:
            self.history_table.setRowCount(0)
            self.history_status_label.setText(f"خطا در بارگذاری تاریخچه: {exc}")

    def _on_scanout_done(self, data: dict) -> None:
        """Handle real-time scanout done event."""
        print(f"Real-time scanout detected: {data}")
        # Refresh inventory data when scanout happens
        self._load_today()
        self._load_shipped()

    def _on_checkin_completed(self, data: dict) -> None:
        """Handle real-time checkin completed event."""
        print(f"Real-time checkin detected: {data}")
        # Refresh today's entries when new checkin happens
        self._load_today()

    def _on_inventory_updated(self) -> None:
        """Handle general inventory update event."""
        print("Inventory updated via real-time event")
        # Optionally refresh all tabs
        # self.load_data()
