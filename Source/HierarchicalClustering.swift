import Foundation

class HierarchicalClustering {

        let number_of_points: Int
        let point_distances: [Double]
        let linkage: String

        var parents1 = [] as [Int?]
        var parents2 = [] as [Int?]
        var distances = [] as [Double]
        var cluster_size = [] as [Int]
        var alive = [] as [Bool]
        var number_of_live_clusters = 0
        var nearest_neighbor = [] as [Int]
        var nearest_neighbor_distance = [] as [Double]

        var order = [] as [Int]
        var cluster_average_position = [] as [Double]

        init(number_of_points: Int, point_distances: [Double], linkage: String) {
                self.number_of_points = number_of_points
                self.point_distances = point_distances
                self.linkage = linkage

                calculate_clusters()
                order = [Int](count: number_of_points, repeatedValue: -1)
                calculate_ordering(cluster: parents1.count - 1, start: 0, end: number_of_points)
                calculate_cluster_average_position()
        }

        func calculate_clusters() {
                parents1 = [Int?](count: number_of_points, repeatedValue: nil)
                parents2 = [Int?](count: number_of_points, repeatedValue: nil)
                distances = [Double](count: number_of_points, repeatedValue: 0)
                cluster_size = [Int](count: number_of_points, repeatedValue: 1)
                alive = [Bool](count: number_of_points, repeatedValue: true)
                number_of_live_clusters = number_of_points
                nearest_neighbor = [Int](count: number_of_points, repeatedValue: -1)
                nearest_neighbor_distance = [Double](count: number_of_points, repeatedValue: Double.infinity)

                for i in 1 ..< number_of_points {
                        for j in 0 ..< i {
                                let distance = point_distances[i * (i - 1) / 2 + j]
                                if distance < nearest_neighbor_distance[i] {
                                        nearest_neighbor[i] = j
                                        nearest_neighbor_distance[i] = distance
                                }
                                if distance < nearest_neighbor_distance[j] {
                                        nearest_neighbor[j] = i
                                        nearest_neighbor_distance[j] = distance
                                }
                        }
                }

                while number_of_live_clusters > 1 {
                        var minimum_distance = Double.infinity
                        var minimum_distance_cluster = -1
                        for i in 0 ..< alive.count {
                                if alive[i] && nearest_neighbor_distance[i] < minimum_distance {
                                        minimum_distance = nearest_neighbor_distance[i]
                                        minimum_distance_cluster = i
                                }
                        }
                        let parent1 = minimum_distance_cluster
                        let parent2 = nearest_neighbor[parent1]
                        parents1.append(parent1)
                        parents2.append(parent2)
                        distances.append(minimum_distance)
                        cluster_size.append(cluster_size[parent1] + cluster_size[parent2])
                        alive[parent1] = false
                        alive[parent2] = false
                        alive.append(true)
                        number_of_live_clusters--

                        let nearest = calculate_nearest_neighbor(cluster: alive.count - 1)
                        nearest_neighbor.append(nearest.neighbor)
                        nearest_neighbor_distance.append(nearest.distance)

                        for i in 0 ..< alive.count - 1 {
                                if alive[i] && (i == parent1 || i == parent2 || nearest_neighbor[i] == parent1 || nearest_neighbor[i] == parent2) {
                                        let nearest = calculate_nearest_neighbor(cluster: i)
                                        nearest_neighbor[i] = nearest.neighbor
                                        nearest_neighbor_distance[i] = nearest.distance
                                }
                        }
                }
        }

        func expand_clusters(clusters clusters: [Int]) -> [Int] {
                var done = true
                var expansion = [] as [Int]
                for cluster in clusters {
                        if cluster < number_of_points {
                                expansion.append(cluster)
                        } else {
                                expansion.append(parents1[cluster]!)
                                expansion.append(parents2[cluster]!)
                                done = false
                        }
                }
                return done ? expansion : expand_clusters(clusters: expansion)
        }

        func calculate_points_in_cluster(cluster cluster: Int) -> [Int] {
                return expand_clusters(clusters: [cluster])
        }

        func calculate_ordering(cluster cluster: Int, start: Int, end: Int) {
                if cluster < number_of_points {
                        order[cluster] = start
                        return
                }

                let parent1 = parents1[cluster]!
                let parent2 = parents2[cluster]!
                if cluster_size[parent1] >= cluster_size[parent2] {
                        calculate_ordering(cluster: parent1, start: start, end: start + cluster_size[parent1])
                        calculate_ordering(cluster: parent2, start: start + cluster_size[parent1], end: end)
                } else {
                        calculate_ordering(cluster: parent2, start: start, end: start + cluster_size[parent2])
                        calculate_ordering(cluster: parent1, start: start + cluster_size[parent2], end: end)
                }
        }

        func calculate_cluster_average_position() {
                cluster_average_position = [Double](count: parents1.count, repeatedValue: -1)
                for i in 0 ..< number_of_points {
                        cluster_average_position[i] = Double(order[i]) + 0.5
                }
                for i in number_of_points ..< parents1.count {
                        cluster_average_position[i] = (cluster_average_position[parents1[i]!] + cluster_average_position[parents2[i]!]) / 2
                }
        }

        func calculate_distance_between_clusters(cluster1 cluster1: Int, cluster2: Int) -> Double {
                let points1 = calculate_points_in_cluster(cluster: cluster1)
                let points2 = calculate_points_in_cluster(cluster: cluster2)

                switch linkage {
                case "minimum":
                        return minimum_linkage(points1: points1, points2: points2)
                case "maximum":
                        return maximum_linkage(points1: points1, points2: points2)
                default:
                        return average_linkage(points1: points1, points2: points2)
                }
        }

        func minimum_linkage(points1 points1: [Int], points2: [Int]) -> Double {
                var minimum = Double.infinity
                for point1 in points1 {
                        for point2 in points2 {
                                let (i, j) = point1 < point2 ? (point2, point1) : (point1, point2)
                                let distance = point_distances[i * (i - 1) / 2 + j]
                                if distance < minimum {
                                        minimum = distance
                                }
                        }
                }
                return minimum
        }

        func maximum_linkage(points1 points1: [Int], points2: [Int]) -> Double {
                var maximum = -Double.infinity
                for point1 in points1 {
                        for point2 in points2 {
                                let (i, j) = point1 < point2 ? (point2, point1) : (point1, point2)
                                let distance = point_distances[i * (i - 1) / 2 + j]
                                if distance > maximum {
                                        maximum = distance
                                }
                        }
                }
                return maximum
        }

        func average_linkage(points1 points1: [Int], points2: [Int]) -> Double {
                var sum_of_distances = 0 as Double
                for point1 in points1 {
                        for point2 in points2 {
                                let (i, j) = point1 < point2 ? (point2, point1) : (point1, point2)
                                let distance = point_distances[i * (i - 1) / 2 + j]
                                sum_of_distances += distance
                        }
                }
                return sum_of_distances / Double(points1.count * points2.count)
        }

        func calculate_nearest_neighbor(cluster cluster: Int) -> (neighbor: Int, distance: Double) {
                var neighbor = -1
                var distance = Double.infinity

                for i in 0 ..< alive.count {
                        if alive[i] && i != cluster {
                                let dist = calculate_distance_between_clusters(cluster1: cluster, cluster2: i)
                                if dist < distance {
                                        neighbor = i
                                        distance = dist
                                }
                        }
                }
                return (neighbor, distance)
        }
}
