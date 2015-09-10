import Foundation

class Anova {

        let f_statistics: Double
        let p_value: Double
        let means: [Double]
        let standard_deviations: [Double]
        let number_of_present_values: [Int]
        let number_of_missing_values: [Int]

        init(values: [Double], offset: Int, indices_for_levels: [[Int]]) {
                var values_for_levels = [[Double]](count: indices_for_levels.count, repeatedValue: [])

                for i in 0 ..< indices_for_levels.count {
                        for index in indices_for_levels[i] {
                                let value = values[offset + index]
                                values_for_levels[i].append(value)
                        }
                }

                var means = [Double](count: indices_for_levels.count, repeatedValue: Double.NaN)
                var standard_deviations = [Double](count: indices_for_levels.count, repeatedValue: Double.NaN)
                var number_of_present_values = [Int](count: indices_for_levels.count, repeatedValue: 0)
                var number_of_missing_values = [Int](count: indices_for_levels.count, repeatedValue: 0)

                for i in 0 ..< indices_for_levels.count {
                        let values_for_level = values_for_levels[i]
                        means[i] = stat_mean(values: values_for_level)
                        standard_deviations[i] = stat_standard_deviation(values: values_for_level)
                        var missing = 0
                        for value in values_for_level {
                                if value.isNaN {
                                        missing++
                                }
                        }
                        number_of_present_values[i] = values_for_level.count - missing
                        number_of_missing_values[i] = missing
                }

                self.means = means
                self.standard_deviations = standard_deviations
                self.number_of_present_values = number_of_present_values
                self.number_of_missing_values = number_of_missing_values

                (f_statistics, p_value) = stat_anova(values: values_for_levels)
        }
}
