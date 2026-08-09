from __future__ import annotations


class Palette:
    APP_BG = "#0f1114"
    SURFACE = "#16191e"
    SURFACE_ALT = "#1a1d22"
    SURFACE_HOVER = "#22262d"
    BORDER = "#2a2d33"
    TEXT = "#f0f2f5"
    TEXT_MUTED = "#8b9099"
    PRIMARY = "#4ade80"
    PRIMARY_HOVER = "#6ee7a7"
    PRIMARY_PRESSED = "#22c55e"
    DANGER = "#ef4444"
    DANGER_BG = "#2a1719"
    DANGER_HOVER = "#3a1f22"
    DISABLED_BG = "#444c56"
    DISABLED_TEXT = "#9aa0a6"
    WHITE = "#ffffff"
    DIVIDER = "#dcdcdc"


def app_stylesheet() -> str:
    return f"""
        QMainWindow, QWidget {{
            background: {Palette.APP_BG};
            color: {Palette.TEXT};
            font-family: Tahoma;
        }}
        QToolTip {{
            background: {Palette.SURFACE_ALT};
            color: {Palette.TEXT};
            border: 1px solid {Palette.BORDER};
            padding: 6px;
        }}
    """


def card_style() -> str:
    return f"""
        background-color: {Palette.SURFACE_ALT};
        border-radius: 20px;
        border: 1px solid {Palette.BORDER};
    """


def input_style() -> str:
    return f"""
        QLineEdit {{
            background-color: {Palette.APP_BG};
            border: 1.5px solid {Palette.BORDER};
            border-radius: 10px;
            padding: 12px 16px;
            font-size: 14px;
            color: {Palette.TEXT};
            font-family: Tahoma;
        }}
        QLineEdit:focus {{
            border-color: {Palette.PRIMARY};
        }}
    """


def button_style(variant: str = "primary") -> str:
    if variant == "secondary":
        return f"""
            QPushButton {{
                background-color: {Palette.SURFACE_HOVER};
                color: {Palette.TEXT};
                border: 1px solid {Palette.BORDER};
                border-radius: 10px;
                font-size: 13px;
                font-weight: bold;
                padding: 10px 16px;
            }}
            QPushButton:hover {{ background-color: {Palette.BORDER}; }}
            QPushButton:pressed {{ background-color: {Palette.SURFACE}; }}
            QPushButton:disabled {{
                background-color: {Palette.DISABLED_BG};
                color: {Palette.DISABLED_TEXT};
            }}
        """

    if variant == "danger":
        return f"""
            QPushButton {{
                background-color: {Palette.DANGER_BG};
                color: {Palette.DANGER};
                border: 1px solid {Palette.BORDER};
                border-radius: 10px;
                font-size: 13px;
                font-weight: bold;
                padding: 10px 16px;
            }}
            QPushButton:hover {{ background-color: {Palette.DANGER_HOVER}; }}
            QPushButton:pressed {{ background-color: {Palette.BORDER}; }}
        """

    return f"""
        QPushButton {{
            background-color: {Palette.PRIMARY};
            color: #000000;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: bold;
            padding: 10px 16px;
        }}
        QPushButton:hover {{ background-color: {Palette.PRIMARY_HOVER}; }}
        QPushButton:pressed {{ background-color: {Palette.PRIMARY_PRESSED}; }}
        QPushButton:disabled {{
            background-color: {Palette.DISABLED_BG};
            color: {Palette.DISABLED_TEXT};
        }}
    """


def sidebar_style() -> str:
    return f"""
        background: {Palette.SURFACE};
        border-left: 1px solid {Palette.BORDER};
    """


def sidebar_list_style() -> str:
    return f"""
        QListWidget {{
            background: transparent;
            border: none;
            outline: none;
        }}
        QListWidget::item {{
            padding: 10px 12px;
            margin: 2px 0;
            border-radius: 8px;
            color: {Palette.TEXT_MUTED};
            font-size: 13px;
        }}
        QListWidget::item:selected {{
            background: {Palette.PRIMARY};
            color: #000000;
            font-weight: bold;
        }}
    """


def header_bar_style() -> str:
    return f"""
        background: {Palette.SURFACE_ALT};
        border-bottom: 1px solid {Palette.BORDER};
    """


def tab_style() -> str:
    return f"""
        QTabWidget::pane {{
            border: none;
        }}
        QTabBar::tab {{
            background: {Palette.SURFACE_ALT};
            color: {Palette.TEXT_MUTED};
            padding: 10px 20px;
            font-size: 13px;
            font-weight: bold;
            border-bottom: 2px solid transparent;
        }}
        QTabBar::tab:selected {{
            color: {Palette.PRIMARY};
            border-bottom-color: {Palette.PRIMARY};
        }}
    """


def table_style() -> str:
    return f"""
        QTableWidget {{
            background: {Palette.SURFACE_ALT};
            border: 1px solid {Palette.BORDER};
            gridline-color: {Palette.BORDER};
            border-radius: 12px;
        }}
        QHeaderView::section {{
            background: {Palette.SURFACE_HOVER};
            color: {Palette.TEXT_MUTED};
            padding: 8px;
            border: none;
            border-bottom: 1px solid {Palette.BORDER};
        }}
        QTableWidget::item {{
            padding: 8px;
            color: {Palette.TEXT};
        }}
    """
