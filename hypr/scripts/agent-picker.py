#!/usr/bin/env python3
import sys, os, json, subprocess
from PyQt6 import QtCore, QtGui, QtWidgets, QtSvg

# --- 1. Workspace & Dolphin Directory Detection ---
def get_dolphin_path_from_pid(pid):
    if not pid or pid <= 0:
        return None
    try:
        import dbus
        bus = dbus.SessionBus()
        service = f"org.kde.dolphin-{pid}"
        obj = bus.get_object(service, "/dolphin/Dolphin_1")
        props = dbus.Interface(obj, "org.freedesktop.DBus.Properties")
        title = str(props.Get("org.qtproject.Qt.QWidget", "windowTitle")).strip()
        expanded = os.path.expanduser(title)
        if os.path.isdir(expanded):
            return expanded
    except Exception:
        pass
    return None

def parse_dolphin_title(title):
    if not title:
        return None
    for suffix in [" — Dolphin", " – Dolphin", " - Dolphin", " — Manajer Berkas"]:
        if suffix in title:
            title = title.split(suffix)[0]
    title = title.strip()
    expanded = os.path.expanduser(title)
    if os.path.isdir(expanded):
        return expanded
    home = os.path.expanduser("~")
    for sub in ["Projects", "Documents", "Downloads", "infra", ""]:
        cand = os.path.join(home, sub, title) if sub else os.path.join(home, title)
        if os.path.isdir(cand):
            return cand
    return None

def get_proc_cwd(pid):
    if not pid or pid <= 0:
        return None
    try:
        children = subprocess.check_output(["pgrep", "-P", str(pid)], text=True).strip().split()
        target_pid = children[-1] if children else str(pid)
        cwd = os.path.realpath(f"/proc/{target_pid}/cwd")
        if os.path.isdir(cwd) and cwd != "/":
            return cwd
    except Exception:
        pass
    try:
        cwd = os.path.realpath(f"/proc/{pid}/cwd")
        if os.path.isdir(cwd) and cwd != "/":
            return cwd
    except Exception:
        pass
    return None

def get_workspace_dir():
    try:
        active_ws = json.loads(subprocess.check_output(["hyprctl", "activeworkspace", "-j"], text=True))
        ws_id = active_ws.get("id")
        clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
        active_win = json.loads(subprocess.check_output(["hyprctl", "activewindow", "-j"], text=True))
    except Exception:
        return os.path.expanduser("~")

    # 1. Focused window is Dolphin
    if "dolphin" in active_win.get("class", "").lower():
        p = get_dolphin_path_from_pid(active_win.get("pid")) or parse_dolphin_title(active_win.get("title", ""))
        if p and os.path.isdir(p):
            return p

    # 2. Check Dolphin in active workspace
    ws_clients = [c for c in clients if c.get("workspace", {}).get("id") == ws_id]
    for c in ws_clients:
        if "dolphin" in c.get("class", "").lower():
            p = get_dolphin_path_from_pid(c.get("pid")) or parse_dolphin_title(c.get("title", ""))
            if p and os.path.isdir(p):
                return p

    # 3. Focused window is terminal / editor with cwd
    p = get_proc_cwd(active_win.get("pid"))
    if p and os.path.isdir(p):
        return p

    # 4. Any terminal in active workspace
    for c in ws_clients:
        p = get_proc_cwd(c.get("pid"))
        if p and os.path.isdir(p):
            return p

    # 5. Check any Dolphin anywhere on the desktop
    for c in clients:
        if "dolphin" in c.get("class", "").lower():
            p = get_dolphin_path_from_pid(c.get("pid")) or parse_dolphin_title(c.get("title", ""))
            if p and os.path.isdir(p):
                return p

    return os.path.expanduser("~")

