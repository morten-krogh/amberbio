import Foundation

class DonationManager {

        let threshold_app_did_enter_foreground_counter = 5
        let threshold_time_donation_view =  20 //   7 * 24 * 60 * 60
        let threshold_time_donation = 60 // 8 * 7 * 24 * 60 * 60
        
        let database: Database
        
        var app_did_enter_foreground_counter = 0
        var app_did_enter_foreground_counter_at_view = 0
        var time_donation_view = 0
        var time_donation = 0
        
        let key_app_did_enter_foreground_counter = "app_did_enter_foreground_counter"
        let key_app_did_enter_foreground_counter_at_view = "app_did_enter_foreground_counter_at_view"
        let key_time_donation_view = "time_donation_view"
        let key_time_donation = "time_donation"
        
        init(database: Database) {
                self.database = database

                get_all()
                put_all()
        }

        func app_will_enter_foreground() {
                app_did_enter_foreground_counter++
                put(key: key_app_did_enter_foreground_counter, value: app_did_enter_foreground_counter)
                
                if app_did_enter_foreground_counter - app_did_enter_foreground_counter_at_view < threshold_app_did_enter_foreground_counter {
//                        return
                }
                
                let now = Int(round(NSDate().timeIntervalSince1970))
                
                if now - time_donation_view < threshold_time_donation_view {
//                        return
                }

                if now - time_donation < threshold_time_donation {
//                        return
                }
                
                show_donation_view()
        }
        
        func donation() {
                print("donation")
                time_donation = Int(round(NSDate().timeIntervalSince1970))
                put(key: key_time_donation, value: time_donation)
        }

        func show_donation_view() {
                print("show donation view")
                app_did_enter_foreground_counter_at_view = app_did_enter_foreground_counter
                time_donation_view = Int(round(NSDate().timeIntervalSince1970))
                put_all()
                if state.render_type == .full_page {
                        state.render_type = .donation_view
                }
        }
        
        func get_all() {
                app_did_enter_foreground_counter = get(key: key_app_did_enter_foreground_counter)
                app_did_enter_foreground_counter_at_view = get(key: key_app_did_enter_foreground_counter_at_view)
                time_donation_view = get(key: key_time_donation_view)
                time_donation = get(key: key_time_donation)
        }

        func put_all() {
                put(key: key_app_did_enter_foreground_counter, value: app_did_enter_foreground_counter)
                put(key: key_app_did_enter_foreground_counter_at_view, value: app_did_enter_foreground_counter_at_view)
                put(key: key_time_donation_view, value: time_donation_view)
                put(key: key_time_donation, value: time_donation)
        }
        
        func get(key key: String) -> Int {
                return Int(sqlite_key_value_select(database: database, key: key) ?? "0") ?? 0
        }
        
        func put(key key: String, value: Int) {
                sqlite_key_value_insert(database: database, key: key, value: String(value))
        }
}
