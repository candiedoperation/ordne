public class Application : Gtk.Application {
    protected override void activate () {
        Hdy.init ();
    
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();                        
        
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        var welcome_page = new Granite.Widgets.Welcome ("Ordne", "A simple Pomodoro Timer.");
        welcome_page.append ("document-open-recent", "Start Working", "Begin the Working Countdown.");
        welcome_page.append ("preferences-system", "Pomodoro Preferences", "Change Break and Working Duration");
        welcome_page.append ("process-stop", "Close", "Close the Application");
        
        var grid_welcome = new Gtk.Grid ();
        grid_welcome.attach(welcome_page, 0, 1);                           
        
        var grid = new Gtk.Grid ();
        grid.attach(grid_welcome, 0, 1);
        
        var windowhandle = new Hdy.WindowHandle();
        windowhandle.add(grid);
        
        var hdy_window = new Hdy.Window ();    
        hdy_window.application = this;
        hdy_window.title = ("Ordne");
        hdy_window.add(windowhandle);
        hdy_window.set_size_request (600, 500);
        hdy_window.window_position = Gtk.WindowPosition.CENTER;      
        
        hdy_window.show_all();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }    
}