# --- 2. SVGs & Icon Compositor ---
GEMINI_PATH = "M11.04 19.32Q12 21.51 12 24q0-2.49.93-4.68.96-2.19 2.58-3.81t3.81-2.55Q21.51 12 24 12q-2.49 0-4.68-.93a12.3 12.3 0 0 1-3.81-2.58 12.3 12.3 0 0 1-2.58-3.81Q12 2.49 12 0q0 2.49-.96 4.68-.93 2.19-2.55 3.81a12.3 12.3 0 0 1-3.81 2.58Q2.49 12 0 12q2.49 0 4.68.96 2.19.93 3.81 2.55t2.55 3.81z"
OPENAI_PATH = "M22.2819 9.8211a5.9847 5.9847 0 0 0-.5157-4.9108 6.0462 6.0462 0 0 0-6.5098-2.9A6.0651 6.0651 0 0 0 4.9807 4.1818a5.9847 5.9847 0 0 0-3.9977 2.9 6.0462 6.0462 0 0 0 .7427 7.0966 5.98 5.98 0 0 0 .511 4.9107 6.051 6.051 0 0 0 6.5146 2.9001A5.9847 5.9847 0 0 0 13.2599 24a6.0557 6.0557 0 0 0 5.7718-4.2058 5.9894 5.9894 0 0 0 3.9977-2.9001 6.0557 6.0557 0 0 0-.7475-7.0729zm-9.022 12.6081a4.4755 4.4755 0 0 1-2.8764-1.0408l.1419-.0804 4.7783-2.7582a.7948.7948 0 0 0 .3927-.6813v-6.7369l2.02 1.1686a.071.071 0 0 1 .038.052v5.5826a4.504 4.504 0 0 1-4.4945 4.4944zm-9.6607-4.1254a4.4708 4.4708 0 0 1-.5346-3.0137l.142.0852 4.783 2.7582a.7712.7712 0 0 0 .7806 0l5.8428-3.3685v2.3324a.0804.0804 0 0 1-.0332.0615L9.74 19.9502a4.4992 4.4992 0 0 1-6.1408-1.6464zM2.3408 7.8956a4.485 4.485 0 0 1 2.3655-1.9728V11.6a.7664.7664 0 0 0 .3879.6765l5.8144 3.3543-2.0201 1.1685a.0757.0757 0 0 1-.071 0l-4.8303-2.7865A4.504 4.504 0 0 1 2.3408 7.872zm16.5963 3.8558L13.1038 8.364 15.1192 7.2a.0757.0757 0 0 1 .071 0l4.8303 2.7913a4.4944 4.4944 0 0 1-.6765 8.1042v-5.6772a.7904.7904 0 0 0-.407-.667zm2.0107-3.0231l-.142-.0852-4.7735-2.7818a.7759.7759 0 0 0-.7854 0L9.409 9.2297V6.8974a.0662.0662 0 0 1 .0284-.0615l4.8303-2.7866a4.4992 4.4992 0 0 1 6.6802 4.66zM8.3065 12.863l-2.02-1.1638a.0804.0804 0 0 1-.038-.0567V6.0742a4.4992 4.4992 0 0 1 7.3757-3.4537l-.142.0805L8.704 5.459a.7948.7948 0 0 0-.3927.6813zm1.0976-2.3654l2.602-1.4998 2.6069 1.4998v2.9994l-2.5974 1.4997-2.6067-1.4997Z"

