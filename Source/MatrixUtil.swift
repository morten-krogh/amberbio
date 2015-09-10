import Foundation

func missing_values_for_columns(matrix matrix: [Double], number_of_rows: Int, number_of_columns: Int) -> [Int] {
        var missing_values = [Int](count: number_of_columns, repeatedValue: 0)
        for i in 0 ..< number_of_rows {
                for j in 0 ..< number_of_columns {
                        if matrix[i * number_of_columns + j].isNaN {
                                missing_values[j]++
                        }
                }
        }
        return missing_values
}

func missing_values_for_rows(matrix matrix: [Double], number_of_rows: Int, number_of_columns: Int) -> [Int] {
        var missing_values = [Int](count: number_of_rows, repeatedValue: 0)
        for i in 0 ..< number_of_rows {
                for j in 0 ..< number_of_columns {
                        if matrix[i * number_of_columns + j].isNaN {
                                missing_values[i]++
                        }
                }
        }
        return missing_values
}
