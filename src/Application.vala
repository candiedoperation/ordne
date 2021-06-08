/*
    Ordne
    Copyright (C) 2021  Atheesh Thirumalairajan

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
    Authored By: Atheesh Thirumalairajan <candiedoperation@icloud.com>
*/

public class Application : Gtk.Application {
    private Granite.Widgets.Welcome welcome_page;
    private Granite.Widgets.Welcome stats_page;
    private Granite.Dialog preference_window;
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
    private GLib.Settings settings;
    private int complete_working_duration;
    private int complete_break_duration; 
    private int current_countdown_duration;
    private bool is_working;
    private bool is_count_requested; //Timer Regulator
    
    public Application () {
        Object (
            application_id: "com.github.candiedoperation.ordne",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }    
    
    protected override void activate () {
        Hdy.init (); //Initializing LibHandy
    
        var granite_settings = Granite.Settings.get_default (); //For Auto Dark Mode Toggle
        var gtk_settings = Gtk.Settings.get_default (); //For Auto Dark Mode Toggle
        settings = new GLib.Settings ("com.github.candiedoperation.ordne");    
        
        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
        
        is_count_requested = false;
        is_working = true;
        
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
                break;
            }
            
            case 1: {
                create_prefs_window();                
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
                start_working_countdown();
                break;
            }
            
            case 1: {
                start_break_countdown();            
                break;                
            }
            
            case 2: {
                create_prefs_window();                
                break;
            }
                    
            case 3: {
                hdy_window.destroy();
                break;
            }
        }        
    }
    
    private void start_working_countdown() {
        withdraw_notification ("working-complete");    
    
        current_countdown_duration = (int.parse(settings.get_string("pref-working-duration")) * 60);
        update_timer_label(Granite.DateTime.seconds_to_time(current_countdown_duration));
        
        is_working = true;
        countdown_type.label = "Working";
        stop_working.label = "Stop Working";       
        
        is_count_requested = true;
        start_count_bot();
        
        grid.remove(grid_welcome);
        grid.remove(grid_stats);
        grid.attach(grid_countdown, 0, 1);
        hdy_window.show_all();        
    }
    
    private void start_break_countdown() {
        withdraw_notification ("working-complete");
            
        current_countdown_duration = (int.parse(settings.get_string("pref-break-duration")) * 60);
        update_timer_label(Granite.DateTime.seconds_to_time(current_countdown_duration));

        is_working = false;
        countdown_type.label = "Resting";
        stop_working.label = "End Break";                
        
        is_count_requested = true;   
        start_count_bot();
        
        grid.remove(grid_welcome);
        grid.remove(grid_stats);
        grid.attach(grid_countdown, 0, 1);
        hdy_window.show_all();              
    }
    
    private void start_count_bot() {
        Timeout.add(1000, () => {
            current_countdown_duration--;
            if(current_countdown_duration > 0 && is_count_requested == true) {
                //Update countdown label
                continue_timer_countdown(current_countdown_duration);
                return true;
            } else if(is_count_requested == false) { //Otherwise, end_timer_countdown gets called twice             
                return false;
            } else {
                //Call end timer function
                end_timer_countdown();  
                return false;                
            }
        });        
    }
    
    private void continue_timer_countdown(int time_left) {        
        update_timer_label(Granite.DateTime.seconds_to_time(current_countdown_duration));        
    }
    
    private void end_timer_countdown() {
        is_count_requested = false;
        
        if(current_countdown_duration == 0) {            
            //Update total time by subtracting from stored time
            update_timer_label(Granite.DateTime.seconds_to_time(current_countdown_duration));
            (is_working == true) ? complete_working_duration += (int.parse(settings.get_string("pref-working-duration")) * 60) : complete_break_duration += (int.parse(settings.get_string("pref-break-duration")) * 60); //Update Number of Seconds Worked / Breaked
            
            //Auto Ended, Notify
            ring_notification("Worked " + seconds_human_parser(complete_working_duration) + " | Break " + seconds_human_parser(complete_break_duration));            
        } else {
            //Stop the Timer Loop
            //is_count_requested = false;
            (is_working == true) ? complete_working_duration += ((int.parse(settings.get_string("pref-working-duration")) * 60) - current_countdown_duration) : complete_break_duration += ((int.parse(settings.get_string("pref-break-duration")) * 60) - current_countdown_duration);
        }
        
        stats_page.subtitle = "Work - " + seconds_human_parser(complete_working_duration) + " | Break - " + seconds_human_parser(complete_break_duration);
        
        grid.remove(grid_countdown);
        grid.attach(grid_stats, 0, 1);
        hdy_window.show_all();            
    }
    
    private void update_timer_label(string label_data) {
        countdown_time.label = label_data + " remaining";
    }
    
    private void ring_notification(string notify_body) {
        var action_working = new SimpleAction ("action-working", null);
        action_working.activate.connect(start_working_countdown);
                                
        var action_break = new SimpleAction ("action-break", null);
        action_break.activate.connect(start_break_countdown); 
                
        add_action(action_working);
        add_action(action_break);
        
        Notification notification;
        (is_working == true) ? notification = new Notification ("Working Complete!") : notification = new Notification ("Break Complete!");
        notification.set_body (notify_body);
        notification.set_icon (new ThemedIcon ("process-completed"));
        notification.add_button("Take a Break", "app.action-break");
        notification.add_button("Continue Working", "app.action-working");
        
        if (settings.get_boolean("pref-ring-auto-dismiss") == false) {
            notification.set_priority (NotificationPriority.URGENT);
        } else {
            notification.set_priority (NotificationPriority.NORMAL);
        }        
                    
        send_notification ("working-complete", notification);        
    }
    
    public string seconds_human_parser(int seconds) {
        double day = seconds / (24 * 3600);
        seconds %= (24 * 3600);
        
        double hour = seconds / 3600;
        seconds %= 3600;
        
        double minutes = seconds / 60;
        seconds %= 60;
        
        string human_time = "";
        
        (day == 0) ? human_time += "" : human_time += day.to_string() + "d ";
        (hour == 0) ? human_time += "" : human_time += hour.to_string() + "h ";
        (minutes == 0) ? human_time += "0m " : human_time += minutes.to_string() + "m ";
        (seconds == 0) ? human_time += "0s": human_time += seconds.to_string() + "s";
        
        return human_time;
    }
    
    private void create_welcome_page() {
        welcome_page = new Granite.Widgets.Welcome ("Ordne", "A simple Pomodoro Timer.");
        welcome_page.append ("document-open-recent", "Start Working", "Begin the Working Countdown");
        welcome_page.append ("preferences-system", "Pomodoro Preferences", "Change Break and Working Duration");
        welcome_page.append ("process-stop", "Close", "Close the Application");
        welcome_page.activated.connect (on_welcome_action);  
        
        grid_welcome = new Gtk.Grid ();
        grid_welcome.attach(welcome_page, 0, 1);               
    }
    
    private void create_stats_page() {
        stats_page = new Granite.Widgets.Welcome ("Stats", "Work - 0h 3m 42s | Break - 0h 50m 42s");
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
        stop_working.clicked.connect(end_timer_countdown);       
        
        countdown_icon = new Gtk.Image () {
            gicon = new ThemedIcon ("document-open-recent"),
            pixel_size = 100,
            hexpand = true
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
                
        var grid_status = new Gtk.Grid () {
            row_spacing = 5,
            hexpand = true,
            vexpand = true,
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER
        };
        
        grid_status.attach(countdown_icon, 0, 0);        
        grid_status.attach(countdown_time, 0, 1);
        grid_status.attach(countdown_type, 0, 2);
        
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
               
        grid_countdown.attach(grid_status, 0, 0);
        grid_countdown.attach(grid_actions, 0, 1);
    }
    
    private void create_prefs_window() {
        var working_entry = new Gtk.Entry();
        working_entry.max_length = 3;
        settings.bind ("pref-working-duration", working_entry, "text", GLib.SettingsBindFlags.DEFAULT);        
        
        var break_entry = new Gtk.Entry();
        break_entry.max_length = 3;
        settings.bind ("pref-break-duration", break_entry, "text", GLib.SettingsBindFlags.DEFAULT);         
        
        var notify_switch = new Gtk.Switch();
        notify_switch.hexpand = false;
        notify_switch.set_halign(Gtk.Align.START);
        settings.bind ("pref-ring-auto-dismiss", notify_switch, "active", GLib.SettingsBindFlags.DEFAULT);        
        
        var working_label = new Gtk.Label("Working Duration (in minutes)");
        working_label.set_halign(Gtk.Align.START);
        working_label.hexpand = true;
        
        var break_label = new Gtk.Label("Break Duration (in minutes)");
        break_label.set_halign(Gtk.Align.START);
        break_label.hexpand = true;
        
        var notify_label = new Gtk.Label("Auto Dismiss Notification");
        notify_label.set_halign(Gtk.Align.START);
        notify_label.hexpand = true;                        
        
        var grid_prefs = new Gtk.Grid () {
            row_spacing = 12,
            column_spacing = 10,
            margin = 10,
            vexpand = true
        };
        
        grid_prefs.attach(working_label, 0, 1);
        grid_prefs.attach(working_entry, 1, 1);
        
        grid_prefs.attach(break_label, 0, 2);
        grid_prefs.attach(break_entry, 1, 2);  
        
        grid_prefs.attach(notify_label, 0, 3);
        grid_prefs.attach(notify_switch, 1, 3, 1, 1); //Last two Params to prevent expanding to maintain grid uniformity
        
        preference_window = new Granite.Dialog ();
        preference_window.transient_for = hdy_window;
        preference_window.resizable = false;
        preference_window.set_size_request (400, 350);
        preference_window.get_content_area ().add (grid_prefs);
        
        preference_window.add_button ("Close", Gtk.ResponseType.ACCEPT);        
        preference_window.show_all();
        
        preference_window.response.connect ((response_id) => {
            preference_window.destroy ();
        });        
    }
    
    private void initialize_hdy_window() {
        hdy_window = new Hdy.Window ();    
        hdy_window.application = this;
        hdy_window.resizable = false;
        hdy_window.title = ("Ordne");
        hdy_window.add(window_handle);
        hdy_window.set_size_request (600, 530);
        hdy_window.window_position = Gtk.WindowPosition.CENTER;        
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }    
}
