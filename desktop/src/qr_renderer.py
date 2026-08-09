from __future__ import annotations

from dataclasses import dataclass
from io import BytesIO
from typing import Any

import qrcode
from PIL import Image
from PyQt6.QtCore import QMarginsF, QSizeF, Qt
from PyQt6.QtGui import QColor, QFont, QImage, QPageLayout, QPageSize, QPainter, QPixmap
from PyQt6.QtPrintSupport import QPrintDialog, QPrinter
from PyQt6.QtWidgets import (
    QFrame,
    QGraphicsDropShadowEffect,
    QHBoxLayout,
    QLabel,
    QSizePolicy,
    QVBoxLayout,
    QWidget,
)


@dataclass(frozen=True)
class LabelConfig:
    width_mm: float = 58
    height_mm: float = 77
    width_px: int = 200
    height_px: int = 300
    font_header: int = 8
    font_row: int = 7
    font_barcode: int = 12
    font_tracking: int = 6
    font_main: str = "Segoe UI"
    font_barcode_family: str = "Courier New"
    color_bg: str = "#ffffff"
    color_text: str = "#000000"
    color_muted: str = "#4a4a4a"
    color_border: str = "#e0e0e0"
    color_divider: str = "#dcdcdc"
    padding: int = 8
    qr_size: int = 95


class InfoRow(QWidget):
    def __init__(self, label_text: str, config: LabelConfig):
        super().__init__()
        self.setFixedHeight(18)
        layout = QHBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(4)

        label = QLabel(f"▸ {label_text}")
        label.setFont(QFont(config.font_main, config.font_row))
        label.setStyleSheet(f"color: {config.color_text};")
        label.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)

        self.value_label = QLabel("—")
        value_font = QFont(config.font_main, config.font_row)
        value_font.setBold(True)
        self.value_label.setFont(value_font)
        self.value_label.setAlignment(Qt.AlignmentFlag.AlignRight | Qt.AlignmentFlag.AlignVCenter)
        self.value_label.setStyleSheet(f"color: {config.color_text};")
        self.value_label.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)

        layout.addWidget(label)
        layout.addWidget(self.value_label)


def configure_printer(printer: QPrinter, config: LabelConfig) -> None:
    page_size = QPageSize(
        QSizeF(config.width_mm, config.height_mm),
        QPageSize.Unit.Millimeter,
        "WarehouseLabel",
    )
    page_layout = QPageLayout(
        page_size,
        QPageLayout.Orientation.Portrait,
        QMarginsF(0, 0, 0, 0),
    )
    printer.setPageLayout(page_layout)
    printer.setResolution(300)


def print_label_batch(label_widgets: list["QRLabelWidget"], parent: QWidget | None = None) -> bool:
    if not label_widgets:
        return False

    printer = QPrinter(QPrinter.PrinterMode.HighResolution)
    configure_printer(printer, label_widgets[0].config)

    dialog = QPrintDialog(printer, parent)
    if dialog.exec() != QPrintDialog.DialogCode.Accepted:
        return False

    painter = QPainter(printer)
    for index, label_widget in enumerate(label_widgets):
        if index > 0:
            printer.newPage()
        label_widget.render(painter)
    painter.end()
    return True


