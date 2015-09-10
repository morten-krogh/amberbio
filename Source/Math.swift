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
        for i in 1 ..< 10 {
                let value = Double(i) * power_of_ten
                if value < number {
                        tick_values.append(value)
                } else {
                        break
                }
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
