import Foundation

class PCAaxis {

        let values: [Double]
        let min_value: Double
        let max_value: Double

        let tick_values: [Double]

        init(values: [Double]) {
                self.values = values
                let (min_value, max_value) = math_min_max(numbers: values)
                self.min_value = min_value < 0 ? min_value : -1
                self.max_value = max_value > 0 ? max_value : 1

                let max_abs_value = max(-min_value, max_value)
                let positive_tick_values = math_pca_tick_values(value: max_abs_value)
                var tick_values = [] as [Double]
                for positive_tick_value in positive_tick_values {
                        if -positive_tick_value > min_value {
                                tick_values.append(-positive_tick_value)
                        }
                }
                for positive_tick_value in positive_tick_values {
                        if positive_tick_value < max_value {
                                tick_values.append(positive_tick_value)
                        }
                }
                self.tick_values = tick_values
        }

        func value_to_unit_interval(value value: Double) -> Double {
                return (value - min_value) / (min_value + max_value)
        }
}