class QRLabelWidget(QFrame):
    def __init__(self, data: dict[str, Any], config: LabelConfig | None = None, parent: QWidget | None = None):
        super().__init__(parent)
        self.config = config or LabelConfig()
        self._data: dict[str, Any] = {}

        self.setObjectName("QRLabelWidget")
        self.setFixedSize(self.config.width_px, self.config.height_px)
        self.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Fixed)
        self.setStyleSheet(
            f"""
            QFrame#QRLabelWidget {{
                background: {self.config.color_bg};
                border: 1px solid {self.config.color_border};
                border-radius: 10px;
            }}
            QFrame#QRLabelWidget * {{
                background: transparent;
            }}
            """
        )

        shadow = QGraphicsDropShadowEffect(self)
        shadow.setBlurRadius(10)
        shadow.setOffset(0, 2)
        shadow.setColor(QColor(0, 0, 0, 30))
        self.setGraphicsEffect(shadow)

        self._layout = QVBoxLayout(self)
        self._layout.setSpacing(2)
        self._layout.setContentsMargins(
            self.config.padding,
            self.config.padding,
            self.config.padding,
            self.config.padding,
        )

        self._build_ui()
        self.set_data(data)

    def _build_ui(self) -> None:
        header_font = QFont(self.config.font_main, self.config.font_header)
        header_font.setBold(True)

        self.header_label = QLabel("MA WAREHOUSE")
        self.header_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.header_label.setFont(header_font)
        self.header_label.setStyleSheet(
            f"color: {self.config.color_text}; border-bottom: 2px solid {self.config.color_text}; padding-bottom: 1px;"
        )
        self.header_label.setFixedHeight(18)
        self._layout.addWidget(self.header_label)

        self.qr_label = QLabel()
        self.qr_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.qr_label.setFixedSize(self.config.qr_size, self.config.qr_size)
        self._layout.addWidget(self.qr_label, alignment=Qt.AlignmentFlag.AlignCenter)

        self._layout.addWidget(self._make_divider())

        self.model_row = InfoRow("مدل", self.config)
        self.qty_row = InfoRow("تعداد", self.config)
        self.serial_row = InfoRow("سریال", self.config)
        self.date_row = InfoRow("تاریخ", self.config)
        for row in [self.model_row, self.qty_row, self.serial_row, self.date_row]:
            self._layout.addWidget(row)

        self._layout.addWidget(self._make_divider())

        barcode_font = QFont(self.config.font_barcode_family, self.config.font_barcode)
        barcode_font.setBold(True)
        self.barcode_label = QLabel()
        self.barcode_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.barcode_label.setFont(barcode_font)
        self.barcode_label.setStyleSheet(f"color: {self.config.color_text}; letter-spacing: 2px;")
        self.barcode_label.setFixedHeight(22)
        self._layout.addWidget(self.barcode_label)

        self.tracking_label = QLabel()
        self.tracking_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.tracking_label.setFont(QFont(self.config.font_main, self.config.font_tracking))
        self.tracking_label.setStyleSheet(f"color: {self.config.color_muted}; letter-spacing: 1px;")
        self.tracking_label.setFixedHeight(14)
        self._layout.addWidget(self.tracking_label)

    def _make_divider(self) -> QFrame:
        divider = QFrame()
        divider.setFrameShape(QFrame.Shape.HLine)
        divider.setStyleSheet(
            f"border: 0.5px dashed {self.config.color_divider}; margin: 2px 0;"
        )
        divider.setFixedHeight(5)
        return divider

    @staticmethod
    def _generate_qr_pixmap(data: str, size: int) -> QPixmap:
        qr = qrcode.QRCode(box_size=10, border=2)
        qr.add_data(data or " ")
        qr.make(fit=True)
        image = qr.make_image(fill_color="black", back_color="white").convert("RGBA")
        image = image.resize((size, size), Image.Resampling.LANCZOS)
        buffer = BytesIO()
        image.save(buffer, format="PNG")
        qimage = QImage.fromData(buffer.getvalue())
        return QPixmap.fromImage(qimage)

    def set_data(self, data: dict[str, Any]) -> None:
        self._data = data

        product = data.get("product")
        product_name = (
            product.get("name", "") if isinstance(product, dict) else str(data.get("productName") or "")
        )

        model = data.get("model")
        if isinstance(model, dict):
            model_name = model.get("name", "") or ""
            units = model.get("unitsPerBox")
        else:
            model_name = str(data.get("modelName") or "")
            units = data.get("capacityPerBox")

        model_display = model_name or product_name or "—"
        is_individual = bool(data.get("isIndividual", data.get("isIndividualUnit", False)))
        qty_text = "۱ عدد (تکی)" if is_individual else f"{units if units is not None else '?'} عدد / کارتن"

        # سریال واقعی کارتن — محتوای QR جدید (v2) نیز همان سریال است
        serial = str(data.get("serialNumber") or "")
        if not serial:
            raw_id = str(data.get("qrUuid") or data.get("id") or "")
            serial = raw_id[:8].upper().replace("-", "")
        barcode_value = serial[:16] or "000000"
        tracking_value = serial or "MA-XXXXXXXX"
        date_value = str(data.get("createdAt", ""))[:10] or "—"
        qr_payload = str(data.get("qrPayload") or tracking_value)

        self.model_row.value_label.setText(model_display)
        self.qty_row.value_label.setText(qty_text)
        self.serial_row.value_label.setText(serial or "—")
        self.date_row.value_label.setText(date_value)
        self.barcode_label.setText(f"*{barcode_value}*")
        self.tracking_label.setText(tracking_value)

        qr_pixmap = self._generate_qr_pixmap(qr_payload, self.config.qr_size)
        self.qr_label.setPixmap(
            qr_pixmap.scaled(
                self.config.qr_size,
                self.config.qr_size,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.SmoothTransformation,
            )
        )

    def data(self) -> dict[str, Any]:
        return self._data

    def print_label(self, printer: QPrinter | None = None) -> bool:
        if printer is None:
            printer = QPrinter(QPrinter.PrinterMode.HighResolution)
            configure_printer(printer, self.config)
            dialog = QPrintDialog(printer, self)
            if dialog.exec() != QPrintDialog.DialogCode.Accepted:
                return False
        else:
            configure_printer(printer, self.config)

        painter = QPainter(printer)
        self.render(painter)
        painter.end()
        return True

    def export_to_pixmap(self, scale: float = 2.0) -> QPixmap:
        width = int(self.width() * scale)
        height = int(self.height() * scale)
        pixmap = QPixmap(width, height)
        pixmap.fill(Qt.GlobalColor.white)

        painter = QPainter(pixmap)
        painter.scale(scale, scale)
        self.render(painter)
        painter.end()
        return pixmap
