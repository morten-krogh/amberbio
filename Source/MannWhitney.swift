import Foundation

class MannWhitney {

        let n1_max: Int
        let n2_max: Int
        var frequencies: [[[Int]]]

        init(n1_max: Int, n2_max: Int) {
                self.n1_max = n1_max
                self.n2_max = n2_max

                frequencies = []
                for n1 in 0 ... n1_max {
                        var frequencies1 = [] as [[Int]]
                        for n2 in 0 ... min(n1, n2_max) {
                                let frequencies2 = [Int](count: n1 * n2 / 2 + 1, repeatedValue: 1)
                                frequencies1.append(frequencies2)
                        }
                        frequencies.append(frequencies1)
                }

                for n1 in 1 ... n1_max {
                        for n2 in 1 ... min(n1, n2_max) {
                                if n1 * n2 >= 2 {
                                        for u in 1 ... n1 * n2 / 2 {
                                                // F(u|n1, n2) = F(u − n2|n1 − 1, n2) + F(u|n1, n2 − 1)
                                                let term1 = get_frequency(n1: n1 - 1, n2: n2, u: u - n2)
                                                let term2 = get_frequency(n1: n1, n2: n2 - 1, u: u)
                                                frequencies[n1][n2][u] = term1 + term2
                                        }
                                }
                        }
                }
        }

        func get_frequency(n1 n1: Int, n2: Int, u: Int) -> Int {
                if u < 0 || u > n1 * n2 || n1 < 0 || n2 < 0 {
                        return 0
                }
                let v = u > n1 * n2 / 2 ? n1 * n2 - u : u
                return n1 < n2 ? frequencies[n2][n1][v] : frequencies[n1][n2][v]
        }

        func lower_tail_p_value_from_table(n1 n1: Int, n2: Int, u: Double) -> Double {
                var sum_of_frequencies = 0
                for var v = 0; Double(v) <= u; v++ {
                        let freq = get_frequency(n1: n1, n2: n2, u: v)
                        sum_of_frequencies += freq
                }

                let normalizer = exp(lgamma(Double(n1 + 1)) + lgamma(Double(n2 + 1)) - lgamma(Double(n1 + n2 + 1)))
                return normalizer * Double(sum_of_frequencies)
        }

        func lower_tail_p_value_from_normal_distribution(n1 n1: Int, n2: Int, u: Double) -> Double {
                let mean = Double(n1 * n2) / 2.0
                let variance = Double(n1 * n2 * (n1 + n2 + 1)) / 12.0
                let p_value = normal_distribution_lower_tail(mean: mean, variance: variance, quantile: u)
                return p_value
        }

        func two_sided_pvalue(n1 n1: Int, n2: Int, u: Double) -> Double {
                let m1 = max(n1, n2)
                let m2 = min(n1, n2)
                let v = u <= Double(m1 * m2) / 2 ? u : Double(m1 * m2) - u

                let p_value_one_sided = m1 <= n1_max && m2 <= n2_max ? lower_tail_p_value_from_table(n1: m1, n2: m2, u: v) : lower_tail_p_value_from_normal_distribution(n1: m1, n2: m2, u: v)

                return min(2.0 * p_value_one_sided, 1.0)
        }

        func two_sided_pvalue(values1 values1: [Double], values2: [Double]) -> Double {
                let sorted_values1 = values1.sort()
                let sorted_values2 = values2.sort()

                let n1 = sorted_values1.count
                let n2 = sorted_values2.count

                var counter1 = 0
                var counter2 = 0
                var u = 0 as Double

                while counter1 < n1 && counter2 < n2 {
                        if sorted_values1[counter1] < sorted_values2[counter2] {
                                u += Double(n2 - counter2)
                                counter1++
                        } else if sorted_values1[counter1] > sorted_values2[counter2] {
                                counter2++
                        } else {
                                var local_counter = counter2
                                while local_counter < n2 && sorted_values1[counter1] == sorted_values2[local_counter] {
                                        local_counter++
                                }
                                u += 0.5 * Double(local_counter - counter2)
                                u += Double(n2 - local_counter)
                                counter1++
                        }
                }

                return two_sided_pvalue(n1: n1, n2: n2, u: u)
        }
}
