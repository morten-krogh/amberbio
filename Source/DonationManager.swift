import Foundation

class DonationManager {

        let database: Database
        
        var number_of_times_app_did_become_active = 0
        var number_time_app_did_become_active_at_view = 0
//        var most_recent_time_app_did_become_active = 0
        var most_recent_time_donation_view_shown = 0
        var most_recent_time_donation = 0
        
        init() {
                database = state.database

                get_all()
                put_all()
        }

        func app_did_become_active() {
                number_of_times_app_did_become_active++
                put_all()
                if number_of_times_app_did_become_active - number_time_app_did_become_active_at_view < 5 {
                        return
                }
                let now = Int(round(NSDate().timeIntervalSince1970))
                if now - most_recent_time_donation_view_shown < 3 * 24 * 3600 {
                        return
                }
                if now - most_recent_time_donation < 60 * 24 * 3600 {
                        return
                }
                show_donation_view()
        }
        
        func donation() {
                
                
                
        }

        func show_donation_view() {
                
        }
        
        func get_all() {
                number_of_times_app_did_become_active = get(key: "number_of_times_app_did_become_active")
                number_time_app_did_become_active_at_view = get(key: "number_time_app_did_become_active_at_view")
//                most_recent_time_app_did_become_active = get(key: "most_recent_time_app_did_become_active")
                most_recent_time_donation_view_shown = get(key: "most_recent_time_donation_view_shown")
                most_recent_time_donation = get(key: "most_recent_time_donation")
        }

        func put_all() {
                put(key: "number_of_times_app_did_become_active", value: number_of_times_app_did_become_active)
                put(key: "number_time_app_did_become_active_at_view", value: number_time_app_did_become_active_at_view)
//                put(key: "most_recent_time_app_did_become_active", value: most_recent_time_app_did_become_active)
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
