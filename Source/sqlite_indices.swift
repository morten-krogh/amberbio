import Foundation

func sqlite_indices(database database: Database) {
        var queries = [] as [Query]
        var statement: String

        func query_append(statement: String) {
                queries.append(Query(statement: statement))
        }

        // file
        query_append("create index file_type_index on file(file_type)")
        query_append("create index file_data_id_index on file(file_data_id)")

        // data_set
        query_append("create index data_set_project_id_index on data_set(project_id)")
        query_append("create index data_set_data_set_data_id_index on data_set(data_set_data_id)")

        // file_data_set
        query_append("create index file_data_set_file_id_index on file_data_set(file_id)")
        query_append("create index file_data_set_data_set_id_index on file_data_set(data_set_id)")

        // factor
        query_append("create index factor_project_id_index on factor(project_id)")

        // level
        query_append("create index level_factor_id_index on level(factor_id)")

        // sample_level
        query_append("create index sample_level_sample_id_index on sample_level(sample_id)")
        query_append("create index sample_level_level_id_index on sample_level(level_id)")

        // molecule_annotation
        query_append("create index molecule_annotation_project_id_index on molecule_annotation(project_id)")

        sqlite_execute(database: database, queries: queries)
}
