import Foundation
import StoreKit

var state: State!
let database_file_name = "amberbio-main.sqlite"
let database_url = file_app_directory_url(file_name: database_file_name)

let reset_database = false
//let initial_active_data_set_id = 1
let initial_page_state = PCAState()

func state_init() {
        //        print(database_path)

        var copy_database_from_bundle = false

        let database_file_exists = file_exists(url: database_url)

        if database_file_exists {
                let database = sqlite_open(database_path: database_url.path!)!
                let (version, _) = sqlite_get_info(database: database) ?? (1, "")
                sqlite_close(database: database)
                if reset_database || version == 1 {
                        try! NSFileManager.defaultManager().removeItemAtURL(database_url)
                        copy_database_from_bundle = true
                }
        } else {
                copy_database_from_bundle = true
        }

        if copy_database_from_bundle {
                if let bundle_database_url = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(database_file_name) {
                        try! NSFileManager.defaultManager().copyItemAtURL(bundle_database_url, toURL: database_url)
                }
        }

        let database = sqlite_open(database_path: database_url.path!)!
//        sqlite_database_main_migrate(database: database)

        state = State(database: database)
        state.set_page_state(page_state: initial_page_state)

        SKPaymentQueue.defaultQueue().addTransactionObserver(state.store)
}
