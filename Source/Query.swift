import Foundation

class Query {

        let statement: String
        let bind_texts: [String]
        let bind_integers: [Int]
        let bind_blobs: [NSData]
        let result_types: [String]

        var result_texts = [] as [[String]]
        var result_integers = [] as [[Int]]
        var result_datas = [] as [[NSData]]

        init(statement: String, bind_texts: [String] = [], bind_integers: [Int] = [], bind_blobs: [NSData] = [], result_types: [String] = []) {
                self.statement = statement
                self.bind_texts = bind_texts
                self.bind_integers = bind_integers
                self.bind_blobs = bind_blobs
                self.result_types = result_types
        }
}
