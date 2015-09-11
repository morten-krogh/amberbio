import Foundation

func make_database() {
        let database_file_name = "amberbio-main.sqlite"
        let database_path = file_app_directory_url(file_name: database_file_name).path!

        var database: Database!

        do { try NSFileManager.defaultManager().removeItemAtPath(database_path) } catch _ { }

        database = sqlite_open(database_path: database_path)

        sqlite_begin(database: database)
        sqlite_tables(database: database)
        sqlite_triggers(database: database)
        sqlite_indices(database: database)
        sqlite_set_info(database: database, version: database_info_version, type: database_main_info_type)
        sqlite_end(database: database)

        database_populate(database: database)

        print(database_path)
}