def create_terminal_badge_icon(badge_type):
    pix = QtGui.QPixmap(48, 48)
    pix.fill(QtCore.Qt.GlobalColor.transparent)
    p = QtGui.QPainter(pix)
    p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing)
    p.setRenderHint(QtGui.QPainter.RenderHint.SmoothPixmapTransform)

    p.setBrush(QtGui.QBrush(QtGui.QColor(22, 23, 34)))
    p.setPen(QtGui.QPen(QtGui.QColor(52, 56, 78), 1.5))
    p.drawRoundedRect(QtCore.QRectF(2, 2, 44, 44), 9, 9)

    p.setPen(QtGui.QPen(QtGui.QColor(36, 40, 60), 1))
    p.drawLine(QtCore.QPointF(3, 13), QtCore.QPointF(45, 13))

    p.setPen(QtCore.Qt.PenStyle.NoPen)
    p.setBrush(QtGui.QBrush(QtGui.QColor(237, 135, 150)))
    p.drawEllipse(QtCore.QPointF(7, 8), 1.6, 1.6)
    p.setBrush(QtGui.QBrush(QtGui.QColor(238, 212, 159)))
    p.drawEllipse(QtCore.QPointF(12, 8), 1.6, 1.6)
    p.setBrush(QtGui.QBrush(QtGui.QColor(166, 218, 149)))
    p.drawEllipse(QtCore.QPointF(17, 8), 1.6, 1.6)

    font = QtGui.QFont("JetBrains Mono", 10, QtGui.QFont.Weight.Bold)
    p.setFont(font)
    p.setPen(QtGui.QPen(QtGui.QColor(138, 173, 244)))
    p.drawText(QtCore.QPointF(7, 26), ">")
    p.setPen(QtGui.QPen(QtGui.QColor(202, 211, 245)))
    p.drawText(QtCore.QPointF(16, 26), "_")

    badge_rect = QtCore.QRectF(25, 25, 21, 21)
    p.setBrush(QtGui.QBrush(QtGui.QColor(16, 17, 26)))
    p.setPen(QtGui.QPen(QtGui.QColor(16, 17, 26), 2.5))
    p.drawEllipse(badge_rect)

    if badge_type == "claude":
        claude_path = "/usr/share/icons/hicolor/128x128/apps/claude-desktop.png"
        if os.path.exists(claude_path):
            claude_img = QtGui.QPixmap(claude_path)
            clip = QtGui.QPainterPath()
            clip.addEllipse(badge_rect)
            p.setClipPath(clip)
            p.drawPixmap(badge_rect.toRect(), claude_img.scaled(21, 21, QtCore.Qt.AspectRatioMode.KeepAspectRatio, QtCore.Qt.TransformationMode.SmoothTransformation))
            p.setClipping(False)

    elif badge_type == "kiro":
        kiro_path = "/home/rayin/.local/opt/kiro-ide/resources/app/resources/linux/code.png"
        if os.path.exists(kiro_path):
            kiro_img = QtGui.QPixmap(kiro_path)
            clip = QtGui.QPainterPath()
            clip.addEllipse(badge_rect)
            p.setClipPath(clip)
            p.drawPixmap(badge_rect.toRect(), kiro_img.scaled(21, 21, QtCore.Qt.AspectRatioMode.KeepAspectRatio, QtCore.Qt.TransformationMode.SmoothTransformation))
            p.setClipping(False)

    elif badge_type == "gemini":
        p.setBrush(QtGui.QBrush(QtGui.QColor(28, 22, 44)))
        p.setPen(QtGui.QPen(QtGui.QColor(142, 117, 178), 1))
        p.drawEllipse(badge_rect)

        svg_xml = f"""<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#4e82ee"/>
              <stop offset="50%" stop-color="#b567d8"/>
              <stop offset="100%" stop-color="#eb6383"/>
            </linearGradient>
          </defs>
          <path fill="url(#g)" d="{GEMINI_PATH}"/>
        </svg>"""
        renderer = QtSvg.QSvgRenderer(QtCore.QByteArray(svg_xml.encode("utf-8")))
        renderer.render(p, QtCore.QRectF(27.5, 27.5, 16, 16))

    elif badge_type == "chatgpt":
        p.setBrush(QtGui.QBrush(QtGui.QColor(16, 32, 26)))
        p.setPen(QtGui.QPen(QtGui.QColor(16, 185, 129), 1))
        p.drawEllipse(badge_rect)

        svg_xml = f"""<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path fill="#10a37f" d="{OPENAI_PATH}"/>
        </svg>"""
        renderer = QtSvg.QSvgRenderer(QtCore.QByteArray(svg_xml.encode("utf-8")))
        renderer.render(p, QtCore.QRectF(27.5, 27.5, 16, 16))

    elif badge_type == "opencode":
        p.setBrush(QtGui.QBrush(QtGui.QColor(18, 28, 44)))
        p.setPen(QtGui.QPen(QtGui.QColor(56, 189, 248), 1))
        p.drawEllipse(badge_rect)

        svg_xml = """<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M13 2L4 14h7v8l9-12h-7z" fill="#38bdf8"/>
        </svg>"""
        renderer = QtSvg.QSvgRenderer(QtCore.QByteArray(svg_xml.encode("utf-8")))
        renderer.render(p, QtCore.QRectF(28.5, 28.5, 14, 14))

    p.end()
    return pix

def load_regular_icon(path):
    pix = QtGui.QPixmap(48, 48)
    pix.fill(QtCore.Qt.GlobalColor.transparent)
    p = QtGui.QPainter(pix)
    p.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing)
    p.setRenderHint(QtGui.QPainter.RenderHint.SmoothPixmapTransform)

    if os.path.exists(path):
        if path.endswith(".svg"):
            renderer = QtSvg.QSvgRenderer(path)
            renderer.render(p)
        else:
            orig = QtGui.QPixmap(path)
            p.drawPixmap(0, 0, 48, 48, orig.scaled(48, 48, QtCore.Qt.AspectRatioMode.KeepAspectRatio, QtCore.Qt.TransformationMode.SmoothTransformation))
    p.end()
    return pix

