import Foundation

var state: State!
let database_file_name = "bioinformatics.sqlite"
let database_path = path_to_file_in_app_directory(file_name: database_file_name)
let reset_database = false

let initial_active_data_set_id = 5
let initial_page_state = HomeState()

func state_init() {
        //        print(database_path)

        let database_file_exists = file_exists(path: database_path)

        if reset_database && database_file_exists {
                try! NSFileManager.defaultManager().removeItemAtPath(database_path)
        }

        if reset_database || !database_file_exists {
                let bundle_database_path = NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent(database_file_name)
                try! NSFileManager.defaultManager().copyItemAtPath(bundle_database_path, toPath: database_path)
        }

        let database = sqlite_open(database_path: database_path)!

        state = State(database: database, initial_active_data_set_id: initial_active_data_set_id)
        state.set_page_state(page_state: initial_page_state)
}
