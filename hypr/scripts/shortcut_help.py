#!/usr/bin/python3
import sys
import os
import re
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

import json
import subprocess

# Hyprland 0.57+ is Lua-only: binds are read live from `hyprctl binds -j`.
# Each bind's label is its `description` set in hyprland/keybinds.lua / hypr-user.lua;
# binds without a description are hidden (internal helpers).
MODS = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]

def key_name(key):
    return {
        "mouse:272": "L-Click",
        "mouse:273": "R-Click",
        "mouse_up": "Scroll Up",
        "mouse_down": "Scroll Down",
        "slash": "/",
        "period": ".",
        "comma": ",",
        "backslash": "\\",
        "equal": "=",
        "minus": "-",
        "super_l": "Super",
        "xf86audioraisevolume": "AudioRaiseVolume",
        "xf86audiolowervolume": "AudioLowerVolume",
        "xf86audiomute": "AudioMute",
        "xf86audiomicmute": "AudioMicMute",
        "xf86monbrightnessup": "BrightnessUp",
        "xf86monbrightnessdown": "BrightnessDown",
    }.get(key.lower(), key)

def key_tokens(modmask, key):
    tokens = [name for bit, name in MODS if modmask & bit]
    name = key_name(key)
    if name not in tokens:
        tokens.append(name)
    return tokens

def category_for(action):
    text = action.lower()
    if text.startswith("window group"):
        return "Window Groups"
    if "move window to" in text or "move window out" in text:
        return "Window Placement"
    if "workspace" in text and "overlay" not in text:
        return "Workspaces"
    if any(w in text for w in ["window", "fullscreen", "focus", "pin", "picture-in-picture"]):
        return "Window Actions"
    if any(w in text for w in ["open ", "launcher", "overlay"]):
        return "Apps & Launchers"
    if any(w in text for w in ["volume", "mute", "media", "brightness", "lock", "suspend", "shell", "session", "sidebar", "dashboard", "notification"]):
        return "System & Media"
    return "Utilities"

def has_touchpad():
    try:
        with open("/proc/bus/input/devices") as f:
            return "touchpad" in f.read().lower()
    except OSError:
        return False

# shortcut: mirrors hyprland/gestures.lua by hand; update both if gestures change.
GESTURES = [
    ("3-finger horizontal swipe", "Switch workspace"),
    ("4-finger horizontal swipe", "Switch workspace"),
    ("3-finger up swipe", "Close special workspace"),
    ("3-finger down swipe", "Open special workspace"),
    ("4-finger down swipe", "Suspend system"),
]

def parse_keybinds():
    try:
        binds = json.loads(subprocess.check_output(["hyprctl", "binds", "-j"], text=True))
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as e:
        print("Error reading binds:", e)
        binds = []
    rows, seen = [], set()
    for b in binds:
        action = (b.get("description") or "").strip()
        if not action:
            continue
        item = {"category": category_for(action), "action": action, "keys": key_tokens(b.get("modmask", 0), b.get("key", ""))}
        ident = (item["category"], item["action"], tuple(item["keys"]))
        if ident not in seen:
            seen.add(ident)
            rows.append(item)
    if has_touchpad():
        rows.extend({"category": "Touchpad Gestures", "action": act, "keys": [keys]} for keys, act in GESTURES)
    rows.sort(key=lambda item: (item["category"], item["action"], " ".join(item["keys"])))
    return rows

KEYBINDS = parse_keybinds()

def load_colors():
    colors = {
        "background": "#121414",
        "text": "#e3e2e3",
        "surfaceContainerLow": "#1a1c1d",
        "outline": "#8b9295",
        "primary": "#ccedfd",
        "outlineVariant": "#42484b",
        "surfaceContainerHigh": "#292a2b",
        "subtext0": "#8b9295",
        "surfaceContainerHighest": "#343536",
        "onSurface": "#e3e2e3"
    }
    try:
        lua_path = os.path.expanduser("~/.config/hypr/scheme/current.lua")
        with open(lua_path) as f:
            for k, v in re.findall(r'^\s*(\w+)\s*=\s*"([0-9A-Fa-f]{6,8})"', f.read(), re.M):
                colors[k] = "#" + v
    except Exception as e:
        print("Error loading colors:", e)
    return colors

class KeybindsWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Hyprland & Caelestia Keybinds")
        self.set_default_size(820, 640)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_wmclass("shortcut-helper", "shortcut-helper")
        
        # Apply CSS
        self.apply_css()
        
        # Main Layout
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        vbox.get_style_context().add_class("main-card")
        vbox.set_margin_top(18)
        vbox.set_margin_bottom(18)
        vbox.set_margin_start(18)
        vbox.set_margin_end(18)
        self.add(vbox)
        
        # Header Box (Title & Escape Hint)
        header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        title = Gtk.Label(label="Hyprland Shortcuts")
        title.get_style_context().add_class("title-label")
        header_box.pack_start(title, False, False, 0)
        
        escape_lbl = Gtk.Label(label="Esc closes")
        escape_lbl.get_style_context().add_class("escape-hint")
        header_box.pack_end(escape_lbl, False, False, 0)
        vbox.pack_start(header_box, False, False, 0)
        
        # Search Entry
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_placeholder_text("Search shortcuts...")
        self.search_entry.get_style_context().add_class("search-bar")
        self.search_entry.connect("search-changed", self.on_search_changed)
        vbox.pack_start(self.search_entry, False, False, 0)

        # Category Filter Buttons
        self.filter_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        vbox.pack_start(self.filter_box, False, False, 0)
        
        self.categories = [
            ("All", "All"),
            ("Workspaces", "Workspaces"),
            ("Windows", "Windows"),
            ("Apps", "Apps"),
            ("Utilities", "Utilities"),
            ("System", "System"),
            ("Touchpad", "Touchpad")
        ]
        self.category_buttons = {}
        self.active_category = "All"
        
        for name, label in self.categories:
            btn = Gtk.Button(label=label)
            btn.get_style_context().add_class("category-btn")
            if name == "All":
                btn.get_style_context().add_class("category-btn-active")
            btn.connect("clicked", self.on_category_clicked, name)
            self.filter_box.pack_start(btn, True, True, 0)
            self.category_buttons[name] = btn
        
        # Scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        vbox.pack_start(scrolled, True, True, 0)
        
        # List box for keybinds
        self.listbox = Gtk.ListBox()
        self.listbox.set_selection_mode(Gtk.SelectionMode.NONE)
        scrolled.add(self.listbox)
        
        # Populate List
        self.populate_keybinds()
        
        # Close on Escape key
        self.connect("key-press-event", self.on_key_press)
        
        self.show_all()
        
    def apply_css(self):
        colors = load_colors()
        css = f"""
        window {{
            background-color: {colors.get('background', '#121414')};
            color: {colors.get('text', '#e3e2e3')};
        }}
        .main-card {{
            background-color: {colors.get('surfaceContainerLow', '#1a1c1d')};
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 18px;
            padding: 16px;
        }}
        .title-label {{
            font-size: 22px;
            font-weight: bold;
            color: {colors.get('primary', '#abccda')};
        }}
        .escape-hint {{
            font-size: 12px;
            color: {colors.get('subtext0', '#8b9295')};
            font-family: monospace;
            padding: 6px 10px;
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 999px;
        }}
        .search-bar {{
            background-color: {colors.get('background', '#121414')};
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 12px;
            padding: 10px 12px;
            color: {colors.get('text', '#e3e2e3')};
            font-size: 14px;
        }}
        .search-bar:focus {{
            border-color: {colors.get('primary', '#abccda')};
        }}
        button.category-btn {{
            background: {colors.get('background', '#121414')};
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 999px;
            padding: 7px 12px;
            color: {colors.get('text', '#e3e2e3')};
            font-size: 12px;
            font-weight: bold;
            box-shadow: none;
            text-shadow: none;
        }}
        button.category-btn:hover {{
            background: {colors.get('surfaceContainerHigh', '#292a2b')};
            border-color: {colors.get('outline', '#8b9295')};
            color: {colors.get('onSurface', '#e3e2e3')};
        }}
        button.category-btn-active, button.category-btn-active:hover {{
            background: {colors.get('primary', '#abccda')};
            color: {colors.get('background', '#121414')};
            border-color: {colors.get('primary', '#abccda')};
        }}
        .key-row {{
            padding: 12px 14px;
            background-color: transparent;
            border-bottom: 1px solid {colors.get('outlineVariant', '#42484b')};
        }}
        .key-row:hover {{
            background-color: {colors.get('surfaceContainerHigh', '#292a2b')};
        }}
        .key-action {{
            font-size: 14px;
            font-weight: 600;
            color: {colors.get('text', '#e3e2e3')};
        }}
        .key-category {{
            font-size: 10px;
            color: {colors.get('subtext0', '#8b9295')};
            font-weight: bold;
            letter-spacing: 0.8px;
        }}
        .keycap {{
            background-color: {colors.get('background', '#121414')};
            color: {colors.get('onSurface', '#e3e2e3')};
            border: 1px solid {colors.get('outline', '#8b9295')};
            border-radius: 7px;
            padding: 3px 8px;
            font-size: 12px;
            font-family: monospace;
            font-weight: bold;
        }}
        scrolledwindow {{
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 14px;
            background-color: {colors.get('background', '#121414')};
        }}
        listbox {{
            background-color: transparent;
        }}
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
    def populate_keybinds(self):
        self.rows_widgets = []
        for bind in KEYBINDS:
            row_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            row_box.get_style_context().add_class("key-row")
            
            # Left info box (action + category)
            info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            
            category_lbl = Gtk.Label()
            category_lbl.set_text(bind['category'].upper())
            category_lbl.get_style_context().add_class("key-category")
            category_lbl.set_xalign(0)
            info_box.pack_start(category_lbl, False, False, 0)
            
            action_lbl = Gtk.Label()
            action_lbl.set_text(bind['action'])
            action_lbl.get_style_context().add_class("key-action")
            action_lbl.set_xalign(0)
            info_box.pack_start(action_lbl, False, False, 0)
            
            row_box.pack_start(info_box, True, True, 0)
            
            # Right keycaps box
            keys_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
            keys_box.set_valign(Gtk.Align.CENTER)
            
            for i, key in enumerate(bind['keys']):
                if i > 0:
                    plus_lbl = Gtk.Label(label="+")
                    plus_lbl.set_valign(Gtk.Align.CENTER)
                    keys_box.pack_start(plus_lbl, False, False, 2)
                
                key_lbl = Gtk.Label(label=key)
                key_lbl.get_style_context().add_class("keycap")
                keys_box.pack_start(key_lbl, False, False, 0)
                
            row_box.pack_end(keys_box, False, False, 0)
            
            list_row = Gtk.ListBoxRow()
            list_row.add(row_box)
            self.listbox.add(list_row)
            
            search_text = f"{bind['category']} {bind['action']} {' '.join(bind['keys'])}".lower()
            self.rows_widgets.append((list_row, search_text, bind['category']))

    def on_category_clicked(self, button, category_name):
        for name, btn in self.category_buttons.items():
            if name == category_name:
                btn.get_style_context().add_class("category-btn-active")
            else:
                btn.get_style_context().remove_class("category-btn-active")
        
        self.active_category = category_name
        self.update_filtering()

    def on_search_changed(self, entry):
        self.update_filtering()

    def update_filtering(self):
        query = self.search_entry.get_text().lower().strip()
        for list_row, search_text, category in self.rows_widgets:
            mapped_category = "All"
            cat_lower = category.lower()
            if "workspace" in cat_lower:
                mapped_category = "Workspaces"
            elif "window" in cat_lower:
                mapped_category = "Windows"
            elif "apps" in cat_lower:
                mapped_category = "Apps"
            elif "utilit" in cat_lower:
                mapped_category = "Utilities"
            elif "system" in cat_lower:
                mapped_category = "System"
            elif "touchpad" in cat_lower:
                mapped_category = "Touchpad"
                
            match_query = not query or query in search_text
            match_category = self.active_category == "All" or mapped_category == self.active_category
            
            if match_query and match_category:
                list_row.show()
            else:
                list_row.hide()
                
    def on_key_press(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self.close()

if __name__ == "__main__":
    win = KeybindsWindow()
    win.connect("destroy", Gtk.main_quit)
    Gtk.main()
