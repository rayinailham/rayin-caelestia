#!/usr/bin/python3
import sys
import os
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

KEYBINDS = [
    # Workspaces
    {"category": "Workspaces", "action": "Go to Workspace [1-10]", "keys": ["Super", "[1-0]"]},
    {"category": "Workspaces", "action": "Go to Workspace Group [1-10]", "keys": ["Ctrl", "Super", "[1-0]"]},
    {"category": "Workspaces", "action": "Next Workspace", "keys": ["Ctrl", "Super", "Right"]},
    {"category": "Workspaces", "action": "Previous Workspace", "keys": ["Ctrl", "Super", "Left"]},
    {"category": "Workspaces", "action": "Next Workspace (Alt)", "keys": ["Super", "Page_Down"]},
    {"category": "Workspaces", "action": "Previous Workspace (Alt)", "keys": ["Super", "Page_Up"]},
    {"category": "Workspaces", "action": "Scroll Next Workspace", "keys": ["Super", "Scroll Down"]},
    {"category": "Workspaces", "action": "Scroll Prev Workspace", "keys": ["Super", "Scroll Up"]},
    {"category": "Workspaces", "action": "Next Workspace Group", "keys": ["Ctrl", "Super", "Scroll Down"]},
    {"category": "Workspaces", "action": "Prev Workspace Group", "keys": ["Ctrl", "Super", "Scroll Up"]},
    {"category": "Workspaces", "action": "Toggle Special Workspace", "keys": ["Super", "S"]},

    # Window Placement
    {"category": "Window Placement", "action": "Move Window to Workspace [1-10]", "keys": ["Super", "Alt", "[1-0]"]},
    {"category": "Window Placement", "action": "Move Window to Group [1-10]", "keys": ["Ctrl", "Super", "Alt", "[1-0]"]},
    {"category": "Window Placement", "action": "Move Window to Next Workspace", "keys": ["Ctrl", "Super", "Shift", "Right"]},
    {"category": "Window Placement", "action": "Move Window to Prev Workspace", "keys": ["Ctrl", "Super", "Shift", "Left"]},
    {"category": "Window Placement", "action": "Move Window to Next (Alt)", "keys": ["Super", "Alt", "Page_Down"]},
    {"category": "Window Placement", "action": "Move Window to Prev (Alt)", "keys": ["Super", "Alt", "Page_Up"]},
    {"category": "Window Placement", "action": "Move Window to Special Workspace", "keys": ["Ctrl", "Super", "Shift", "Up"]},
    {"category": "Window Placement", "action": "Restore Window from Special Workspace", "keys": ["Ctrl", "Super", "Shift", "Down"]},
    {"category": "Window Placement", "action": "Move Window to Special (Alt)", "keys": ["Super", "Alt", "S"]},

    # Window Actions
    {"category": "Window Actions", "action": "Close Active Window", "keys": ["Super", "Q"]},
    {"category": "Window Actions", "action": "Toggle Floating Mode", "keys": ["Super", "Alt", "Space"]},
    {"category": "Window Actions", "action": "Toggle Fullscreen", "keys": ["Super", "F"]},
    {"category": "Window Actions", "action": "Toggle Fullscreen (Borders)", "keys": ["Super", "Alt", "F"]},
    {"category": "Window Actions", "action": "Move Focus (Left/Right/Up/Down)", "keys": ["Super", "Arrow Keys"]},
    {"category": "Window Actions", "action": "Swap Window Position", "keys": ["Super", "Shift", "Arrow Keys"]},
    {"category": "Window Actions", "action": "Drag & Move Window", "keys": ["Super", "L-Click"]},
    {"category": "Window Actions", "action": "Keyboard Move Window", "keys": ["Super", "Z"]},
    {"category": "Window Actions", "action": "Drag & Resize Window", "keys": ["Super", "R-Click"]},
    {"category": "Window Actions", "action": "Keyboard Resize Window", "keys": ["Super", "X"]},
    {"category": "Window Actions", "action": "Resize Width (Left/Right)", "keys": ["Super", "- / ="]},
    {"category": "Window Actions", "action": "Resize Height (Up/Down)", "keys": ["Super", "Shift", "- / ="]},
    {"category": "Window Actions", "action": "Resize Fine-tuned", "keys": ["Super", "Alt", "Arrow Keys"]},
    {"category": "Window Actions", "action": "Center Window", "keys": ["Ctrl", "Super", "\\"]},
    {"category": "Window Actions", "action": "Center & Resize (55%x70%)", "keys": ["Ctrl", "Super", "Alt", "\\"]},
    {"category": "Window Actions", "action": "Picture-in-Picture (PiP) Mode", "keys": ["Super", "Alt", "\\"]},
    {"category": "Window Actions", "action": "Pin Window (All Workspaces)", "keys": ["Super", "P"]},

    # Window Groups (Tabs)
    {"category": "Window Groups (Tabs)", "action": "Toggle Tab Group", "keys": ["Super", ","]},
    {"category": "Window Groups (Tabs)", "action": "Ungroup Active Window", "keys": ["Super", "U"]},
    {"category": "Window Groups (Tabs)", "action": "Cycle Tab Forward", "keys": ["Alt", "Tab"]},
    {"category": "Window Groups (Tabs)", "action": "Cycle Tab Backward", "keys": ["Shift", "Alt", "Tab"]},
    {"category": "Window Groups (Tabs)", "action": "Switch Active Group Tab Forward", "keys": ["Ctrl", "Alt", "Tab"]},
    {"category": "Window Groups (Tabs)", "action": "Switch Active Group Tab Backward", "keys": ["Ctrl", "Shift", "Alt", "Tab"]},
    {"category": "Window Groups (Tabs)", "action": "Lock Active Group Toggle", "keys": ["Super", "Shift", ","]},

    # Apps & Launchers
    {"category": "Apps & Launchers", "action": "Open App Launcher Menu", "keys": ["Super"]},
    {"category": "Apps & Launchers", "action": "Open Terminal (foot)", "keys": ["Super", "T"]},
    {"category": "Apps & Launchers", "action": "Toggle Browser Overlay", "keys": ["Super", "B"]},
    {"category": "Apps & Launchers", "action": "Open Editor (OpenCode)", "keys": ["Super", "C"]},
    {"category": "Apps & Launchers", "action": "Open File Explorer (Dolphin)", "keys": ["Super", "E"]},
    {"category": "Apps & Launchers", "action": "Open System Monitor Overlay", "keys": ["Ctrl", "Shift", "Escape"]},
    {"category": "Apps & Launchers", "action": "Open Process Manager (qps)", "keys": ["Ctrl", "Alt", "Escape"]},
    {"category": "Apps & Launchers", "action": "Open Volume Mixer (pavucontrol)", "keys": ["Ctrl", "Alt", "V"]},
    {"category": "Apps & Launchers", "action": "Toggle Music Overlay", "keys": ["Super", "M"]},
    {"category": "Apps & Launchers", "action": "Toggle Discord Overlay", "keys": ["Super", "D"]},
    {"category": "Apps & Launchers", "action": "Toggle WhatsApp Overlay", "keys": ["Super", "W"]},
    {"category": "Apps & Launchers", "action": "Toggle Teams Overlay", "keys": ["Super", "U"]},

    # Utilities
    {"category": "Utilities", "action": "Shortcut Help Menu", "keys": ["Super", "/"]},
    {"category": "Utilities", "action": "Toggle Sidebar", "keys": ["Super", "N"]},
    {"category": "Utilities", "action": "Toggle Dashboard Panels", "keys": ["Super", "K"]},
    {"category": "Utilities", "action": "Clear Notifications", "keys": ["Ctrl", "Alt", "C"]},
    {"category": "Utilities", "action": "Screenshot (Full Screen)", "keys": ["Print"]},
    {"category": "Utilities", "action": "Screenshot (Freeze Selection)", "keys": ["Super", "Shift", "S"]},
    {"category": "Utilities", "action": "Screenshot (Selection)", "keys": ["Super", "Shift", "Alt", "S"]},
    {"category": "Utilities", "action": "Record Selection with Sound", "keys": ["Super", "Alt", "R"]},
    {"category": "Utilities", "action": "Record Full Screen (Silent)", "keys": ["Ctrl", "Alt", "R"]},
    {"category": "Utilities", "action": "Record Selection (Silent)", "keys": ["Super", "Shift", "Alt", "R"]},
    {"category": "Utilities", "action": "Color Picker", "keys": ["Super", "Shift", "C"]},
    {"category": "Utilities", "action": "Clipboard History Menu", "keys": ["Super", "V"]},
    {"category": "Utilities", "action": "Clipboard Delete Item Menu", "keys": ["Super", "Alt", "V"]},
    {"category": "Utilities", "action": "Emoji Picker", "keys": ["Super", "."]},
    {"category": "Utilities", "action": "Autotype Last Copied Text", "keys": ["Ctrl", "Shift", "Alt", "V"]},

    # System & Media
    {"category": "System & Media", "action": "Volume Up (10%)", "keys": ["AudioRaiseVolume"]},
    {"category": "System & Media", "action": "Volume Down (10%)", "keys": ["AudioLowerVolume"]},
    {"category": "System & Media", "action": "Mute Speaker Toggle", "keys": ["AudioMute"]},
    {"category": "System & Media", "action": "Mute Speaker Toggle (Alt)", "keys": ["Super", "Shift", "M"]},
    {"category": "System & Media", "action": "Mute Mic Toggle", "keys": ["AudioMicMute"]},
    {"category": "System & Media", "action": "Brightness Up / Down", "keys": ["MonBrightnessUp/Down"]},
    {"category": "System & Media", "action": "Media Play / Pause", "keys": ["Ctrl", "Super", "Space"]},
    {"category": "System & Media", "action": "Media Next Track", "keys": ["Ctrl", "Super", "="]},
    {"category": "System & Media", "action": "Media Prev Track", "keys": ["Ctrl", "Super", "-"]},
    {"category": "System & Media", "action": "Lock Screen", "keys": ["Super", "L"]},
    {"category": "System & Media", "action": "Restore Lock Screen", "keys": ["Super", "Alt", "L"]},
    {"category": "System & Media", "action": "Power / Session Menu", "keys": ["Ctrl", "Alt", "Delete"]},
    {"category": "System & Media", "action": "Suspend & Hibernate", "keys": ["Super", "Shift", "L"]},
    {"category": "System & Media", "action": "Kill Shell UI", "keys": ["Ctrl", "Super", "Shift", "R"]},
    {"category": "System & Media", "action": "Restart Shell UI", "keys": ["Ctrl", "Super", "Alt", "R"]},

    # Touchpad Gestures
    {"category": "Touchpad Gestures (Laptops)", "action": "Switch Workspace", "keys": ["4-finger horizontal swipe"]},
    {"category": "Touchpad Gestures (Laptops)", "action": "Open Special Workspace", "keys": ["3-finger swipe up"]},
    {"category": "Touchpad Gestures (Laptops)", "action": "Close Special Workspace", "keys": ["3-finger swipe down"]},
    {"category": "Touchpad Gestures (Laptops)", "action": "Suspend System", "keys": ["4-finger swipe down"]}
]

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
        conf_path = os.path.expanduser("~/.config/hypr/scheme/current.conf")
        if os.path.exists(conf_path):
            with open(conf_path) as f:
                for line in f:
                    if "=" in line:
                        k, v = line.strip().split("=", 1)
                        k = k.strip().replace("$", "")
                        v = v.strip()
                        if not v.startswith("#"):
                            v = "#" + v
                        colors[k] = v
    except Exception as e:
        print("Error loading colors:", e)
    return colors

class KeybindsWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Hyprland & Caelestia Keybinds")
        self.set_default_size(700, 560)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_wmclass("shortcut-helper", "shortcut-helper")
        
        # Apply CSS
        self.apply_css()
        
        # Main Layout
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        vbox.set_margin_top(15)
        vbox.set_margin_bottom(15)
        vbox.set_margin_start(15)
        vbox.set_margin_end(15)
        self.add(vbox)
        
        # Header Box (Title & Escape Hint)
        header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        title = Gtk.Label(label="⌨️  Hyprland & Caelestia Shortcuts")
        title.get_style_context().add_class("title-label")
        header_box.pack_start(title, False, False, 0)
        
        escape_lbl = Gtk.Label(label="[Esc] to close")
        escape_lbl.get_style_context().add_class("escape-hint")
        header_box.pack_end(escape_lbl, False, False, 0)
        vbox.pack_start(header_box, False, False, 0)
        
        # Search Entry
        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_placeholder_text("Type to search shortcuts...")
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
        .title-label {{
            font-size: 16px;
            font-weight: bold;
            color: {colors.get('primary', '#abccda')};
        }}
        .escape-hint {{
            font-size: 11px;
            color: {colors.get('subtext0', '#8b9295')};
            font-family: monospace;
        }}
        .search-bar {{
            background-color: {colors.get('surfaceContainerLow', '#1a1c1d')};
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 8px;
            padding: 8px;
            color: {colors.get('text', '#e3e2e3')};
            font-size: 13px;
        }}
        .search-bar:focus {{
            border-color: {colors.get('primary', '#abccda')};
        }}
        button.category-btn {{
            background: {colors.get('surfaceContainerLow', '#1a1c1d')};
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 8px;
            padding: 6px 10px;
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
            padding: 10px 12px;
            background-color: transparent;
            border-bottom: 1px solid {colors.get('surfaceContainerLow', '#1a1c1d')};
        }}
        .key-row:hover {{
            background-color: {colors.get('surfaceContainerHigh', '#292a2b')};
        }}
        .key-action {{
            font-size: 13px;
            font-weight: 500;
            color: {colors.get('text', '#e3e2e3')};
        }}
        .key-category {{
            font-size: 9px;
            color: {colors.get('subtext0', '#8b9295')};
            font-weight: bold;
            letter-spacing: 0.5px;
        }}
        .keycap {{
            background-color: {colors.get('surfaceContainerHighest', '#343536')};
            color: {colors.get('onSurface', '#e3e2e3')};
            border: 1px solid {colors.get('outline', '#8b9295')};
            border-radius: 4px;
            padding: 2px 6px;
            font-size: 11px;
            font-family: monospace;
            font-weight: bold;
        }}
        scrolledwindow {{
            border: 1px solid {colors.get('outlineVariant', '#42484b')};
            border-radius: 8px;
            background-color: {colors.get('surfaceContainerLow', '#1a1c1d')};
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
