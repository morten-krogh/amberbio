import Foundation
import StoreKit

var state: State!
let database_file_name = "amberbio-main.sqlite"
let database_url = file_app_directory_url(file_name: database_file_name)

let reset_database = false
//let initial_active_data_set_id = 1
let initial_page_state = StoreFrontState()

func state_init() {
        //        print(database_path)

        let database_file_exists = file_exists(url: database_url)

//        if reset_database && database_file_exists {
//                try! NSFileManager.defaultManager().removeItemAtURL(database_url)
//        }

        if reset_database || !database_file_exists {
                if let bundle_database_url = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(database_file_name) {
                        try! NSFileManager.defaultManager().copyItemAtURL(bundle_database_url, toURL: database_url)
                }
        }

        let database = sqlite_open(database_path: database_url.path!)!

        state = State(database: database)
        state.set_page_state(page_state: initial_page_state)

        SKPaymentQueue.defaultQueue().addTransactionObserver(state.store)

        state.store.request_products()
}
