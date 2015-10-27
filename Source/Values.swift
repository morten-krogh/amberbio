import Foundation

func values_molecule_indices_without_missing_values(values values: [Double], number_of_molecules: Int, number_of_samples: Int, sample_indices: [Int]) -> [Int] {

        var molecule_indices = [Int](0 ..< number_of_molecules)
        var molecule_indices_length = number_of_molecules
        values_molecules_without_missing_values(values, number_of_molecules, number_of_samples, sample_indices, sample_indices.count, &molecule_indices, &molecule_indices_length)
        molecule_indices = [Int](molecule_indices[0 ..< molecule_indices_length])

        return molecule_indices
}
