public class Application : Gtk.Application {
    private Granite.Widgets.Welcome welcome_page;
    private Granite.Widgets.Welcome stats_page;
    private Gtk.Button close_app;
    private Gtk.Button stop_working;    
    private Gtk.Grid grid_welcome;
    private Gtk.Grid grid_stats;
    private Gtk.Grid grid_countdown;
    private Gtk.Grid grid;
    private Gtk.Label countdown_time;
    private Gtk.Label countdown_type;    
    private Gtk.Image countdown_icon;
    private Hdy.WindowHandle window_handle;
    private Hdy.Window hdy_window;
    private int complete_working_duration;
    private int complete_break_duration; 
    private int current_countdown_duration;   
    
    protected override void activate () {
        Hdy.init (); //Initializing LibHandy
    
        var granite_settings = Granite.Settings.get_default (); //For Auto Dark Mode Toggle
        var gtk_settings = Gtk.Settings.get_default (); //For Auto Dark Mode Toggle
        
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        create_welcome_page (); //Adding UI Elements to the Welcome Grid
        create_stats_page ();
        create_countdown_page ();
                                   
        grid = new Gtk.Grid ();
        grid.attach(grid_welcome, 0, 1); //grid_welcome intialally
        
        window_handle = new Hdy.WindowHandle();
        window_handle.add(grid);
        
        initialize_hdy_window(); //Creating new Hdy.Window and Adding Preferences
        hdy_window.show_all();
    }
    
    private void on_welcome_action(int option) {
        switch(option) {
            case 0: {
                start_working_countdown();
                grid.remove(grid_welcome);
                grid.attach(grid_countdown, 0, 1);
                hdy_window.show_all();
                break;
            }
            
            case 2: {
                hdy_window.destroy();
                break;
            }
        }        
    }
    
    private void on_stats_action(int option) {
        switch(option) {
            case 0: {
                grid.remove(grid_stats);
                grid.attach(grid_countdown, 0, 1);
                hdy_window.show_all();
                break;
            }
                    
            case 3: {
                hdy_window.destroy();
                break;
            }
        }        
    }
    
    private void start_working_countdown() {
        current_countdown_duration = 20;
        update_timer_label(Granite.DateTime.seconds_to_time(current_countdown_duration) + " seconds");
        
        Timeout.add(1000, () => {
            current_countdown_duration--;
            if(current_countdown_duration > 0) {
                //Update countdown label
                continue_timer_countdown(current_countdown_duration);
                return true;
            } else {
                //Call end timer function
                end_timer_countdown(current_countdown_duration);                
                return false;
            }
        });
    }
    
    private void continue_timer_countdown(int time_left) {     
        update_timer_label(Granite.DateTime.seconds_to_time(time_left) + " seconds");        
    }
    
    private void end_timer_countdown(int time_left) {
        if(time_left == 0) {
            //Auto Ended, Notify
            //Update total time by subtracting from stored time
            update_timer_label(Granite.DateTime.seconds_to_time(time_left) + " seconds");
        } 
        
        grid.remove(grid_countdown);
        grid.attach(grid_stats, 0, 1);
        hdy_window.show_all();            
    }
    
    private void update_timer_label(string label_data) {
        countdown_time.label = label_data;
    }
    
    private void create_welcome_page() {
        welcome_page = new Granite.Widgets.Welcome ("Ordne", "A simple Pomodoro Timer.");
        welcome_page.append ("document-open-recent", "Start Working", "Begin the Working Countdown");
        //welcome_page.append ("face-tired", "Take a Break", "Begin the Break Countdown");
        welcome_page.append ("preferences-system", "Pomodoro Preferences", "Change Break and Working Duration");
        welcome_page.append ("process-stop", "Close", "Close the Application");
        welcome_page.activated.connect (on_welcome_action);  
        
        grid_welcome = new Gtk.Grid ();
        grid_welcome.attach(welcome_page, 0, 1);               
    }
    
    private void create_stats_page() {
        stats_page = new Granite.Widgets.Welcome ("Stats", "Work - 19 Minutes | Break - 5 Minutes");
        stats_page.append ("document-open-recent", "Continue Working", "Continue the Working Countdown");
        stats_page.append ("face-tired", "Take a Break", "Begin the Break Countdown");
        stats_page.append ("preferences-system", "Pomodoro Preferences", "Change Break and Working Duration");
        stats_page.append ("process-stop", "Close", "Close the Application");
        stats_page.activated.connect (on_stats_action); 
        
        grid_stats = new Gtk.Grid ();
        grid_stats.attach(stats_page, 0, 1);                
    }
    
    private void create_countdown_page() {
        close_app = new Gtk.Button.with_label("Close");
        close_app.clicked.connect(() => { hdy_window.destroy(); });
        
        stop_working = new Gtk.Button.with_label("Stop Working");
        stop_working.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
        stop_working.clicked.connect(() => { end_timer_countdown(current_countdown_duration); });
        
        countdown_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("document-open-recent"),
            pixel_size = 100
        };        
        
        countdown_time = new Gtk.Label("00:00 seconds");
        countdown_time.set_halign(Gtk.Align.CENTER);        
        countdown_time.hexpand = true;

        unowned Gtk.StyleContext countdown_time_context = countdown_time.get_style_context ();
        countdown_time_context.add_class (Granite.STYLE_CLASS_H1_LABEL);        
        countdown_time_context.add_class (Granite.STYLE_CLASS_ACCENT);                
        
        countdown_type = new Gtk.Label("Working");
        countdown_type.set_halign(Gtk.Align.CENTER);
        countdown_type.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);                        
        countdown_type.hexpand = true;        
                
        var grid_stats = new Gtk.Grid () {
            row_spacing = 5,
            hexpand = true,
            vexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        
        grid_stats.attach(countdown_icon, 0, 0);        
        grid_stats.attach(countdown_time, 0, 1);
        grid_stats.attach(countdown_type, 0, 2);
        
        var grid_actions = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.CENTER,
            hexpand = true,
            spacing = 6
        };
        
        grid_actions.add(close_app);
        grid_actions.add(stop_working);
        
        grid_countdown = new Gtk.Grid() {
            margin = 12,
            margin_top = 10,
            row_spacing = 10,
            hexpand = true
        };
               
        grid_countdown.attach(grid_stats, 0, 0);
        grid_countdown.attach(grid_actions, 0, 1);
    }
    
    private void initialize_hdy_window() {
        hdy_window = new Hdy.Window ();    
        hdy_window.application = this;
        hdy_window.title = ("Ordne");
        hdy_window.add(window_handle);
        hdy_window.set_size_request (600, 500);
        hdy_window.window_position = Gtk.WindowPosition.CENTER;        
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }    
}
