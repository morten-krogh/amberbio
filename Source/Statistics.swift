import Foundation

func stat_remove_mising_values(values values: [Double]) -> [Double] {
        return values.filter{ !$0.isNaN }
}

func stat_number_of_present_values(values values: [Double]) -> Int {
        var count = 0
        for value in values {
                if !value.isNaN {
                        count++
                }
        }
        return count
}

func stat_mean(values values: [Double]) -> Double {
        var sum = 0 as Double
        var count = 0
        for value in values {
                if !value.isNaN {
                        count++
                        sum += value
                }
        }
        return count == 0 ? Double.NaN : sum / Double(count)
}

func stat_subtract_mean(values values: [Double]) -> [Double] {
        let mean = stat_mean(values: values)
        if mean.isNaN {
                return values
        }
        var values_subtracted = [Double](count: values.count, repeatedValue: Double.NaN)
        for i in 0 ..< values.count {
                if !values[i].isNaN  {
                        values_subtracted[i] = values[i] - mean
                }
        }
        return values_subtracted
}

func stat_variance(values values: [Double]) -> Double {
        let count = stat_number_of_present_values(values: values)
        if count < 2 {
                return Double.NaN
        }

        let mean = stat_mean(values: values)
        var sum_of_square_deviations = 0 as Double
        for value in values {
                if !value.isNaN {
                        let deviation = value - mean
                        sum_of_square_deviations += deviation * deviation
                }
        }

        return sum_of_square_deviations / Double(count - 1)
}

func stat_standard_deviation(values values: [Double]) -> Double {
        let variance = stat_variance(values: values)
        return variance.isNaN ? Double.NaN : sqrt(variance)
}

func stat_false_discovery_rate(p_values p_values: [Double]) -> [Double] {
        let sortedIndices = [Int](0 ..< p_values.count).sort({
                let p_value0 = p_values[$0]
                let p_value1 = p_values[$1]
                return p_value1.isNaN || p_value0 <= p_value1
        })

        var false_discovery_rates = [Double](count: p_values.count, repeatedValue: Double.NaN)

        var numberOfPresentValues = 0
        for p_value in p_values {
                if !p_value.isNaN {
                        numberOfPresentValues++
                }
        }

        var minimum = 1 as Double

        for var i = numberOfPresentValues - 1; i >= 0; --i {
                let index = sortedIndices[i]
                let p_value = p_values[index]
                let qValue = p_value * Double(numberOfPresentValues) / Double(i + 1)
                if qValue < minimum {
                        minimum = qValue
                }
                false_discovery_rates[index] = minimum
        }

        return false_discovery_rates
}

func stat_t_test(values values: [Double]) -> (t_statistic: Double, p_value: Double) {
        if values.count < 2 {
                return (Double.NaN, Double.NaN)
        }

        let standard_deviation = stat_standard_deviation(values: values)
        let mean_value = stat_mean(values: values)
        let degrees_of_freedom = values.count - 1
        let t_statistics = mean_value / (standard_deviation / sqrt(Double(values.count)))
        let quantile = abs(Double(t_statistics))
        let p_value = Double(2.0 * distribution_t_upper_tail(degrees_of_freedom, quantile))

        return (t_statistics, p_value)
}

func stat_t_test(values1 values1: [Double], values2: [Double]) -> (t_statistic: Double, p_value: Double) {
        let degrees_of_freedom = values1.count + values2.count - 2

        if values1.count < 1 || values2.count < 1 || degrees_of_freedom < 1 {
                return (Double.NaN, Double.NaN)
        }

        let mean1 = stat_mean(values: values1)
        let mean2 = stat_mean(values: values2)
        let mean_difference = mean1 - mean2

        var sum_of_squares = 0 as Double
        for value in values1 {
                let deviation = value - mean1
                sum_of_squares += deviation * deviation
        }
        for value in values2 {
                let deviation = value - mean2
                sum_of_squares += deviation * deviation
        }
        let variance = sum_of_squares / Double(degrees_of_freedom)

        if variance == 0 {
                if mean_difference == 0 {
                        return (Double.NaN, Double.NaN)
                } else {
                        return (Double.NaN, 0)
                }
        }

        let reciprocal_number = 1 / Double(values1.count) + 1 / Double(values2.count)
        let t_statistic = mean_difference / (sqrt(variance) * sqrt(reciprocal_number))
        let quantile = abs(Double(t_statistic))
        let p_value = Double(2.0 * distribution_t_upper_tail(degrees_of_freedom, quantile))

        return (t_statistic, p_value)
}

func stat_anova(values values: [[Double]]) -> (f_statistics: Double, p_value: Double) {

        var total_sum = 0 as Double
        var total_count = 0
        var counts = [] as [Int]
        var mean_values = [] as [Double]
        var degrees_of_freedom_between = -1

        for i in 0 ..< values.count {
                var count = 0
                var sum = 0 as Double
                for j in 0 ..< values[i].count {
                        let value = values[i][j]
                        if !value.isNaN {
                                count++
                                sum += value
                        }
                }
                total_sum += sum
                total_count += count
                counts.append(count)
                let mean_value = count == 0 ? Double.NaN : sum / Double(count)
                mean_values.append(mean_value)
                if count > 0 {
                        degrees_of_freedom_between++
                }
        }

        let degrees_of_freedom_within = total_count - 1 - degrees_of_freedom_between

        if degrees_of_freedom_between < 1 || degrees_of_freedom_within < 1 {
                return (Double.NaN, Double.NaN)
        }

        let total_mean = total_sum / Double(total_count)

        var sum_of_squares_between = 0 as Double
        for i in 0 ..< values.count {
                if counts[i] > 0 {
                        let deviation = mean_values[i] - total_mean
                        sum_of_squares_between += Double(counts[i]) * deviation * deviation
                }
        }

        let mean_square_between = sum_of_squares_between / Double(degrees_of_freedom_between)

        var sum_of_squares_within = 0 as Double

        for i in 0 ..< values.count {
                if counts[i] > 0 {
                        for j in 0 ..< values[i].count {
                                let value = values[i][j]
                                if !value.isNaN {
                                        let deviation = value - mean_values[i]
                                        sum_of_squares_within += deviation * deviation
                                }
                        }
                }
        }

        let mean_square_within = sum_of_squares_within / Double(degrees_of_freedom_within)

        if mean_square_within == 0 {
                return (Double.NaN, Double.NaN)
        }

        let f_statistic = mean_square_between / mean_square_within
        let p_value = distribution_f_upper_tail(degrees_of_freedom_between, degrees_of_freedom_within, Double(f_statistic))

        return (f_statistic, Double(p_value))
}
