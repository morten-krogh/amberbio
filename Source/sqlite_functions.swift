import Foundation

func sqlite_update_project_guid(database database: Database, project_id: Int, project_guid: String) {
        let statement = "update project set project_guid = :text0 where project_id = :integer0"
        let query = Query(statement: statement, bind_texts: [project_guid], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
}

func sqlite_get_store_product_ids(database database: Database) -> [String] {
        let statement = "select store_product_product_id from store_product"
        let query = Query(statement: statement, result_types: ["text"])
        sqlite_execute(database: database, query: query)
        return query.result_texts[0]
}

func sqlite_insert_store_product_id(database database: Database, store_product_id: String) {
        let statement = "insert into store_product (store_product_product_id) values (:text0)"
        let query = Query(statement: statement, bind_texts: [store_product_id])
        sqlite_execute(database: database, query: query)
}

func sqlite_get_info(database database: Database) -> (version: Int, type: String)? {
        let statement = "select version, type from info"
        let query = Query(statement: statement, result_types: ["integer", "text"])
        sqlite_execute(database: database, query: query)
        return query.result_integers[0].isEmpty ? nil : (query.result_integers[0][0], query.result_texts[0][0])
}

func sqlite_set_info(database database: Database, version: Int, type: String) {
        let statement = "insert or replace into info (info_id, version, type) values (1, :integer0, :text0)"
        let query = Query(statement: statement, bind_texts: [type], bind_integers: [version])
        sqlite_execute(database: database, query: query)
}

func sqlite_copy_project(source_database source_database: Database, destination_database: Database, source_project_id: Int) -> Int {

        var statement = "select project_guid, project_name, project_date_of_creation from project where project_id = :integer0"
        var query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["text", "text", "text"])
        sqlite_execute(database: source_database, query: query)
        let (project_guid, project_name, project_date_of_creation) = (query.result_texts[0][0], query.result_texts[1][0], query.result_texts[2][0])

        statement = "insert into project (project_guid, project_name, project_date_of_creation) values (:text0, :text1, :text2)"
        query = Query(statement: statement, bind_texts: [project_guid, project_name, project_date_of_creation])
        sqlite_execute(database: destination_database, query: query)
        let destination_project_id = sqlite_last_insert_rowid(database: destination_database)

        statement = "select project_note_date, project_note_text, project_note_type, project_note_user_name from project_note where project_id = :integer0 order by project_note_date"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["text", "text", "text", "text"])
        sqlite_execute(database: source_database, query: query)
        let (project_note_dates, project_note_texts, project_note_types, project_note_user_names) = (query.result_texts[0], query.result_texts[1], query.result_texts[2], query.result_texts[3])

        statement = "insert into project_note (project_note_date, project_note_text, project_note_type, project_note_user_name, project_id) values (:text0, :text1, :text2, :text3, :integer0)"
        for i in 0 ..< project_note_dates.count {
                query = Query(statement: statement, bind_texts: [project_note_dates[i], project_note_texts[i], project_note_types[i], project_note_user_names[i]], bind_integers: [destination_project_id])
                sqlite_execute(database: destination_database, query: query)
        }

        statement = "select factor_id, factor_name, factor_date_of_change from factor where project_id = :integer0 order by factor_id"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["integer", "text", "text"])
        sqlite_execute(database: source_database, query: query)
        let (source_factor_ids, factor_names, factor_date_of_changes) = (query.result_integers[0], query.result_texts[0], query.result_texts[1])

        var destination_factor_ids = [] as [Int]
        statement = "insert into factor (factor_name, factor_date_of_change, project_id) values (:text0, :text1, :integer0)"
        for i in 0 ..< source_factor_ids.count {
                query = Query(statement: statement, bind_texts: [factor_names[i], factor_date_of_changes[i]], bind_integers: [destination_project_id])
                sqlite_execute(database: destination_database, query: query)
                let destination_factor_id = sqlite_last_insert_rowid(database: destination_database)
                destination_factor_ids.append(destination_factor_id)
        }

        statement = "select data_set_id, data_set_guid, data_set_name, data_set_date_of_creation, data_set_data_id, data_set_sample_ids, data_set_molecule_indices from data_set where project_id = :integer0 order by data_set_id"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["integer", "text", "text", "text", "integer", "data", "data"])
        sqlite_execute(database: source_database, query: query)
        let (source_data_set_ids, data_set_guids, data_set_names, data_set_date_of_creations, source_data_set_data_ids, source_data_set_sample_ids_array, data_set_molecule_indices_array) = (query.result_integers[0], query.result_texts[0], query.result_texts[1], query.result_texts[2], query.result_integers[1], query.result_datas[0], query.result_datas[1])

        var destination_data_set_data_ids = [] as [Int]
        for data_set_data_id in source_data_set_data_ids {
                statement = "select data_set_bytes from data_set_data where data_set_data_id = :integer0"
                query = Query(statement: statement, bind_integers: [data_set_data_id], result_types: ["data"])
                sqlite_execute(database: source_database, query: query)
                let data_set_bytes = query.result_datas[0][0]

                statement = "insert into data_set_data (data_set_bytes) values (:blob0)"
                query = Query(statement: statement, bind_blobs: [data_set_bytes])
                sqlite_execute(database: destination_database, query: query)
                let destination_data_set_data_id = sqlite_last_insert_rowid(database: destination_database)
                destination_data_set_data_ids.append(destination_data_set_data_id)
        }

        var source_sample_id_set = [] as Set<Int>
        for data in source_data_set_sample_ids_array {
                let sample_ids = deserialize_integers(data: data)
                for sample_id in sample_ids {
                        source_sample_id_set.insert(sample_id)
                }
        }

        let source_sample_ids = [Int](source_sample_id_set).sort()
        var source_sample_id_to_destination_sample_id = [:] as [Int: Int]
        for source_sample_id in source_sample_ids {
                statement = "select sample_name from sample where sample_id = :integer0"
                query = Query(statement: statement, bind_integers: [source_sample_id], result_types: ["text"])
                sqlite_execute(database: source_database, query: query)
                let sample_name = query.result_texts[0][0]

                statement = "insert into sample (sample_name) values (:text0)"
                query = Query(statement: statement, bind_texts: [sample_name])
                sqlite_execute(database: destination_database, query: query)
                let destination_sample_id = sqlite_last_insert_rowid(database: destination_database)
                source_sample_id_to_destination_sample_id[source_sample_id] = destination_sample_id
        }

        for i in 0 ..< source_factor_ids.count {
                let source_factor_id = source_factor_ids[i]
                let destination_factor_id = destination_factor_ids[i]

                statement = "select level_id, level_name, level_color from level where factor_id = :integer0 order by level_id"
                query = Query(statement: statement, bind_integers: [source_factor_id], result_types: ["integer", "text", "text"])
                sqlite_execute(database: source_database, query: query)
                let (source_level_ids, level_names, level_colors) = (query.result_integers[0], query.result_texts[0], query.result_texts[1])

                var destination_level_ids = [] as [Int]
                statement = "insert into level (level_name, level_color, factor_id) values (:text0, :text1, :integer0)"
                for i in 0 ..< source_level_ids.count {
                        query = Query(statement: statement, bind_texts: [level_names[i], level_colors[i]], bind_integers: [destination_factor_id])
                        sqlite_execute(database: destination_database, query: query)
                        let destination_level_id = sqlite_last_insert_rowid(database: destination_database)
                        destination_level_ids.append(destination_level_id)
                }

                for i in 0 ..< source_level_ids.count {
                        statement = "select sample_id from sample_level where level_id = :integer0 order by sample_id"
                        query = Query(statement: statement, bind_integers: [source_level_ids[i]], result_types: ["integer"])
                        sqlite_execute(database: source_database, query: query)
                        let source_sample_ids_for_source_level_id = query.result_integers[0]

                        for source_sample_id in source_sample_ids_for_source_level_id {
                                let destination_sample_id = source_sample_id_to_destination_sample_id[source_sample_id]!
                                statement = "insert into sample_level (sample_id, level_id) values (:integer0, :integer1)"
                                query = Query(statement: statement, bind_integers: [destination_sample_id, destination_level_ids[i]])
                                sqlite_execute(database: destination_database, query: query)
                        }
                }
        }

        statement = "insert into data_set (data_set_guid, data_set_name, data_set_date_of_creation, project_id, data_set_data_id, data_set_sample_ids, data_set_molecule_indices) values (:text0, :text1, :text2, :integer0, :integer1, :blob0, :blob1)"
        for i in 0 ..< source_data_set_ids.count {
                let source_sample_ids_data = source_data_set_sample_ids_array[i]
                let source_sample_ids = deserialize_integers(data: source_sample_ids_data)

                let destination_sample_ids = source_sample_ids.map { source_sample_id_to_destination_sample_id[$0]! } as [Int]
                let destination_sample_ids_data = serialize_integers(integers: destination_sample_ids)

                query = Query(statement: statement, bind_texts: [data_set_guids[i], data_set_names[i], data_set_date_of_creations[i]], bind_integers: [destination_project_id, destination_data_set_data_ids[i]], bind_blobs: [destination_sample_ids_data, data_set_molecule_indices_array[i]])
                sqlite_execute(database: destination_database, query: query)
        }

        statement = "select molecule_annotation_name, molecule_annotation_values from molecule_annotation where project_id = :integer0"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["text", "data"])
        sqlite_execute(database: source_database, query: query)
        let (molecule_annotation_names, molecule_annotation_values_array) = (query.result_texts[0], query.result_datas[0])

        statement = "insert into molecule_annotation (project_id, molecule_annotation_name, molecule_annotation_values) values (:integer0, :text0, :blob0)"
        for i in 0 ..< molecule_annotation_names.count {
                query = Query(statement: statement, bind_texts: [molecule_annotation_names[i]], bind_integers: [destination_project_id], bind_blobs: [molecule_annotation_values_array[i]])
                sqlite_execute(database: destination_database, query: query)
        }

        return destination_project_id
}

