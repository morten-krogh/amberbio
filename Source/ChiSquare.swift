import Foundation

class ChiSquare {

        class func incompleteNormalizedLowerGammaSeriesExpansion(s s: Double, z: Double) -> Double {
                /*
                Series expansion of the normalized lower incomplete gamma function
                This function should only be used for positive s and z.
                */

                let logPreFactor = -z + s * log(z) - lgamma(s)
                let preFactor = exp(logPreFactor)

                var term = 1 / s
                var sum = term
                for n in 1 ..< 1000 {
                        term *= z / (s + Double(n))
                        sum += term
                        if term < sum * 1e-6 {
                                break
                        }
                }
                
                let result = preFactor * sum
                
                return result
        }

        class func incompleteNormalizedUpperGammaContinuedFraction(s s: Double, z: Double) -> Double {
                /*
                Continued fraction expansion of the normalized upper incomplete gamma function.
                This function should only be called for positive s and z and z >= s.
                */
                let relativeError = 1e-10

                let logPreFactor = -z + s * log(z) - lgamma(s)
                let preFactor = exp(logPreFactor)

                var numerator = 1.0
                var numeratorPrevious = 0.0
                var denominator = 1.0 + z - s
                var denominatorPrevious = 1.0

                for n in 2 ..< 100 {
                        let nDouble = Double(n)
                        let a = 2 * nDouble - 1 + z - s
                        let b = (nDouble - 1) * (s - nDouble + 1)
                        let numeratorTemp = a * numerator + b * numeratorPrevious
                        let denominatorTemp = a * denominator + b * denominatorPrevious

                        numeratorPrevious = numerator
                        denominatorPrevious = denominator
                        numerator = numeratorTemp
                        denominator = denominatorTemp

                        let scale = min(numerator, denominator)
                        if scale > 1 {
                                numerator /= scale
                                denominator /= scale
                                numeratorPrevious /= scale
                                denominatorPrevious /= scale
                        }

                        if numerator != 0 && denominator != 0 && numeratorPrevious != 0 && denominatorPrevious != 0 {
                                let fraction = numerator / denominator
                                let fractionPrevious = numeratorPrevious / denominatorPrevious
                                let ratioOfFractions = fraction / fractionPrevious
                                if ratioOfFractions > 1 - relativeError && ratioOfFractions < 1 + relativeError {
                                        break
                                }
                        }
                }
                
                var fraction: Double
                if abs(denominator) <= 1e-20 {
                        fraction = numerator / denominator
                } else {
                        fraction = numeratorPrevious / denominatorPrevious
                }
                
                let result = preFactor * fraction
                
                return result
        }

        class func incompleteUpperGamma(s s: Double, z: Double) -> Double {

                if s <= 0 || z < 0 {
                        return Double.NaN
                }

                if z <= s {
                        return 1 - incompleteNormalizedLowerGammaSeriesExpansion(s: s, z: z)
                } else {
                        return incompleteNormalizedUpperGammaContinuedFraction(s: s, z: z)
                }
        }

        class func chiSquareProbabilityUpperTail(degreesOfFreedom degreesOfFreedom: Double, quantile: Double) -> Double {
                let upperTail = incompleteUpperGamma(s: degreesOfFreedom / 2, z: quantile / 2)
                
                return upperTail
        }
}
