#!/usr/bin/env python3
import json, os, subprocess, sys

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
        # Check child processes first (foot -> fish / editor)
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

    # 1. If currently focused window is Dolphin -> get exact path via DBus or title
    if "dolphin" in active_win.get("class", "").lower():
        p = get_dolphin_path_from_pid(active_win.get("pid")) or parse_dolphin_title(active_win.get("title", ""))
        if p and os.path.isdir(p):
            return p

    # 2. Check Dolphin windows in active workspace
    ws_clients = [c for c in clients if c.get("workspace", {}).get("id") == ws_id]
    for c in ws_clients:
        if "dolphin" in c.get("class", "").lower():
            p = get_dolphin_path_from_pid(c.get("pid")) or parse_dolphin_title(c.get("title", ""))
            if p and os.path.isdir(p):
                return p

    # 3. If focused window is terminal / editor -> get its process cwd
    p = get_proc_cwd(active_win.get("pid"))
    if p and os.path.isdir(p):
        return p

    # 4. Check any terminal / editor in active workspace
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

    # 6. Fallback
    return os.path.expanduser("~")

if __name__ == "__main__":
    d = get_workspace_dir()
    if not d or not os.path.isdir(d):
        d = os.path.expanduser("~")
    print(d)