func sqlite_update_project(source_database source_database: Database, source_project_id: Int, destination_database: Database, destination_project_id: Int) {

        var statement = "select project_note_date, project_note_text, project_note_type, project_note_user_name from project_note where project_id = :integer0 order by project_note_date"
        var query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["text", "text", "text", "text"])
        sqlite_execute(database: source_database, query: query)
        let (source_project_note_dates, source_project_note_texts, source_project_note_types, source_project_note_user_names) = (query.result_texts[0], query.result_texts[1], query.result_texts[2], query.result_texts[3])

        query = Query(statement: statement, bind_integers: [destination_project_id], result_types: ["text", "text", "text", "text"])
        sqlite_execute(database: destination_database, query: query)
        let destination_project_note_texts = query.result_texts[1]

        statement = "insert into project_note (project_note_date, project_note_text, project_note_type, project_note_user_name, project_id) values (:text0, :text1, :text2, :text3, :integer0)"
        let destination_project_note_text_set = Set<String>(destination_project_note_texts)
        for i in 0 ..< source_project_note_texts.count {
                if !destination_project_note_text_set.contains(source_project_note_texts[i]) {
                        query = Query(statement: statement, bind_texts: [source_project_note_dates[i], source_project_note_texts[i], source_project_note_types[i], source_project_note_user_names[i]], bind_integers: [destination_project_id])
                        sqlite_execute(database: destination_database, query: query)
                }
        }

        statement = "select data_set_sample_ids from data_set where project_id = :integer0 order by data_set_date_of_creation limit 1"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["data"])
        sqlite_execute(database: source_database, query: query)
        let source_original_data_set_sample_ids_data = query.result_datas[0][0]
        let source_original_data_set_sample_ids = deserialize_integers(data: source_original_data_set_sample_ids_data)

        query = Query(statement: statement, bind_integers: [destination_project_id], result_types: ["data"])
        sqlite_execute(database: destination_database, query: query)
        let destination_original_data_set_sample_ids_data = query.result_datas[0][0]
        var destination_original_data_set_sample_ids = deserialize_integers(data: destination_original_data_set_sample_ids_data)

        var source_sample_id_to_destination_sample_id = [:] as [Int: Int]
        for i in 0 ..< destination_original_data_set_sample_ids.count {
                source_sample_id_to_destination_sample_id[source_original_data_set_sample_ids[i]] = destination_original_data_set_sample_ids[i]
        }

        statement = "select data_set_id, data_set_guid from data_set where project_id = :integer0"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["integer", "text"])
        sqlite_execute(database: source_database, query: query)
        let (source_data_set_ids, source_data_set_guids) = (query.result_integers[0], query.result_texts[0])

        statement = "select data_set_guid from data_set where project_id = :integer0"
        query = Query(statement: statement, bind_integers: [destination_project_id], result_types: ["text"])
        sqlite_execute(database: destination_database, query: query)
        let destination_data_set_guids = query.result_texts[0]

        let destination_data_set_guid_set = Set<String>(destination_data_set_guids)
        var surplus_source_data_set_ids = [] as [Int]
        for i in 0 ..< source_data_set_ids.count {
                if !destination_data_set_guid_set.contains(source_data_set_guids[i]) {
                        surplus_source_data_set_ids.append(source_data_set_ids[i])
                }
        }

        for source_data_set_id in surplus_source_data_set_ids {
                statement = "select data_set_guid, data_set_name, data_set_date_of_creation, data_set_data_id, data_set_sample_ids, data_set_molecule_indices from data_set where data_set_id = :integer0"
                query = Query(statement: statement, bind_integers: [source_data_set_id], result_types: ["text", "text", "text", "integer", "data", "data"])
                sqlite_execute(database: source_database, query: query)
                let (data_set_guid, data_set_name, data_set_date_of_creation, source_data_set_data_id, source_data_set_sample_ids_data, data_set_molecule_indices_data) = (query.result_texts[0][0], query.result_texts[1][0], query.result_texts[2][0], query.result_integers[0][0], query.result_datas[0][0], query.result_datas[1][0])

                statement = "select data_set_bytes from data_set_data where data_set_data_id = :integer0"
                query = Query(statement: statement, bind_integers: [source_data_set_data_id], result_types: ["data"])
                sqlite_execute(database: source_database, query: query)
                let data_set_bytes = query.result_datas[0][0]

                statement = "insert into data_set_data (data_set_bytes) values (:blob0)"
                query = Query(statement: statement, bind_blobs: [data_set_bytes])
                sqlite_execute(database: destination_database, query: query)
                let destination_data_set_data_id = sqlite_last_insert_rowid(database: destination_database)

                let source_data_set_sample_ids = deserialize_integers(data: source_data_set_sample_ids_data)

                let destination_data_set_sample_ids = source_data_set_sample_ids.map { source_sample_id_to_destination_sample_id[$0]! }
                let destination_data_set_sample_ids_data = serialize_integers(integers: destination_data_set_sample_ids)

                statement = "insert into data_set (data_set_guid, data_set_name, data_set_date_of_creation, project_id, data_set_data_id, data_set_sample_ids, data_set_molecule_indices) values (:text0, :text1, :text2, :integer0, :integer1, :blob0, :blob1)"
                query = Query(statement: statement, bind_texts: [data_set_guid, data_set_name, data_set_date_of_creation], bind_integers: [destination_project_id, destination_data_set_data_id], bind_blobs: [destination_data_set_sample_ids_data, data_set_molecule_indices_data])
                sqlite_execute(database: destination_database, query: query)
        }

        statement = "select factor_id, factor_name, factor_date_of_change from factor where project_id = :integer0 order by factor_id"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["integer", "text", "text"])
        sqlite_execute(database: source_database, query: query)
        let (source_factor_ids, source_factor_names, source_factor_date_of_changes) = (query.result_integers[0], query.result_texts[0], query.result_texts[1])

        statement = "select factor_name from factor where project_id = :integer0"
        query = Query(statement: statement, bind_integers: [destination_project_id], result_types: ["text"])
        sqlite_execute(database: destination_database, query: query)
        let destination_factor_names = query.result_texts[0]
        let destination_factor_name_set = Set<String>(destination_factor_names)

        for i in 0 ..< source_factor_ids.count {
                if !destination_factor_name_set.contains(source_factor_names[i]) {
                        statement = "insert into factor (factor_name, factor_date_of_change, project_id) values (:text0, :text1, :integer0)"
                        query = Query(statement: statement, bind_texts: [source_factor_names[i], source_factor_date_of_changes[i]], bind_integers: [destination_project_id])
                        sqlite_execute(database: destination_database, query: query)
                        let destination_factor_id = sqlite_last_insert_rowid(database: destination_database)

                        statement = "select level_id, level_name, level_color from level where factor_id = :integer0 order by level_id"
                        query = Query(statement: statement, bind_integers: [source_factor_ids[i]], result_types: ["integer", "text", "text"])
                        sqlite_execute(database: source_database, query: query)
                        let (source_level_ids, level_names, level_colors) = (query.result_integers[0], query.result_texts[0], query.result_texts[1])

                        var destination_level_ids = [] as [Int]
                        statement = "insert into level (level_name, level_color, factor_id) values (:text0, :text1, :integer0)"
                        for i in 0 ..< source_level_ids.count {
                                query = Query(statement: statement, bind_texts: [level_names[i], level_colors[i]], bind_integers: [destination_factor_id])
                                sqlite_execute(database: destination_database, query: query)
                                let destination_level_id = sqlite_last_insert_rowid(database: destination_database)
                                destination_level_ids.append(destination_level_id)
                        }

                        for i in 0 ..< source_level_ids.count {
                                statement = "select sample_id from sample_level where level_id = :integer0 order by sample_id"
                                query = Query(statement: statement, bind_integers: [source_level_ids[i]], result_types: ["integer"])
                                sqlite_execute(database: source_database, query: query)
                                let source_sample_ids_for_source_level_id = query.result_integers[0]

                                for source_sample_id in source_sample_ids_for_source_level_id {
                                        let destination_sample_id = source_sample_id_to_destination_sample_id[source_sample_id]!
                                        statement = "insert into sample_level (sample_id, level_id) values (:integer0, :integer1)"
                                        query = Query(statement: statement, bind_integers: [destination_sample_id, destination_level_ids[i]])
                                        sqlite_execute(database: destination_database, query: query)
                                }
                        }
                }
        }

        statement = "select molecule_annotation_name, molecule_annotation_values from molecule_annotation where project_id = :integer0"
        query = Query(statement: statement, bind_integers: [source_project_id], result_types: ["text", "data"])
        sqlite_execute(database: source_database, query: query)
        let (source_molecule_annotation_names, source_molecule_annotation_values_array) = (query.result_texts[0], query.result_datas[0])

        statement = "select molecule_annotation_name from molecule_annotation where project_id = :integer0"
        query = Query(statement: statement, bind_integers: [destination_project_id], result_types: ["text"])
        sqlite_execute(database: destination_database, query: query)
        let destination_molecule_annotation_names = query.result_texts[0]
        let destination_molecule_annotation_name_set = Set<String>(destination_molecule_annotation_names)

        statement = "insert into molecule_annotation (project_id, molecule_annotation_name, molecule_annotation_values) values (:integer0, :text0, :blob0)"
        for i in 0 ..< source_molecule_annotation_names.count {
                if !destination_molecule_annotation_name_set.contains(source_molecule_annotation_names[i]) {
                        query = Query(statement: statement, bind_texts: [source_molecule_annotation_names[i]], bind_integers: [destination_project_id], bind_blobs: [source_molecule_annotation_values_array[i]])
                        sqlite_execute(database: destination_database, query: query)
                }
        }
}

