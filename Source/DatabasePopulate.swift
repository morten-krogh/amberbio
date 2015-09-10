import Foundation

func set_user_name(database database: Database, user_name: String) {
        let statement = "insert or replace into user (user_id, user_name) values (1, :text0)"
        let query = Query(statement: statement, bind_texts: [user_name])
        sqlite_execute(database: database, query: query)
}

func set_email(database database: Database, email: String) {
        let statement = "insert into email (email_address) values (:text0)"
        let query = Query(statement: statement, bind_texts: [email])
        sqlite_execute(database: database, query: query)
}

func insert_file_data(database database: Database, data: NSData) -> Int {
        let statement = "insert into file_data (file_bytes) values (:blob0)"
        let query = Query(statement: statement, bind_blobs: [data])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_file(database database: Database, name: String, type: String, data: NSData) -> Int {
        let file_data_id = insert_file_data(database: database, data: data)
        let statement = "insert into file (file_name, file_size, file_type, file_data_id) values (:text0, :integer0, :text1, :integer1)"
        let query = Query(statement: statement, bind_texts: [name, type], bind_integers: [data.length, file_data_id])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_samples(database database: Database, sample_names: [String]) -> [Int] {
        let statement = "insert into sample (sample_name) values (:text0)"
        var sample_ids = [] as [Int]
        for i in 0 ..< sample_names.count {
                sqlite_execute(database: database, query: Query(statement: statement, bind_texts: [sample_names[i]]))
                sample_ids.append(sqlite_last_insert_rowid(database: database))
        }
        return sample_ids
}

func insert_molecule_annotation(database database: Database, project_id: Int, molecule_annotation_name: String, molecule_annotation_values: [String]) {
        let statement = "insert into molecule_annotation (project_id, molecule_annotation_name, molecule_annotation_values) values (:integer0, :text0, :blob0)"
        let molecule_annotation_values_serialized = serialize_strings(strings: molecule_annotation_values)
        let query = Query(statement: statement, bind_texts: [molecule_annotation_name], bind_blobs: [molecule_annotation_values_serialized], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
}


func insert_values(database database: Database, values: [Double]) -> Int {
        let data = serialize_doubles(doubles: values)
        let statement = "insert into data_set_data (data_set_bytes) values (:blob0)"
        let query = Query(statement: statement, bind_blobs: [data])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_data_set(database database: Database, data_set_name: String, project_id: Int, values: [Double], sample_ids: [Int], molecule_indices: [Int]) -> Int {
        let data_sample_ids = serialize_integers(integers: sample_ids)
        let data_molecule_indices = serialize_integers(integers: molecule_indices)

        sqlite_begin(database: database)

        let data_set_data_id = insert_values(database: database, values: values)

        let statement_data_set = "insert into data_set (data_set_guid, data_set_name, project_id, data_set_data_id, data_set_sample_ids, data_set_molecule_indices) values ((select lower(hex(randomblob(10)))), :text0, :integer0, :integer1, :blob0, :blob1)"
        let query_data_set = Query(statement: statement_data_set, bind_texts: [data_set_name], bind_blobs: [data_sample_ids, data_molecule_indices], bind_integers: [project_id, data_set_data_id])

        sqlite_execute(database: database, query: query_data_set)
        let data_set_id = sqlite_last_insert_rowid(database: database)

        sqlite_end(database: database)
        
        return data_set_id
}

func insert_factor(database database: Database, factor_name: String, project_id: Int) -> Int {
        let statement = "insert into factor (factor_name, project_id) values (:text0, :integer0)"
        let query = Query(statement: statement, bind_texts: [factor_name], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_level(database database: Database, level_name: String, color: String, factor_id: Int) -> Int {
        let statement = "insert into level (level_name, level_color, factor_id) values (:text0, :text1, :integer0)"
        let query = Query(statement: statement, bind_texts: [level_name, color], bind_integers: [factor_id])
        sqlite_execute(database: database, query: query)
        return sqlite_last_insert_rowid(database: database)
}

func insert_sample_level(database database: Database, sample_id: Int, level_id: Int) {
        let statement = "insert into sample_level (sample_id, level_id) values (:integer0, :integer1)"
        let query = Query(statement: statement, bind_integers: [sample_id, level_id])
        sqlite_execute(database: database, query: query)
}

func insert_factor(database database: Database, project_id: Int, sample_ids: [Int], factor_name: String, level_names_of_samples: [String]) -> Int {
        var level_names = [] as [String]
        var index_of_level_name = [:] as [String: Int]
        var level_set = [] as Set<String>
        for level_name in level_names_of_samples {
                if !level_set.contains(level_name) {
                        index_of_level_name[level_name] = level_names.count
                        level_names.append(level_name)
                        level_set.insert(level_name)
                }
        }

        let colors = color_palette_hex(number_of_colors: level_names.count)

        let factor_id = insert_factor(database: database, factor_name: factor_name, project_id: project_id)

        var level_ids = [] as [Int]
        for i in 0 ..< level_names.count {
                let level_id = insert_level(database: database, level_name: level_names[i], color: colors[i], factor_id: factor_id)
                level_ids.append(level_id)
        }

        for i in 0 ..< sample_ids.count {
                let level_index = index_of_level_name[level_names_of_samples[i]]!
                let level_id = level_ids[level_index]
                insert_sample_level(database: database, sample_id: sample_ids[i], level_id: level_id)
        }

        return factor_id
}

func insert_project_note(database database: Database, project_note_text: String, project_note_type: String, project_note_user_name: String, project_id: Int) {
        let statement = "insert into project_note (project_note_text, project_note_type, project_note_user_name, project_id) values (:text0, :text1, :text2, :integer0)"
        let query = Query(statement: statement, bind_texts: [project_note_text, project_note_type, project_note_user_name], bind_integers: [project_id])
        sqlite_execute(database: database, query: query)
}

func insert_project(database database: Database, project_name: String, data_set_name: String, values: [Double], sample_names: [String], molecule_names: [String], factor_names: [String], level_names_of_samples_array: [[String]], molecule_annotation_names: [String], molecule_annotation_values_array: [[String]], project_note_texts: [String], project_note_types: [String], project_note_user_names: [String]) -> Int {

        let statement_project = "insert into project (project_guid, project_name) values ((select lower(hex(randomblob(10)))), :text0)"
        let query_project = Query(statement: statement_project, bind_texts: [project_name])
        sqlite_execute(database: database, query: query_project)
        let project_id = sqlite_last_insert_rowid(database: database)

        let sample_ids = insert_samples(database: database, sample_names: sample_names)
        insert_molecule_annotation(database: database, project_id: project_id, molecule_annotation_name: "molecule name", molecule_annotation_values: molecule_names)

        let molecule_indices = [Int](0 ..< molecule_names.count)

        insert_data_set(database: database, data_set_name: data_set_name, project_id: project_id, values: values, sample_ids: sample_ids, molecule_indices: molecule_indices)

        for i in 0 ..< factor_names.count {
                insert_factor(database: database, project_id: project_id, sample_ids: sample_ids, factor_name: factor_names[i], level_names_of_samples: level_names_of_samples_array[i])
        }

        for i in 0 ..< molecule_annotation_names.count {
                insert_molecule_annotation(database: database, project_id: project_id, molecule_annotation_name: molecule_annotation_names[i], molecule_annotation_values: molecule_annotation_values_array[i])
        }

        for i in 0 ..< project_note_texts.count {
                insert_project_note(database: database, project_note_text: project_note_texts[i], project_note_type: project_note_types[i], project_note_user_name: project_note_user_names[i], project_id: project_id)
        }

        return project_id
}

func import_data(database database: Database, stem: String, project_name: String, include_factors: Bool = true, include_annotations: Bool = true) -> Int {

        var values = [] as [Double]
        var sample_names = [] as [String]
        var molecule_names = [] as [String]
        var factor_names = [] as [String]
        var level_names_of_samples_array = [] as [[String]]
        var molecule_annotation_names = [] as [String]
        var molecule_annotation_values_array = [] as [[String]]

        let data = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("\(stem)_values", ofType: "txt")!)!
        (sample_names, molecule_names, values, _, _, _) = parse_import_data(data: data, double_values: true)

        if let file_content = NSBundle.mainBundle().pathForResource("\(stem)_annotations", ofType: "txt"), let data = NSData(contentsOfFile: file_content) {
                (molecule_annotation_names, _, _, _, molecule_annotation_values_array, _) = parse_import_data(data: data, double_values: false)
        }

        if let file_content = NSBundle.mainBundle().pathForResource("\(stem)_factors", ofType: "txt"), let data = NSData(contentsOfFile: file_content) {
                var cells = [] as [[String]]

                (_, factor_names, _, _, cells, _) = parse_import_data(data: data, double_values: false)
                for i in 0 ..< factor_names.count {
                        var sample_level_names = [] as [String]
                        for j in 0 ..< cells.count {
                                sample_level_names.append(cells[j][i])
                        }
                        level_names_of_samples_array.append(sample_level_names)
                }
        }

        return insert_project(database: database, project_name: project_name, data_set_name: "Original data set", values: values, sample_names: sample_names, molecule_names: molecule_names, factor_names: factor_names, level_names_of_samples_array: level_names_of_samples_array, molecule_annotation_names: molecule_annotation_names, molecule_annotation_values_array: molecule_annotation_values_array, project_note_texts: [], project_note_types: [], project_note_user_names: [])
}

func database_populate(database database: Database) {

        sqlite_set_info(database: database, version: 1, type: "Amberbio main database")
        set_user_name(database: database, user_name: "Morten Krogh")
        set_email(database: database, email: "m@amberbio.com")

//        let imported_file_data = [
//                "corrupt database".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "dummy\tsample 1\t sample 2\nmolecule 1\t12.3\t-9.8\nmolecule 2\t45.6\t-100.0\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "dummy\tSample 1\tSample 2\tSample 3\ngender\tmale\tfemale\tmale\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "id\tsequence\nMolecule 1\tACGT\nMolecule 2\tCCGG\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "dummy\tsample 1\tsample 2\tsample 3\ncondition\tgood\tbad\tgood\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "id\tfunction\tnetwork\nMolecule 1\tphosphase\tnetwork 1\nMolecule 2\ttranscription factor\t network 2\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "dummy\tsample 1\nmol1\t12.12\t56\t45\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
//                "dummy\tSwiss Prot\nMolecule 2\tSwiss 2\nMolecule 3\t Swiss 3\nMolecule 1\tSwiss 1\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//        ]
//
//        let imported_file_names = [
//                "CorruptDatabase.sqlite",
//                "ExpressionValues1.txt",
//                "Samples3.txt",
//                "Molecules4.txt",
//                "Samples5.txt",
//                "Molecules6.txt",
//                "ExpressionValues7.txt",
//                "Annotations1.txt"
//        ]
//
//        for i in 0 ..< imported_file_data.count {
//                insert_file(database: database, name: imported_file_names[i], type: "imported", data: imported_file_data[i])
//        }
//
//        var project_name = "Project 1"
//        var values = [12.3, -2.3, Double.NaN, 8.9, 3.7, Double.NaN] as [Double]
//        var sample_names = ["Sample 1", "Sample 2", "Sample 3"]
//        var molecule_names = ["Molecule 1", "Molecule 2"]
//        var factor_names = ["Disease", "Gender", "Country", "Hospital"]
//        var level_names_of_samples_array = [
//                ["Diabetes", "Cancer", "Diabetes"],
//                ["Male", "Female", "Female"],
//                ["Denmark", "Sweden", "Iceland"],
//                ["Lund", "Stockholm", "Lund"]
//        ]
//        var molecule_annotation_names = ["Unigene"]
//        var molecule_annotation_values_array = [
//                 ["Unigene 1", "Unigene 2"]
//        ]
//        var project_note_texts = ["Project note 1"]
//        var project_note_types = ["auto"]
//        var project_note_user_names = ["Morten Krogh"]
//
//        insert_project(database: database, project_name: project_name, data_set_name: "Original data set", values: values, sample_names: sample_names, molecule_names: molecule_names,factor_names: factor_names, level_names_of_samples_array: level_names_of_samples_array, molecule_annotation_names: molecule_annotation_names, molecule_annotation_values_array: molecule_annotation_values_array, project_note_texts: project_note_texts, project_note_types: project_note_types, project_note_user_names: project_note_user_names)
//
//        project_name = "Project 2"
//        values = [12.3, -2.3, 4.5, 12.6, 8.9, 3.7, -10.2, -9.8, 67.5, -7.67, 3.4, 19.9, 1.2, 2.3, 3.4, 4.5, 5.6, -6.7, 7.8, -8.9] as [Double]
//        sample_names = ["Sample 1", "Sample 2", "Sample 3", "Sample 4"]
//        molecule_names = ["Molecule 1", "Molecule 2", "Molecule 3", "Molecule 4", "Molecule 5"]
//        factor_names = ["Disease", "Gender", "Country", "Hospital", "Time"]
//        level_names_of_samples_array = [
//                ["Diabetes", "Cancer", "Diabetes", "Cancer"],
//                ["Male", "Female", "Female", "Female"],
//                ["Denmark", "Sweden", "Iceland", "Sweden"],
//                ["Lund", "Stockholm", "Lund", "Copenhagen"],
//                ["1 day", "3 days", "5days", "7 days"]
//        ]
//        molecule_annotation_names = []
//        molecule_annotation_values_array = []
//        project_note_texts = []
//        project_note_types = []
//        project_note_user_names = []
//
//        insert_project(database: database, project_name: project_name, data_set_name: "Original data set", values: values, sample_names: sample_names, molecule_names: molecule_names,factor_names: factor_names, level_names_of_samples_array: level_names_of_samples_array, molecule_annotation_names: molecule_annotation_names, molecule_annotation_values_array: molecule_annotation_values_array, project_note_texts: project_note_texts, project_note_types: project_note_types, project_note_user_names: project_note_user_names)

        import_data(database: database, stem: "iris", project_name: "Iris flowers", include_factors: true, include_annotations: false)
//        import_data(database: database, stem: "brca", project_name: "brca srm")
//        import_data(database: database, stem: "sox", project_name: "sox cell lines")
//        import_data(database: database, stem: "ovarian", project_name: "ovarian cancer")
//        import_data(database: database, stem: "mouse_brain", project_name: "mouse brain")
//        import_data(database: database, stem: "paired", project_name: "paired")
//        import_data(database: database, stem: "xintela", project_name: "xintela", include_factors: false)
//        import_data(database: database, stem: "xintela_special", project_name: "xintela_special", include_factors: false, include_annotations: false)
}
