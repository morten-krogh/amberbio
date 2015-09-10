import Foundation

typealias Database = COpaquePointer
typealias SQLitePreparedStatement = COpaquePointer

internal let SQLITE_STATIC = unsafeBitCast(COpaquePointer(bitPattern: 0), sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(COpaquePointer(bitPattern: -1), sqlite3_destructor_type.self)

//let SQLITE_STATIC = sqlite3_destructor_type(COpaquePointer(bitPattern: 0))
//let SQLITE_TRANSIENT = sqlite3_destructor_type(COpaquePointer(bitPattern: -1))

func sqlite_open(database_path database_path: String) -> Database? {
        var database = nil as Database
        if sqlite3_open(database_path, &database) == SQLITE_OK {
                sqlite3_exec(database, "pragma foreign_keys = on;", nil, nil, nil)
                return database
        } else {
                return nil
        }
}

func sqlite_close(database database: Database) {
        sqlite3_close(database)
}

func sqlite_begin(database database: Database) {
        sqlite3_exec(database, "begin transaction;", nil, nil, nil)
}

func sqlite_end(database database: Database) {
        sqlite3_exec(database, "end transaction;", nil, nil, nil)
}

func sqlite_execute(database database: Database, queries: [Query]) {
        for query in queries {
                sqlite_execute(database: database, query: query)
        }
}

func sqlite_execute(database database: Database, query: Query) {

        var preparedStatement = nil as SQLitePreparedStatement
        if sqlite3_prepare_v2(database, query.statement, -1, &preparedStatement, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(database))
                print("error preparing insert: \(errmsg) in statement: \(query.statement)")
        }

        for i in 0 ..< query.bind_texts.count {
                let bindParameter = ":text\(i)".cStringUsingEncoding(NSUTF8StringEncoding)!
                let index = sqlite3_bind_parameter_index(preparedStatement, bindParameter) as CInt
                let text = query.bind_texts[i].cStringUsingEncoding(NSUTF8StringEncoding)!
                sqlite3_bind_text(preparedStatement, index, text, -1, SQLITE_TRANSIENT)
        }

        for i in 0 ..< query.bind_integers.count {
                let bindParameter = ":integer\(i)".cStringUsingEncoding(NSUTF8StringEncoding)!
                let index = sqlite3_bind_parameter_index(preparedStatement, bindParameter) as CInt
                let integer = CLongLong(query.bind_integers[i])
                sqlite3_bind_int64(preparedStatement, index, integer)
        }

        for i in 0 ..< query.bind_blobs.count {
                let bindParameter = ":blob\(i)".cStringUsingEncoding(NSUTF8StringEncoding)!
                let index = sqlite3_bind_parameter_index(preparedStatement, bindParameter) as CInt
                let data = query.bind_blobs[i]
                let length = CInt(data.length)
                sqlite3_bind_blob(preparedStatement, index, data.bytes, length, SQLITE_TRANSIENT)
        }

        query.result_texts = [[String]](count: query.result_types.filter({ $0 == "text"}).count, repeatedValue: [] as [String])
        query.result_integers = [[Int]](count: query.result_types.filter({ $0 == "integer"}).count, repeatedValue: [] as [Int])
        query.result_datas = [[NSData]](count: query.result_types.filter({ $0 == "data"}).count, repeatedValue: [] as [NSData])

        while sqlite3_step(preparedStatement) == SQLITE_ROW {
                var textColumnCounter = 0
                var integerColumnCounter = 0
                var dataColumnCounter = 0
                for i in 0 ..< query.result_types.count {
                        if query.result_types[i] == "text" {
                                let c_string = sqlite3_column_text(preparedStatement, CInt(i))
                                let string = String.fromCString(UnsafePointer<Int8>(c_string))!
                                query.result_texts[textColumnCounter].append(string)
                                textColumnCounter++
                        } else if query.result_types[i] == "integer" {
                                let integer = sqlite3_column_int64(preparedStatement, CInt(i)) as CLongLong
                                query.result_integers[integerColumnCounter].append(Int(integer))
                                integerColumnCounter++
                        } else if query.result_types[i] == "data" {
                                let blobLength = Int(sqlite3_column_bytes(preparedStatement, CInt(i)))
                                let blob = sqlite3_column_blob(preparedStatement, CInt(i)) as UnsafePointer<Void>
                                let data = NSData(bytes: blob, length: blobLength)
                                query.result_datas[dataColumnCounter].append(data)
                                dataColumnCounter++
                        }
                }
        }

        sqlite3_finalize(preparedStatement)
}

func sqlite_last_insert_rowid(database database: Database) -> Int {
        let statement = "select last_insert_rowid()"
        let query = Query(statement: statement, result_types: ["integer"])
        sqlite_execute(database: database, query: query)
        return query.result_integers[0][0]
}
