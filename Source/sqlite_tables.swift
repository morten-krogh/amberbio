import Foundation

let database_info_version = 1
let database_main_info_type = "Amberbio main database"
let database_export_info_type = "Amberbio export database"

let sqlite_create_table_statements = [
        "info": "create table info (info_id integer primary key, version integer, type text)",
        "user": "create table user (user_id integer primary key, user_name text)",
        "email": "create table email (email_id integer primary key, email_address text)",
        "file_data": "create table file_data (file_data_id integer primary key, file_bytes blob)",
        "file": "create table file (file_id integer primary key, file_name text, file_date timestamp default current_timestamp, file_size integer, file_type text, file_data_id integer references file_data)",
        "project": "create table project (project_id integer primary key, project_guid text, project_name text, project_date_of_creation timestamp default current_timestamp)",
        "project_note": "create table project_note (project_note_id integer primary key, project_note_date timestamp default current_timestamp, project_note_text text, project_note_type text, project_note_user_name text, project_id integer references project)",
        "sample": "create table sample (sample_id integer primary key, sample_name text)",
        "factor": "create table factor (factor_id integer primary key, factor_name text, factor_date_of_change timestamp default current_timestamp, project_id integer references project)",
        "level": "create table level (level_id integer primary key, level_name text, level_color text, factor_id integer references factor)",
        "sample_level": "create table sample_level (sample_id integer references sample, level_id references level)",
        "data_set_data": "create table data_set_data (data_set_data_id integer primary key, data_set_bytes blob)",
        "data_set": "create table data_set (data_set_id integer primary key, data_set_guid text, data_set_name text, data_set_date_of_creation timestamp default current_timestamp, project_id integer references project, data_set_data_id integer references data_set_data, data_set_sample_ids blob, data_set_molecule_indices blob)",
        "file_data_set": "create table file_data_set (file_id integer references file, data_set_id integer references data_set)",
        "molecule_annotation": "create table molecule_annotation (project_id integer references project, molecule_annotation_name text, molecule_annotation_values blob)",
        "active_data_set": "create table active_data_set (data_set_id integer references data_set)"
]

let sqlite_create_index_statements = [
        "file_type": "create index file_type_index on file(file_type)",
        "file_data_id": "create index file_data_id_index on file(file_data_id)",
        "data_set_project_id": "create index data_set_project_id_index on data_set(project_id)",
        "data_set_data_id": "create index data_set_data_set_data_id_index on data_set(data_set_data_id)",
        "file_data_set_file_id": "create index file_data_set_file_id_index on file_data_set(file_id)",
        "file_data_set_data_set_id": "create index file_data_set_data_set_id_index on file_data_set(data_set_id)",
        "factor_project_id": "create index factor_project_id_index on factor(project_id)",
        "level_factor_id": "create index level_factor_id_index on level(factor_id)",
        "sample_level_sample_id": "create index sample_level_sample_id_index on sample_level(sample_id)",
        "sample_level_level_id": "create index sample_level_level_id_index on sample_level(level_id)",
        "molecule_annotation_project_id": "create index molecule_annotation_project_id_index on molecule_annotation(project_id)"
]

let sqlite_database_main_1_tables = ["info", "user", "email", "file_data", "file", "project", "project_note", "sample", "factor", "level", "sample_level", "data_set_data", "data_set", "file_data_set", "molecule_annotation", "active_data_set"]

let sqlite_database_main_1_indices = ["file_type", "file_data_id", "data_set_project_id", "data_set_data_id", "file_data_set_file_id", "file_data_set_data_set_id", "factor_project_id", "level_factor_id", "sample_level_sample_id", "sample_level_level_id", "molecule_annotation_project_id"]

func sqlite_database_main_1(database database: Database) {
        for table_name in sqlite_database_main_1_tables {
                let statement = sqlite_create_table_statements[table_name]!
                sqlite_execute(database: database, statement: statement)
        }

        for index_name in sqlite_database_main_1_indices {
                let statement = sqlite_create_index_statements[index_name]!
                sqlite_execute(database: database, statement: statement)
        }
}




func sqlite_exported_tables(database database: Database) {
        var queries = [] as [Query]

        func query_append(statement: String) {
                queries.append(Query(statement: statement))
        }

        // info
        query_append("create table info (info_id integer primary key, version integer, type text)")

        // project
        query_append("create table project (project_id integer primary key, project_guid text, project_name text, project_date_of_creation timestamp default current_timestamp)")

        // project_note
        query_append("create table project_note (project_note_id integer primary key, project_note_date timestamp default current_timestamp, project_note_text text, project_note_type text, project_note_user_name text, project_id integer references project)")

        // sample
        query_append("create table sample (sample_id integer primary key, sample_name text)")

        // factor
        query_append("create table factor (factor_id integer primary key, factor_name text, factor_date_of_change timestamp default current_timestamp, project_id integer references project)")

        // level
        query_append("create table level (level_id integer primary key, level_name text, level_color text, factor_id integer references factor)")

        // sample_level
        query_append("create table sample_level (sample_id integer references sample, level_id references level)")

        // data_set_data
        query_append("create table data_set_data (data_set_data_id integer primary key, data_set_bytes blob)")

        // data_set
        query_append("create table data_set (data_set_id integer primary key, data_set_guid text, data_set_name text, data_set_date_of_creation timestamp default current_timestamp, project_id integer references project, data_set_data_id integer references data_set_data, data_set_sample_ids blob, data_set_molecule_indices blob)")

        // molecule_annotation
        query_append("create table molecule_annotation (project_id integer references project, molecule_annotation_name text, molecule_annotation_values blob)")

        sqlite_execute(database: database, queries: queries)
}
