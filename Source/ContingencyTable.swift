import Foundation

struct ChiSquareContingencyTable {

        let observedFrequencies: [[Int]]
        let total: Int
        let rowTotals: [Int]
        let columnTotals: [Int]
        let expectedFrequencies: [[Double]]
        let normalizedObservedExpectedDeviations: [[Double]]
        let chiSquareStatistic: Double
        let degreesOfFreedom: Int
        let p_value: Double

        init(observedFrequencies: [[Int]]) {
                self.observedFrequencies = observedFrequencies
                (total, rowTotals, columnTotals) = ChiSquareContingencyTable.calculateTotals(observedFrequencies: observedFrequencies)
                expectedFrequencies = ChiSquareContingencyTable.calculateExpectedFrequencies(total: total, rowTotals: rowTotals, columnTotals: columnTotals)
                normalizedObservedExpectedDeviations = ChiSquareContingencyTable.calculateNormalizedObservedExpectedDeviations(observedFrequencies: observedFrequencies, expectedFrequencies: expectedFrequencies)
                chiSquareStatistic = ChiSquareContingencyTable.calculateChiSquareStatistic(observedFrequencies: observedFrequencies, expectedFrequencies: expectedFrequencies)
                degreesOfFreedom = (rowTotals.count - 1) * (columnTotals.count - 1)
                p_value = Double(ChiSquare.chiSquareProbabilityUpperTail(degreesOfFreedom: Double(degreesOfFreedom), quantile: Double(chiSquareStatistic)))
        }

        static func calculateTotals(observedFrequencies observedFrequencies: [[Int]]) -> (total: Int, rowTotals: [Int], columnTotals: [Int]) {
                var total = 0
                var rowTotals = [Int](count: observedFrequencies.count, repeatedValue: 0)
                var columnTotals = [Int](count: observedFrequencies[0].count, repeatedValue: 0)
                for i in 0 ..< observedFrequencies.count {
                        for j in 0 ..< observedFrequencies[0].count {
                                total += observedFrequencies[i][j]
                                rowTotals[i] += observedFrequencies[i][j]
                                columnTotals[j] += observedFrequencies[i][j]
                        }
                }
                return (total, rowTotals, columnTotals)
        }

        static func calculateExpectedFrequencies(total total: Int, rowTotals: [Int], columnTotals: [Int]) -> [[Double]] {
                var expectedFrequencies = [] as [[Double]]
                for i in 0 ..< rowTotals.count {
                        var expectedFrequenciesForRow = [] as [Double]
                        for j in 0 ..< columnTotals.count {
                                let expectedFrequency = Double(rowTotals[i]) * Double(columnTotals[j]) / Double(total)
                                expectedFrequenciesForRow.append(expectedFrequency)
                        }
                        expectedFrequencies.append(expectedFrequenciesForRow)
                }
                return expectedFrequencies
        }

        static func calculateNormalizedObservedExpectedDeviations(observedFrequencies observedFrequencies: [[Int]], expectedFrequencies: [[Double]]) -> [[Double]] {
                var normalizedObservedExpectedDeviations = [] as [[Double]]
                for i in 0 ..< observedFrequencies.count {
                        var normalizedObservedExpectedDeviationsForRow = [] as [Double]
                        for j in 0 ..< observedFrequencies[0].count {
                                let deviation = expectedFrequencies[i][j] - Double(observedFrequencies[i][j])
                                var normalizedDeviation = 0 as Double
                                if expectedFrequencies[i][j] < 1e-20 {
                                        normalizedDeviation = 0
                                } else {
                                        normalizedDeviation = deviation / expectedFrequencies[i][j]
                                }
                                normalizedObservedExpectedDeviationsForRow.append(normalizedDeviation)
                        }
                        normalizedObservedExpectedDeviations.append(normalizedObservedExpectedDeviationsForRow)
                }
                return normalizedObservedExpectedDeviations
        }

        static func calculateChiSquareStatistic(observedFrequencies observedFrequencies: [[Int]], expectedFrequencies: [[Double]]) -> Double {
                var chiSquareStatistic = 0 as Double
                for i in 0 ..< observedFrequencies.count {
                        for j in 0 ..< observedFrequencies[0].count {
                                let observed = Double(observedFrequencies[i][j])
                                let expected = expectedFrequencies[i][j]
                                chiSquareStatistic += pow(observed - expected, 2) / expected
                        }
                }
                return chiSquareStatistic
        }
}