func sqlite_export_project(source_database source_database: Database, destination_database: Database, project_id: Int) {
        sqlite_copy_project(source_database: source_database, destination_database: destination_database, source_project_id: project_id)
}

func sqlite_import_database(source_database source_database: Database, destination_database: Database) -> (new_projects: Int, existing_projects: Int) {
        let statement = "select project_id, project_guid from project"
        var query = Query(statement: statement, result_types: ["integer", "text"])
        sqlite_execute(database: destination_database, query: query)
        let (destination_project_ids, destination_project_guids) = (query.result_integers[0], query.result_texts[0])
        var destination_guid_to_id = [:] as [String: Int]
        for i in 0 ..< destination_project_ids.count {
                destination_guid_to_id[destination_project_guids[i]] = destination_project_ids[i]
        }

        query = Query(statement: statement, result_types: ["integer", "text"])
        sqlite_execute(database: source_database, query: query)
        let (source_project_ids, source_project_guids) = (query.result_integers[0], query.result_texts[0])

        var new_projects = 0
        var existing_projects = 0

        for i in 0 ..< source_project_ids.count {
                if let destination_project_id = destination_guid_to_id[source_project_guids[i]] {
                        existing_projects++
                        sqlite_update_project(source_database: source_database, source_project_id: source_project_ids[i], destination_database: destination_database, destination_project_id: destination_project_id)
                } else {
                        new_projects++
                        sqlite_copy_project(source_database: source_database, destination_database: destination_database, source_project_id: source_project_ids[i])
                }
        }

        return (new_projects, existing_projects)
}
