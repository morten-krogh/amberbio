//
//  MissingValues.swift
//  Bioinformatics
//
//  Created by Morten Krogh on 25/05/15.
//  Copyright (c) 2015 Amber Biosicences. All rights reserved.
//

import Foundation

func calculate_molecule_indices_without_missing_values(values values: [Double], number_of_molecules: Int, selected_sample_indices: [Int]) -> [Int] {
        var molecule_indices = [] as [Int]

        for i in 0 ..< number_of_molecules {
                let offset = i * (values.count / number_of_molecules)
                var missing = false
                for sample_index in selected_sample_indices {
                        let value = values[offset + sample_index]
                        if value.isNaN {
                                missing = true
                                break
                        }
                }
                if !missing {
                        molecule_indices.append(i)
                }
        }

        return molecule_indices
}
