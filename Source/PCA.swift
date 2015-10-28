import Foundation

func vector_addition(vectors vectors: [[Double]]) -> [Double] {
        var sum = vectors[0]
        for i in 1 ..< vectors.count {
                for j in 0 ..< vectors[i].count {
                        sum[j] += vectors[i][j]
                }
        }
        return sum
}

func scalar_vector_multiplication(scalar scalar: Double, vector: [Double]) -> [Double] {
        var product = vector
        for i in 0 ..< vector.count {
                product[i] = scalar * vector[i]
        }
        return product
}

func vector_subtraction(vector1 vector1: [Double], vector2: [Double]) -> [Double] {
        var difference = vector1
        for i in 0 ..< vector1.count {
                difference[i] -= vector2[i]
        }
        return difference
}

func vector_product(vector1 vector1: [Double], vector2: [Double]) -> Double {
        var product = 0 as Double
        for i in 0 ..< vector1.count {
                product += vector1[i] * vector2[i]
        }
        return product
}

func vector_norm(vector vector: [Double]) -> Double {
        var norm_square = 0 as Double
        for elem in vector {
                norm_square += elem * elem
        }
        return sqrt(norm_square)
}

func vector_convergence(vector1 vector1: [Double], vector2: [Double], cutoff: Double) -> Bool {
        let difference = vector_subtraction(vector1: vector1, vector2: vector2)
        let norm = vector_norm(vector: difference)
        return norm < cutoff
}

func vector_random_unit(length length: Int) -> [Double] {
        let N = 2147483647 as Double
        var vector = [Double](count: length, repeatedValue: 0)
        for i in 0 ..< length {
                let random_number = Double(random())
                let value = (random_number - N) / N
                vector[i] = value
        }
        let norm = vector_norm(vector: vector)
        if norm < 0.001 {
                return vector_random_unit(length: length)
        } else {
                return scalar_vector_multiplication(scalar: 1 / norm, vector: vector)
        }
}

func matrix_vector_multiplication(matrix matrix: [[Double]], vector: [Double]) -> [Double] {
        var product = [Double](count: matrix.count, repeatedValue: 0)
        for i in 0 ..< matrix.count {
                for j in 0 ..< vector.count {
                        product[i] += matrix[i][j] * vector[j]
                }
        }
        return product
}

func matrix_trace(matrix matrix: [[Double]]) -> Double {
        var trace = 0 as Double
        for i in 0 ..< matrix.count {
                trace += matrix[i][i]
        }
        return trace
}

func gram_schmidt(vector vector: [Double], orthonormals: [[Double]], cutoff: Double) -> [Double]? {
        var projections = [] as [[Double]]
        for normal in orthonormals {
                let scalar = vector_product(vector1: vector, vector2: normal)
                let projection = scalar_vector_multiplication(scalar: scalar, vector: normal)
                projections.append(projection)
        }
        var residual = [] as [Double]
        if !projections.isEmpty {
                let total_projection = vector_addition(vectors: projections)
                residual = vector_subtraction(vector1: vector, vector2: total_projection)
        } else {
                residual = vector
        }
        let norm_of_residual = vector_norm(vector: residual)
        if norm_of_residual < cutoff {
                return nil
        } else {
                return scalar_vector_multiplication(scalar: 1 / norm_of_residual, vector: residual)
        }
}

func pca_next_component(matrix matrix: [[Double]], components: [[Double]], cutoff: Double) -> [Double]? {
        if components.count >= matrix.count {
                return nil
        }
        var component = vector_random_unit(length: matrix.count)
        var iteration = 0
        while iteration < 100 {
                let next = matrix_vector_multiplication(matrix: matrix, vector: component)
                if let orthonormalized_next = gram_schmidt(vector: next, orthonormals: components, cutoff: cutoff) {
                        if vector_convergence(vector1: component, vector2: orthonormalized_next, cutoff: cutoff) {
                                return orthonormalized_next
                        } else {
                                component = orthonormalized_next
                                iteration++
                        }
                } else {
                        return nil
                }
        }
        return component
}

func pca_components(matrix matrix: [[Double]], number_of_components: Int) -> (components: [[Double]], eigenvalues: [Double], variances: [Double]) {
        let cutoff = 1e-4 as Double
        var components = [] as [[Double]]
        var eigenvalues = [] as [Double]
        for _ in 0 ..< number_of_components {
                if let component = pca_next_component(matrix: matrix, components: components, cutoff: cutoff) {
                        let transformed_component =  matrix_vector_multiplication(matrix: matrix, vector: component)
                        let eigenvalue = vector_norm(vector: transformed_component)

                        components.append(component)
                        eigenvalues.append(eigenvalue)
                } else {
                        break
                }
        }

        let total_variance = matrix_trace(matrix: matrix)
        let variances = eigenvalues.map { $0 / total_variance }

        return (components, eigenvalues, variances)
}

