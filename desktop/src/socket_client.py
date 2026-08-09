from __future__ import annotations

import socketio
from PyQt6.QtCore import QObject, pyqtSignal


class SocketClient(QObject):
    """Real-time Socket.IO client for warehouse updates."""
    
    # Signals for real-time events
    scanout_done = pyqtSignal(dict)
    checkin_completed = pyqtSignal(dict)
    inventory_updated = pyqtSignal()
    
    def __init__(self, base_url: str):
        super().__init__()
        self.base_url = base_url.rstrip("/")
        self.sio = socketio.Client(logger=False, engineio_logger=False)
        self.token: str | None = None
        self._setup_handlers()
    
    def _setup_handlers(self) -> None:
        """Setup Socket.IO event handlers."""
        
        @self.sio.event
        def connect():
            print("Socket.IO connected")
            if self.token:
                self.sio.emit("authenticate", {"token": self.token})
        
        @self.sio.event
        def disconnect():
            print("Socket.IO disconnected")
        
        @self.sio.event
        def connect_error(data):
            print(f"Socket.IO connection error: {data}")
        
        # Listen for scanout:done event
        @self.sio.on("scanout:done")
        def on_scanout_done(data):
            print(f"Scanout done: {data}")
            self.scanout_done.emit(data)
            self.inventory_updated.emit()
        
        # Listen for checkin:completed event
        @self.sio.on("checkin:completed")
        def on_checkin_completed(data):
            print(f"Checkin completed: {data}")
            self.checkin_completed.emit(data)
            self.inventory_updated.emit()
    
    def connect(self, token: str | None = None) -> None:
        """Connect to Socket.IO server with optional authentication token."""
        if token:
            self.token = token
        
        try:
            if not self.sio.connected:
                self.sio.connect(
                    self.base_url,
                    auth={"token": self.token} if self.token else None,
                    transports=["websocket", "polling"],
                )
        except Exception as e:
            print(f"Failed to connect to Socket.IO: {e}")
    
    def disconnect(self) -> None:
        """Disconnect from Socket.IO server."""
        try:
            if self.sio.connected:
                self.sio.disconnect()
        except Exception as e:
            print(f"Failed to disconnect from Socket.IO: {e}")
    
    def is_connected(self) -> bool:
        """Check if Socket.IO is connected."""
        return self.sio.connected
