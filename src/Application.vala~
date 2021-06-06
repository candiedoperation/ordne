public class Application : Gtk.Application {
    protected override void activate () {   
        //Gtk.ApplicationWindow app_window = new Gtk.ApplicationWindow (this);
             
        var gtk_settings = Gtk.Settings.get_default ();
        var hdy_window = new Hdy.ApplicationWindow ();
        var header_bar = new Hdy.HeaderBar ();
        var overlaybar = new Granite.Widgets.OverlayBar ();
        
        hdy_window.application = this;

        var dark_mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        );
        
        //New Document
        var welcome_page = new Granite.Widgets.Welcome ("Ordne", "A simple Pomodoro Timer.");
        welcome_page.append ("document-open-recent", "Start Working", "Begin the Working Countdown.");
        welcome_page.append ("preferences-system", "Pomodoro Preferences", "Change Break and Working Duration");
        
        var grid_welcome = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };  

        dark_mode_switch.primary_icon_tooltip_text = ("Light background");
        dark_mode_switch.secondary_icon_tooltip_text = ("Dark background");
        dark_mode_switch.valign = Gtk.Align.CENTER;
        dark_mode_switch.bind_property ("active", gtk_settings, "gtk-application-prefer-dark-theme", GLib.BindingFlags.BIDIRECTIONAL);

        header_bar.show_close_button = true;
        header_bar.title = "Ordne";
        header_bar.pack_end(dark_mode_switch);  
        
        grid_welcome.add(header_bar);
        grid_welcome.add(welcome_page);       
        
        hdy_window.window_position = Gtk.WindowPosition.CENTER;
        hdy_window.set_default_size(1200, 700);
        hdy_window.add(grid_welcome);
        //main_window.set_titlebar(header_bar);
        //main_window.add(grid_welcome); //Adds the welcome grid to the window
        
        //hdy_window.add (main_window);
        hdy_window.show_all();
        //main_window.show_all();
    }
    
    public static void initialize_application() {
        print("Hello");
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }    
}