func pca_center(values values: [Double], number_of_molecules: Int, sample_indices: [Int]) -> [[Double]] {
        var matrix = [] as [[Double]]
        let number_of_samples = values.count / number_of_molecules
        for i in 0 ..< number_of_molecules {
                let offset = i * number_of_samples
                var row = [] as [Double]
                var sum = 0 as Double
                var missing_value = false
                for sample_index in sample_indices {
                        let value = values[offset + sample_index]
                        if value.isNaN {
                                missing_value = true
                                break
                        } else {
                                row.append(value)
                                sum += value
                        }
                }
                if !missing_value {
                        let mean = sum / Double(sample_indices.count)
                        row = row.map { $0 - mean }
                        matrix.append(row)
                }
        }
        return matrix
}

func pca_reduce_rank(matrix matrix: [[Double]]) -> [[Double]] {
        let cutoff = 1e-5 as Double
        var basis = [] as [[Double]]
        var coefficients = [] as [[Double]]
        for i in 0 ..< matrix[0].count - 1 {
                var column = [Double](count: matrix.count, repeatedValue: 0)
                for j in 0 ..< matrix.count {
                        column[j] = matrix[j][i]
                }
                var coefficients_for_column = [] as [Double]
                for basis_vector in basis {
                        let dot_product = vector_product(vector1: column, vector2: basis_vector)
                        coefficients_for_column.append(dot_product)
                        column = vector_subtraction(vector1: column, vector2: scalar_vector_multiplication(scalar: dot_product, vector: basis_vector))
                }
                let norm_column = vector_norm(vector: column)
                if norm_column > cutoff {
                        let basis_vector = scalar_vector_multiplication(scalar: 1 / norm_column, vector: column)
                        basis.append(basis_vector)
                        coefficients_for_column.append(norm_column)
                }
                coefficients.append(coefficients_for_column)
        }

        var reduced_matrix = [[Double]](count: basis.count, repeatedValue: [Double](count: matrix[0].count, repeatedValue: 0))
        for i in 0 ..< coefficients.count {
                let coefficients_for_column = coefficients[i]
                for j in 0 ..< coefficients_for_column.count {
                        reduced_matrix[j][i] = coefficients_for_column[j]
                }
        }
        for i in 0 ..< reduced_matrix.count {
                var sum = 0 as Double
                for j in 0 ..< reduced_matrix[i].count - 1 {
                        sum += reduced_matrix[i][j]
                }
                reduced_matrix[i][reduced_matrix[i].count - 1] = -sum
        }
        return reduced_matrix
}

func pca_matrix_transpose_square(matrix matrix: [[Double]]) -> [[Double]] {
        var symmetric_matrix = [[Double]](count: matrix.count, repeatedValue: [Double](count: matrix.count, repeatedValue: 0))
        for i in 0 ..< matrix.count {
                for j in 0 ..< (i + 1) {
                        var element = 0 as Double
                        for k in 0 ..< matrix[i].count {
                                element += matrix[i][k] * matrix[j][k]
                        }
                        symmetric_matrix[i][j] = element
                        symmetric_matrix[j][i] = element
                }
        }
        return symmetric_matrix
}

func pca_component_matrix(matrix matrix: [[Double]], components: [[Double]]) -> [[Double]] {
        var component_matrix = [[Double]](count: components.count, repeatedValue: [Double](count: matrix[0].count, repeatedValue: 0))
        for i in 0 ..< matrix[0].count {
                var column = [Double](count: matrix.count, repeatedValue: 0)
                for j in 0 ..< matrix.count {
                        column[j] = matrix[j][i]
                }
                for k in 0 ..< components.count {
                        let dot_product = vector_product(vector1: column, vector2: components[k])
                        component_matrix[k][i] = dot_product
                }
        }
        return component_matrix
}

func pca_main(values values: [Double], number_of_molecules: Int, number_of_components: Int, sample_indices: [Int]) -> (component_matrix: [[Double]], variances: [Double]) {
        if sample_indices.count < 2 {
                return ([], [])
        }

        srandom(1)

        let centered_matrix = pca_center(values: values, number_of_molecules: number_of_molecules, sample_indices: sample_indices)
        if centered_matrix.count == 0 {
                return ([], [])
        }

        let reduced_matrix: [[Double]]
        if centered_matrix.count <= centered_matrix[0].count {
                reduced_matrix = centered_matrix
        } else {
                reduced_matrix = pca_reduce_rank(matrix: centered_matrix)
        }

        if reduced_matrix.count == 0 {
                return ([], [])
        }

        let symmetric_matrix = pca_matrix_transpose_square(matrix: reduced_matrix)

        let (components, _, variances) = pca_components(matrix: symmetric_matrix, number_of_components: number_of_components)

        let component_matrix = pca_component_matrix(matrix: reduced_matrix, components: components)

        return (component_matrix, variances)
}
