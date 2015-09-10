import Foundation

func chi_square_table_statistics(values1 values1: [Int], values2: [Int]) -> (indices1: [Int: Int], indices2: [Int: Int], total1: [Int], total2: [Int], total: Int, observed: [[Int]], expected: [[Double]], chi_square_statistic: Double, p_value: Double) {

        let total = values1.count

        var indices1 = [:] as [Int: Int]
        var indices2 = [:] as [Int: Int]

        for i in 0 ..< values1.count {
                let value1 = values1[i]
                if indices1[value1] == nil {
                        indices1[value1] = indices1.count
                }

                let value2 = values2[i]
                if indices2[value2] == nil {
                        indices2[value2] = indices2.count
                }
        }

        var total1 = [Int](count: indices1.count, repeatedValue: 0)
        var total2 = [Int](count: indices2.count, repeatedValue: 0)
        var observed = [[Int]](count: indices1.count, repeatedValue: [Int](count: indices2.count, repeatedValue: 0))

        for i in 0 ..< values1.count {
                let index1 = indices1[values1[i]]!
                let index2 = indices2[values2[i]]!
                total1[index1]++
                total2[index2]++
                observed[index1][index2]++
        }

        var expected = [[Double]](count: indices1.count, repeatedValue: [Double](count: indices2.count, repeatedValue: 0))

        for i in 0 ..< indices1.count {
                for j in 0 ..< indices2.count {
                        expected[i][j] = Double(total1[i]) * Double(total2[j]) / Double(total)
                }
        }

        let chi_square_statistic = calculate_chi_square_statistic(observed: observed, expected: expected)

        let degrees_of_freedom = (indices1.count - 1) * (indices2.count - 1)
        let p_value = Double(ChiSquare.chiSquareProbabilityUpperTail(degreesOfFreedom: Double(degrees_of_freedom), quantile: Double(chi_square_statistic)))


        return (indices1, indices2, total1, total2, total, observed, expected, chi_square_statistic, p_value)
}

func calculate_chi_square_statistic(observed observed: [[Int]], expected: [[Double]]) -> Double {
        var statistic = 0 as Double
        for i in 0 ..< observed.count {
                for j in 0 ..< observed[0].count {
                        let observed_number = Double(observed[i][j])
                        let expected_number = expected[i][j]
                        statistic += pow(observed_number - expected_number, 2) / expected_number
                }
        }
        return statistic
}