# --- 3. App Definitions ---
# Terminal apps do not use -D flag so they never fail on paths containing colons (e.g. RE:type-garden).
# Instead, the working directory is passed natively via cwd to subprocess / systemd --same-dir.
APP_DEFS = [
    {
        "id": "opencode",
        "title": "OpenCode",
        "icon_loader": lambda: create_terminal_badge_icon("opencode"),
        "get_cmd": lambda d: ["foot", "-e", "/home/rayin/.opencode/bin/opencode"],
    },
    {
        "id": "claude-code",
        "title": "Claude Code",
        "icon_loader": lambda: create_terminal_badge_icon("claude"),
        "get_cmd": lambda d: ["foot", "-e", "fish", "-c", "claude"],
    },
    {
        "id": "claude-desktop",
        "title": "Claude Desktop",
        "icon_loader": lambda: load_regular_icon("/usr/share/icons/hicolor/128x128/apps/claude-desktop.png"),
        "get_cmd": lambda d: ["claude-desktop"],
    },
    {
        "id": "kiro-cli",
        "title": "Kiro CLI",
        "icon_loader": lambda: create_terminal_badge_icon("kiro"),
        "get_cmd": lambda d: ["foot", "-e", "/home/rayin/.local/bin/kiro-cli"],
    },
    {
        "id": "kiro-desktop",
        "title": "Kiro Desktop",
        "icon_loader": lambda: load_regular_icon("/home/rayin/.local/opt/kiro-ide/resources/app/resources/linux/code.png"),
        "get_cmd": lambda d: ["/home/rayin/.local/bin/kiro", d],
    },
    {
        "id": "antigravity",
        "title": "Antigravity",
        "icon_loader": lambda: create_terminal_badge_icon("gemini"),
        "get_cmd": lambda d: ["foot", "-e", "/home/rayin/.local/bin/agy"],
    },
    {
        "id": "codex",
        "title": "Codex",
        "icon_loader": lambda: create_terminal_badge_icon("chatgpt"),
        "get_cmd": lambda d: ["foot", "-e", "/home/rayin/.local/bin/codex"],
    },
    {
        "id": "cursor",
        "title": "Cursor",
        "icon_loader": lambda: load_regular_icon("/usr/share/icons/Papirus/64x64/apps/cursor.svg"),
        "get_cmd": lambda d: ["/usr/local/bin/cursor", d],
    },
    {
        "id": "vscode",
        "title": "VS Code",
        "icon_loader": lambda: load_regular_icon("/usr/share/icons/Papirus/64x64/apps/visual-studio-code.svg"),
        "get_cmd": lambda d: ["/usr/bin/code", d],
    },
]

# --- 4. Most Recently Used (MRU) Ordering ---
USAGE_FILE = os.path.expanduser("~/.local/state/agent-picker/usage.json")

def load_usage():
    try:
        if os.path.exists(USAGE_FILE):
            with open(USAGE_FILE, "r") as f:
                data = json.load(f)
                if isinstance(data, list):
                    return data
                elif isinstance(data, dict):
                    # Migrate old count dict: sort by count descending
                    return sorted(data.keys(), key=lambda k: data[k], reverse=True)
    except Exception:
        pass
    return []

def save_usage(app_id):
    try:
        os.makedirs(os.path.dirname(USAGE_FILE), exist_ok=True)
        recent = load_usage()
        if app_id in recent:
            recent.remove(app_id)
        # Put most recently used app at index 0
        recent.insert(0, app_id)
        with open(USAGE_FILE, "w") as f:
            json.dump(recent, f, indent=2)
    except Exception:
        pass

def arrange_center_out(ranked_apps):
    if not ranked_apps:
        return [], 0
    center_item = ranked_apps[0]
    left = []
    right = []
    for rank, item in enumerate(ranked_apps[1:], start=2):
        if rank % 2 == 0:
            left.append(item)
        else:
            right.append(item)

    final_list = list(reversed(left)) + [center_item] + right
    center_index = len(left)
    return final_list, center_index

