import Foundation

func sqlite_views(database database: Database) {
        var queries = [] as [Query]
        var statement: String

        func query_append(statement: String) {
                queries.append(Query(statement: statement))
        }

        // state.project_id_view
        query_append("create view state.project_id_view as select project_id from active_data_set natural join data_set")

        // original_data_set_id
        query_append("create view original_data_set_view as select min(data_set_id) as data_set_id from data_set group by project_id")

        // active data set
        query_append("create view active_data_set_view as select project_id, project_name, data_set_id, data_set_name from active_data_set natural join data_set natural join project")
        query_append("create view active_original_data_set_id_view as select data_set_id from state.project_id_view natural join data_set order by data_set_date_of_creation limit 1")

        // ordered result files in active project
        query_append("create view result_files_in_active_project_view as select data_set_id, data_set_name, file_id, file_name, file_date from state.project_id_view natural join data_set natural join file_data_set natural join file")
        query_append("create view ordered_result_files_in_active_project_view as select data_set_id, data_set_name, file_id, file_name, file_date from result_files_in_active_project_view natural join (select data_set_id, max(file_date) as max_file_date from result_files_in_active_project_view group by data_set_id) order by max_file_date desc, file_date desc")

        sqlite_execute(database: database, queries: queries)
}
