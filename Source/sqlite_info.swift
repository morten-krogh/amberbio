import Foundation

func sqlite_get_info(database database: Database) -> (version: Int, type: String) {
        let statement = "select version, type from info limit 1"
        let query = Query(statement: statement, result_types: ["integer", "text"])
        sqlite_execute(database: database, query: query)
        return query.result_integers.isEmpty ? (0, "") : (query.result_integers[0][0], query.result_texts[0][0])
}

func sqlite_set_info(database database: Database, version: Int, type: String) {
        let statement = "insert into info (version, type) values (:integer0, :text0)"
        let query = Query(statement: statement, bind_texts: [type], bind_integers: [version])
        sqlite_execute(database: database, query: query)
}
