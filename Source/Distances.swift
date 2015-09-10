import Foundation

func distance_euclidean(values1 values1: [Double], values2: [Double]) -> Double {
        var number_of_missing = 0
        var sum_of_squares = 0 as Double
        for i in 0 ..< values1.count {
                if values1[i].isNaN || values2[i].isNaN {
                        number_of_missing++
                } else {
                        let delta = values1[i] - values2[i]
                        sum_of_squares += delta * delta
                }
        }

        if number_of_missing == values1.count {
                return 0
        } else {
                sum_of_squares = sum_of_squares * Double(values1.count) / Double(values1.count - number_of_missing)
                return sqrt(sum_of_squares)
        }
}

func calculate_correlation(values1 values1: [Double], values2: [Double]) -> Double {
        var sum1 = 0 as Double
        var sum2 = 0 as Double
        var sum_of_squares1 = 0 as Double
        var sum_of_squares2 = 0 as Double
        var sum_of_products = 0 as Double
        for i in 0 ..< values1.count {
                sum1 += values1[i]
                sum2 += values2[i]
                sum_of_squares1 += values1[i] * values1[i]
                sum_of_squares2 += values2[i] * values2[i]
                sum_of_products += values1[i] * values2[i]
        }
        let N = Double(values1.count)
        let correlation_numerator = sum_of_products - sum1 * sum2 / N
        let correlation_denominator = sqrt( (sum_of_squares1 - sum1 * sum1 / N) * (sum_of_squares2 - sum2 * sum2 / N) )
        if correlation_denominator > 0 {
                return correlation_numerator / correlation_denominator
        } else {
                return 0
        }
}

func calculate_correlation_with_missing(values1 values1: [Double], values2: [Double]) -> Double {
        var values_no_missing1 = [] as [Double]
        var values_no_missing2 = [] as [Double]
        for i in 0 ..< values1.count {
                if !values1[i].isNaN && !values2[i].isNaN {
                        values_no_missing1.append(values1[i])
                        values_no_missing2.append(values2[i])
                }
        }
        return calculate_correlation(values1: values_no_missing1, values2: values_no_missing2)
}

func distance_correlation(values1 values1: [Double], values2: [Double]) -> Double {
        let correlation = calculate_correlation(values1: values1, values2: values2)
        return 1 - correlation
}

func distance_correlation_with_missing(values1 values1: [Double], values2: [Double]) -> Double {
        let correlation = calculate_correlation_with_missing(values1: values1, values2: values2)
        return 1 - correlation
}
