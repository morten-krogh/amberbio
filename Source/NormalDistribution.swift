import Foundation

func normal_distribution_lower_tail(mean mean: Double, variance: Double, quantile: Double) -> Double {
        let z = (quantile - mean) / sqrt(variance)
        let extreme_tail = 0.5 * ChiSquare.incompleteUpperGamma(s: 0.5, z: z * z / 2)
        return z > 0 ? 1 - extreme_tail : extreme_tail
}

func normal_distribution_upper_tail(mean mean: Double, variance: Double, quantile: Double) -> Double {
        let z = (quantile - mean) / sqrt(variance)
        let extreme_tail = 0.5 * ChiSquare.incompleteUpperGamma(s: 0.5, z: z * z / 2)
        return z > 0 ? extreme_tail : 1 - extreme_tail
}
