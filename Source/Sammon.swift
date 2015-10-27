import Foundation

class Sammon {

        var sammon_points_2d = [] as [[Double]]
        var sammon_points_3d = [] as [[Double]]

        var molecule_indices = [] as [Int]

        init() {
                let sample_indices = [Int](0 ..< state.number_of_samples)

                var missing_values_per_molecule = [Int](count: state.number_of_samples, repeatedValue: 0)
                var std_dev_per_molecule = [Double](count: state.number_of_samples, repeatedValue: 0.0)

                values_calculate_missing_values_and_std_devs(state.values, state.number_of_molecules, state.number_of_samples, &missing_values_per_molecule, &std_dev_per_molecule)

                molecule_indices = []
                for i in 0 ..< state.number_of_samples {
                        if missing_values_per_molecule[i] == 0 {
                                molecule_indices.append(i)
                        }
                }

                

        }







}
