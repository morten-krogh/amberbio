import Foundation

class DonationManager {

        let database: Database
        
        var number_of_times_app_did_become_active = 0
        var number_of_times_app_did_beome_active_at_view = 0
        var most_recent_time_app_did_become_active = NSDate()
        var most_recent_time_show_donation_view = NSDate()
        var most_recent_time_donation: NSDate?
        
        init() {
                database = state.database
                
                if let value = get(key: "number_of_times_app_did_become_active") {
                        number_of_times_app_did_become_active = Int(value) ?? 0
                } else {
                        put(key: "number_of_times_app_did_become_active", value: 0)
                }
                
                
                
                
                
        }
        
        
        
        
        
        
        
        
        
        
        
        func get(key key: String) -> String? {
                return sqlite_key_value_select(database: database, key: key)
        }
        
        func put(key key: String, value: String) {
                sqlite_key_value_insert(database: database, key: key, value: value)
        }
}