# --- 5. Carousel UI Widget ---
class CarouselModal(QtWidgets.QWidget):
    scrollPosChanged = QtCore.pyqtSignal()

    def __init__(self, target_dir):
        super().__init__()
        self.target_dir = target_dir if (target_dir and os.path.isdir(target_dir)) else os.path.expanduser("~")
        self.setObjectName("agent-picker")
        self.setWindowTitle("agent-picker")

        self.setWindowFlags(
            QtCore.Qt.WindowType.FramelessWindowHint
            | QtCore.Qt.WindowType.WindowStaysOnTopHint
            | QtCore.Qt.WindowType.Dialog
        )
        self.setAttribute(QtCore.Qt.WidgetAttribute.WA_TranslucentBackground, True)
        self.setFocusPolicy(QtCore.Qt.FocusPolicy.StrongFocus)

        self.WIDTH = 480
        self.HEIGHT = 165
        self.setFixedSize(self.WIDTH, self.HEIGHT)

        self.CARD_WIDTH = 120
        self.CARD_HEIGHT = 126
        self.SPACING = 24

        # Rank apps purely by Most Recently Used (MRU)
        recent = load_usage()
        def mru_key(a):
            try:
                return recent.index(a["id"])
            except ValueError:
                return 9999

        ranked = sorted(APP_DEFS, key=mru_key)

        self.apps, self.center_index = arrange_center_out(ranked)
        self.current_index = self.center_index

        self.pixmaps = {}
        for app in self.apps:
            self.pixmaps[app["id"]] = app["icon_loader"]()

        self._scroll_pos = float(self.center_index)
        self.anim = QtCore.QPropertyAnimation(self, b"scrollPos")
        self.anim.setDuration(190)
        self.anim.setEasingCurve(QtCore.QEasingCurve.Type.OutCubic)

    @QtCore.pyqtProperty(float)
    def scrollPos(self):
        return self._scroll_pos

    @scrollPos.setter
    def scrollPos(self, val):
        self._scroll_pos = val
        self.update()

    def scroll_to(self, idx):
        idx = max(0, min(len(self.apps) - 1, idx))
        self.current_index = idx
        self.anim.stop()
        self.anim.setStartValue(self._scroll_pos)
        self.anim.setEndValue(float(idx))
        self.anim.start()

    def launch_current(self):
        app = self.apps[self.current_index]
        save_usage(app["id"])
        target = self.target_dir if os.path.isdir(self.target_dir) else os.path.expanduser("~")
        cmd = app["get_cmd"](target)
        # Execute inside target working directory natively (avoids foot -D colon parsing bugs)
        subprocess.Popen(["app2unit", "--", *cmd], cwd=target, start_new_session=True)
        QtWidgets.QApplication.quit()
        sys.exit(0)

    def keyPressEvent(self, event: QtGui.QKeyEvent):
        key = event.key()
        if key in (QtCore.Qt.Key.Key_Left, QtCore.Qt.Key.Key_H):
            self.scroll_to(self.current_index - 1)
        elif key in (QtCore.Qt.Key.Key_Right, QtCore.Qt.Key.Key_L):
            self.scroll_to(self.current_index + 1)
        elif key in (QtCore.Qt.Key.Key_Return, QtCore.Qt.Key.Key_Enter, QtCore.Qt.Key.Key_Space):
            self.launch_current()
        elif key in (QtCore.Qt.Key.Key_Escape, QtCore.Qt.Key.Key_Q):
            QtWidgets.QApplication.quit()
            sys.exit(0)
        else:
            super().keyPressEvent(event)

    def wheelEvent(self, event: QtGui.QWheelEvent):
        delta = event.angleDelta().y() or event.angleDelta().x()
        if delta > 0:
            self.scroll_to(self.current_index - 1)
        elif delta < 0:
            self.scroll_to(self.current_index + 1)

    def mousePressEvent(self, event: QtGui.QMouseEvent):
        click_x = event.position().x()
        center_x = self.WIDTH / 2.0
        step = self.CARD_WIDTH + self.SPACING
        offset = (click_x - center_x) / step
        clicked_idx = int(round(self._scroll_pos + offset))
        if 0 <= clicked_idx < len(self.apps):
            if clicked_idx == self.current_index:
                self.launch_current()
            else:
                self.scroll_to(clicked_idx)

    def changeEvent(self, event):
        if event.type() == QtCore.QEvent.Type.ActivationChange:
            if not self.isActiveWindow():
                QtWidgets.QApplication.quit()
                sys.exit(0)
        super().changeEvent(event)

    def paintEvent(self, event):
        painter = QtGui.QPainter(self)
        painter.setRenderHint(QtGui.QPainter.RenderHint.Antialiasing)
        painter.setRenderHint(QtGui.QPainter.RenderHint.TextAntialiasing)
        painter.setRenderHint(QtGui.QPainter.RenderHint.SmoothPixmapTransform)

        bg_rect = QtCore.QRectF(0, 0, self.WIDTH, self.HEIGHT)
        bg_color = QtGui.QColor(16, 14, 8, 235)
        border_color = QtGui.QColor(217, 197, 136, 60)

        painter.setBrush(QtGui.QBrush(bg_color))
        painter.setPen(QtGui.QPen(border_color, 1.5))
        painter.drawRoundedRect(bg_rect.adjusted(1, 1, -1, -1), 20, 20)

        center_x = self.WIDTH / 2.0
        center_y = self.HEIGHT / 2.0
        step = self.CARD_WIDTH + self.SPACING

        for i, app in enumerate(self.apps):
            diff = i - self._scroll_pos
            if abs(diff) > 2.2:
                continue

            cx = center_x + diff * step
            dist = abs(diff)

            scale = max(0.85, 1.05 - (dist * 0.16))
            opacity = max(0.35, 1.0 - (dist * 0.55))

            w = self.CARD_WIDTH * scale
            h = self.CARD_HEIGHT * scale
            card_rect = QtCore.QRectF(cx - w / 2.0, center_y - h / 2.0, w, h)

            painter.save()
            painter.setOpacity(opacity)

            if dist < 0.5:
                card_bg = QtGui.QColor(217, 197, 136, int(35 + (0.5 - dist) * 35))
                card_border = QtGui.QColor(217, 197, 136, int(180 + (0.5 - dist) * 75))
                border_width = 2.0
            else:
                card_bg = QtGui.QColor(30, 28, 22, 140)
                card_border = QtGui.QColor(255, 255, 255, 18)
                border_width = 1.0

            painter.setBrush(QtGui.QBrush(card_bg))
            painter.setPen(QtGui.QPen(card_border, border_width))
            painter.drawRoundedRect(card_rect, 14, 14)

            icon_pix = self.pixmaps[app["id"]]
            icon_size = 46 * scale
            icon_x = cx - icon_size / 2.0
            icon_y = card_rect.top() + (14 * scale)
            painter.drawPixmap(
                QtCore.QRectF(icon_x, icon_y, icon_size, icon_size),
                icon_pix,
                QtCore.QRectF(icon_pix.rect())
            )

            painter.setPen(QtGui.QColor(238, 229, 209))
            font = QtGui.QFont("JetBrains Mono", int(11 * scale), QtGui.QFont.Weight.Bold)
            painter.setFont(font)

            text_rect = QtCore.QRectF(
                card_rect.left() + 4,
                icon_y + icon_size + (8 * scale),
                card_rect.width() - 8,
                24 * scale
            )
            painter.drawText(text_rect, QtCore.Qt.AlignmentFlag.AlignCenter, app["title"])

            painter.restore()

        dot_y = self.HEIGHT - 12
        total_dots = len(self.apps)
        dot_spacing = 8
        dots_width = total_dots * dot_spacing
        start_dot_x = center_x - dots_width / 2.0

        for idx in range(total_dots):
            dx = start_dot_x + idx * dot_spacing
            d_dist = abs(idx - self._scroll_pos)
            if d_dist < 0.6:
                painter.setBrush(QtGui.QBrush(QtGui.QColor(217, 197, 136, 220)))
                r = 2.5
            else:
                painter.setBrush(QtGui.QBrush(QtGui.QColor(150, 140, 120, 80)))
                r = 1.8
            painter.setPen(QtCore.Qt.PenStyle.NoPen)
            painter.drawEllipse(QtCore.QPointF(dx, dot_y), r, r)

        painter.end()

def main():
    target_dir = get_workspace_dir()

    app = QtWidgets.QApplication(sys.argv)
    app.setDesktopFileName("agent-picker")
    app.setApplicationName("agent-picker")

    modal = CarouselModal(target_dir)

    screen = app.primaryScreen()
    if screen:
        geo = screen.geometry()
        modal.move(
            int((geo.width() - modal.WIDTH) / 2),
            int((geo.height() - modal.HEIGHT) / 2)
        )

    modal.show()
    modal.raise_()
    modal.activateWindow()

    ret = app.exec()
    sys.exit(ret)

if __name__ == "__main__":
    main()
