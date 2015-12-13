import Foundation

class DonationManager {

        let threshold_number_of_times_app_did_become_active = 5
        let threshold_time_interval_since_donation_view =  20 //   7 * 24 * 60 * 60
        let threshold_time_interval_since_donation = 8 * 7 * 24 * 60 * 60
        
        let database: Database
        
        var number_of_times_app_did_become_active = 0
        var number_time_app_did_become_active_at_view = 0
        var most_recent_time_donation_view_shown = 0
        var most_recent_time_donation = 0
        
        init(database: Database) {
                self.database = database

                get_all()
                put_all()
        }

        func app_did_become_active() {
                number_of_times_app_did_become_active++
                put(key: "number_of_times_app_did_become_active", value: number_of_times_app_did_become_active)
                if number_of_times_app_did_become_active - number_time_app_did_become_active_at_view < threshold_number_of_times_app_did_become_active {
//                        return
                }
                let now = Int(round(NSDate().timeIntervalSince1970))
                print(now - most_recent_time_donation_view_shown)
                
                if now - most_recent_time_donation_view_shown < threshold_time_interval_since_donation_view {
                        return
                }
                if now - most_recent_time_donation < threshold_time_interval_since_donation {
//                        return
                }
                show_donation_view()
        }
        
        func donation() {
                most_recent_time_donation = Int(round(NSDate().timeIntervalSince1970))
                put(key: "most_recent_time_donation", value: most_recent_time_donation)
        }

        func show_donation_view() {
                number_time_app_did_become_active_at_view = number_of_times_app_did_become_active
                most_recent_time_donation_view_shown = Int(round(NSDate().timeIntervalSince1970))
                put_all()
                if state.render_type == .full_page {
                        state.render_type = .donation_view
                }
        }
        
        func get_all() {
                number_of_times_app_did_become_active = get(key: "number_of_times_app_did_become_active")
                number_time_app_did_become_active_at_view = get(key: "number_time_app_did_become_active_at_view")
                most_recent_time_donation_view_shown = get(key: "most_recent_time_donation_view_shown")
                most_recent_time_donation = get(key: "most_recent_time_donation")
        }

        func put_all() {
                put(key: "number_of_times_app_did_become_active", value: number_of_times_app_did_become_active)
                put(key: "number_time_app_did_become_active_at_view", value: number_time_app_did_become_active_at_view)
                put(key: "most_recent_time_donation_view_shown", value: most_recent_time_donation_view_shown)
                put(key: "most_recent_time_donation", value: most_recent_time_donation)
        }
        
        func get(key key: String) -> Int {
                return Int(sqlite_key_value_select(database: database, key: key) ?? "0") ?? 0
        }
        
        func put(key key: String, value: Int) {
                sqlite_key_value_insert(database: database, key: key, value: String(value))
        }
}
