import Foundation

func sqlite_triggers(database database: Database) {
        var queries = [] as [Query]
        var statement: String

        func query_append(statement: String) {
                queries.append(Query(statement: statement))
        }

        // file
        query_append("create trigger file_delete after delete on file begin delete from file_data where file_data_id = old.file_data_id; delete from file_data_set where file_id = old.file_id; end")

        // project
        query_append("create trigger project_delete after delete on project begin delete from data_set where project_id = old.project_id; delete from factor where project_id = old.project_id; delete from molecule_annotation where project_id = old.project_id; delete from project_note where project_id = old.project_id; end")

        // data_set
        query_append("create trigger data_set_delete after delete on data_set begin delete from data_set_data where data_set_data_id = old.data_set_data_id; delete from file_data_set where data_set_id = old.data_set_id; delete from active_data_set where data_set_id = old.data_set_id; end")

        // file_data_set
        query_append("create trigger file_data_set_delete after delete on file_data_set begin delete from file where file_id = old.file_id; end")

        // factor
        query_append("create trigger factor_delete after delete on factor begin delete from level where factor_id = old.factor_id; end")

        // level
        query_append("create trigger level_delete after delete on level begin delete from sample_level where level_id = old.level_id; end")

        // sample
        query_append("create trigger sample_delete after delete on sample begin delete from sample_level where sample_id = old.sample_id; end")

        sqlite_execute(database: database, queries: queries)
}
