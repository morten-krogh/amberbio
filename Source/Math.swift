import Foundation

func math_min_max(numbers numbers: [Double]) -> (min: Double, max: Double) {
        var min = Double.infinity
        var max = -Double.infinity
        for number in numbers {
                if number < min {
                        min = number
                }
                if number > max {
                        max = number
                }
        }
        return (min, max)
}

func math_round_to_power_of_ten(number number: Double) -> Double {
        if number == 0 {
                return 0
        }
        if number < 0 {
                return -math_round_to_power_of_ten(number: -number)
        }

        let log_value = log10(number)
        let exponent = floor(log_value)
        return pow(10, exponent)
}

func math_tick_values_positive(number number: Double) -> [Double] {
        let power_of_ten = math_round_to_power_of_ten(number: number)
        var tick_values = [] as [Double]
        if power_of_ten == 0 {
                return tick_values
        }
        let max_ratio = number / power_of_ten
        let ratios: [Int]
        if max_ratio < 2 {
                ratios = [1]
        } else if max_ratio < 3 {
                ratios = [1, 2]
        } else if max_ratio < 4 {
                ratios = [1, 2, 3]
        } else if max_ratio < 5 {
                ratios = [2, 4]
        } else if max_ratio < 6 {
                ratios = [2, 4]
        } else if max_ratio < 8 {
                ratios = [3, 6]
        } else {
                ratios = [4, 8]
        }

        for ratio in ratios {
                let value = Double(ratio) * power_of_ten
                tick_values.append(value)
        }
        return tick_values
}

func math_tick_values_interval(lower lower: Double, upper: Double) -> [Double] {
        let max_number = max(lower, upper)
        let power_of_ten = math_round_to_power_of_ten(number: max_number)
        var tick_values = [] as [Double]
        for i in -9 ..< 10 {
                let value = Double(i) * power_of_ten
                if value >= lower && value <= upper {
                        tick_values.append(value)
                }
        }
        return tick_values
}

func math_pca_tick_values(value value: Double) -> [Double] {
        let power_of_ten = math_round_to_power_of_ten(number: value)
        if value < 2 * power_of_ten {
                return [0.5 * power_of_ten, power_of_ten]
        } else if value < 3 * power_of_ten {
                return [power_of_ten, 2 * power_of_ten]
        } else if value < 4 * power_of_ten {
                return [power_of_ten, 3 * power_of_ten]
        } else if value < 6 * power_of_ten {
                return [2 * power_of_ten, 4 * power_of_ten]
        } else if value < 8 * power_of_ten {
                return [3 * power_of_ten, 6 * power_of_ten]
        } else {
                return [4 * power_of_ten, 8 * power_of_ten]
        }
}
