import UIKit
import SceneKit

class Values3DPlot: SCNView {

        var sphere_nodes = [] as [SCNNode]
        var name_nodes = [] as [SCNNode]
        var title_nodes = [] as [SCNNode]
        var tick_label_nodes = [] as [SCNNode]

        var points_x = [] as [Double]
        var points_y = [] as [Double]
        var points_z = [] as [Double]
        var names = [] as [String]
        var plot_symbol = ""
        var colors = nil as [UIColor]?
        var axis_titles = [] as [String]
        var symbol_size = -1 as Double

        let view_scene = SCNScene()

        init() {
                super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100), options: nil)

                allowsCameraControl = true
                scene = view_scene
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func remove_nodes_from_scene() {
                let child_nodes = view_scene.rootNode.childNodes
                for child_node in child_nodes {
                        child_node.removeFromParentNode()
                }
        }

        func update_points(points_x points_x: [Double], points_y: [Double], points_z: [Double], names: [String], axis_titles: [String]) {

                let (min_xyz, max_xyz) = math_min_max(numbers: points_x + points_y + points_z)
                var max_value = max(abs(min_xyz), abs(max_xyz))
                max_value = max_value == 0 ? 1 : max_value
                let positive_tick_values = math_tick_values_positive(number: max_value)
                var unnormalized_tick_values = [] as [Double]
                for positive_tick_value in positive_tick_values.reverse() {
                        unnormalized_tick_values.append(-positive_tick_value)
                }
                unnormalized_tick_values = unnormalized_tick_values + positive_tick_values

                var tick_values = [] as [Double]
                var tick_labels = [] as [NSAttributedString]
                for tick_value in unnormalized_tick_values {
                        let value_as_string = decimal_string(number: tick_value, fraction_digits: 1)
                        let astring = astring_font_size_color(string: value_as_string, font: font_body)
                        tick_values.append(tick_value / max_value)
                        tick_labels.append(astring)
                }

                let (x_axis_node, x_text_node, x_tick_label_nodes) = create_axis(label: axis_titles[0], tick_values: tick_values, tick_labels: tick_labels)
                x_axis_node.rotation = SCNVector4(x: 0 as Float, y: 0 as Float, z: 1 as Float, w: -Float(M_PI_2))
                view_scene.rootNode.addChildNode(x_axis_node)

                let (y_axis_node, y_text_node, y_tick_label_nodes) = create_axis(label: axis_titles[1], tick_values: tick_values, tick_labels: tick_labels)
                view_scene.rootNode.addChildNode(y_axis_node)

                let (z_axis_node, z_text_node, z_tick_label_nodes) = create_axis(label: axis_titles[2], tick_values: tick_values, tick_labels: tick_labels)
                z_axis_node.rotation = SCNVector4(x: 1 as Float, y: 0 as Float, z: 0 as Float, w: Float(M_PI_2))
                view_scene.rootNode.addChildNode(z_axis_node)

                title_nodes = [x_text_node, y_text_node, z_text_node]
                tick_label_nodes = x_tick_label_nodes + y_tick_label_nodes + z_tick_label_nodes

                sphere_nodes = []
                for i in 0 ..< points_x.count {
                        let radius = 0.06 as CGFloat
                        let sphere_node = create_sphere_node(radius: radius, color: UIColor.blackColor(), x: points_x[i] / max_value, y: points_y[i] / max_value, z: points_z[i] / max_value)
                        sphere_nodes.append(sphere_node)
                        view_scene.rootNode.addChildNode(sphere_node)
                }

                name_nodes = []
                for i in 0 ..< points_x.count {
                        let name_geometry = SCNText(string: names[i], extrusionDepth: 3)
                        name_geometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
                        let name_node = SCNNode(geometry: name_geometry)

                        var min_bounding = SCNVector3()
                        var max_bounding = SCNVector3()
                        name_node.getBoundingBoxMin(&min_bounding, max: &max_bounding)
                        let width_x = max_bounding.x - min_bounding.x
                        let width_y = max_bounding.y - min_bounding.y
                        let width_z = max_bounding.z - min_bounding.z

                        let pivot = SCNMatrix4MakeTranslation(width_x / 2, width_y / 2, width_z / 2)
                        name_node.pivot = pivot

                        name_node.position = SCNVector3(x: Float(points_x[i] / max_value), y: Float(points_y[i] / max_value), z: Float(points_z[i] / max_value))
                        name_nodes.append(name_node)
                        view_scene.rootNode.addChildNode(name_node)
                }
        }

        func update_colors(colors colors: [UIColor]?) {
                for i in 0 ..< sphere_nodes.count {
                        let color = colors?[i] ?? UIColor.blackColor()
                        sphere_nodes[i].geometry?.firstMaterial?.diffuse.contents = color
                        name_nodes[i].geometry?.firstMaterial?.diffuse.contents = color
                }
        }

        func update_plot_symbol(symbol symbol: String) {
                let circles = symbol == "circles"
                for i in 0 ..< sphere_nodes.count {
                        sphere_nodes[i].hidden = !circles
                        name_nodes[i].hidden = circles
                }
        }

        func update_symbol_size(symbol_size symbol_size: Double) {
                let axis_title_scale = 0.003 * exp(symbol_size)
                for title_node in title_nodes {
                        title_node.scale = SCNVector3(x: Float(axis_title_scale), y: Float(axis_title_scale), z: Float(axis_title_scale))
                }

                let tick_label_scale = 0.0009 * exp(symbol_size)
                for tick_label_node in tick_label_nodes {
                        tick_label_node.scale = SCNVector3(x: Float(tick_label_scale), y: Float(tick_label_scale), z: Float(tick_label_scale))
                }

                let xyz_scale = 0.1 * exp(2 * symbol_size)
                let sphere_scale = SCNVector3(x: Float(xyz_scale), y: Float(xyz_scale), z: Float(xyz_scale))
                let name_scale = SCNVector3(x: Float(0.01 * xyz_scale), y: Float(0.01 * xyz_scale), z: Float(0.01 * xyz_scale))
                for i in 0 ..< sphere_nodes.count {
                        sphere_nodes[i].scale = sphere_scale
                        name_nodes[i].scale = name_scale
                }
        }

        func update(points_x points_x: [Double], points_y: [Double], points_z: [Double], names: [String], plot_symbol: String, colors: [UIColor]?, axis_titles: [String], symbol_size: Double) {

                let same_scene = compare_arrays(array1: self.points_x, array2: points_x) && compare_arrays(array1: self.points_y, array2: points_y) && compare_arrays(array1: self.points_z, array2: points_z) && compare_arrays(array1: self.names, array2: names) && compare_arrays(array1: self.axis_titles, array2: axis_titles)

                if !same_scene {
                        remove_nodes_from_scene()
                        update_points(points_x: points_x, points_y: points_y, points_z: points_z, names: names, axis_titles: axis_titles)
                        self.points_x = points_x
                        self.points_y = points_y
                        self.points_z = points_z
                        self.names = names
                        self.axis_titles = axis_titles
                }

                update_colors(colors: colors)
                self.colors = colors

                update_plot_symbol(symbol: plot_symbol)
                self.plot_symbol = plot_symbol

                update_symbol_size(symbol_size: symbol_size)
                self.symbol_size = symbol_size
        }

        func compare_arrays<T: Equatable>(array1 array1: [T], array2: [T]) -> Bool {
                if array1.count != array2.count {
                        return false
                }
                for i in 0 ..< array1.count {
                        if array1[i] != array2[i] {
                                return false
                        }
                }
                return true
        }

        func create_axis(label label: String, tick_values: [Double], tick_labels: [NSAttributedString]) -> (axis_node: SCNNode, text_node: SCNNode, tick_label_nodes: [SCNNode]) {
                let axis_node = SCNNode()
                let cylinder_geometry = SCNCylinder(radius: 0.01, height: 2)
                cylinder_geometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
                let cylinder_node = SCNNode(geometry: cylinder_geometry)
                axis_node.addChildNode(cylinder_node)

                let cone_geometry = SCNCone(topRadius: 0, bottomRadius: 0.03, height: 0.1)
                cone_geometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
                let cone_node = SCNNode(geometry: cone_geometry)
                cone_node.position = SCNVector3(x: 0, y: 1, z: 0)
                axis_node.addChildNode(cone_node)

                let text_geometry = SCNText(string: label, extrusionDepth: 3)
                text_geometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
                let text_node = SCNNode(geometry: text_geometry)
                text_node.rotation = SCNVector4(x: 0 as Float, y: 0 as Float, z: 1 as Float, w: Float(M_PI_2))
                text_node.position = SCNVector3(x: 0.2, y: 0.9, z: 0)
                text_node.scale = SCNVector3(x: 0.006, y: 0.006, z: 0.006)
                axis_node.addChildNode(text_node)

                var tick_label_nodes = [] as [SCNNode]

                for i in 0 ..< tick_values.count {
                        let tick_geometry = SCNCylinder(radius: 0.01, height: 0.1)
                        tick_geometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
                        let tick_node = SCNNode(geometry: tick_geometry)
                        tick_node.rotation = SCNVector4(x: 0 as Float, y: 0 as Float, z: 1 as Float, w: Float(M_PI_2))
                        tick_node.position = SCNVector3(x: 0, y: Float(tick_values[i]), z: 0)
                        axis_node.addChildNode(tick_node)

                        let tick_label_geometry = SCNText(string: tick_labels[i], extrusionDepth: 3)
                        tick_label_geometry.firstMaterial?.diffuse.contents = UIColor.blackColor()
                        let tick_label_node = SCNNode(geometry: tick_label_geometry)
                        tick_label_node.rotation = SCNVector4(x: 0 as Float, y: 0 as Float, z: 1 as Float, w: Float(M_PI_2))
                        tick_label_node.position = SCNVector3(x: 0.15, y: Float(tick_values[i]) - 0.05, z: 0)
                        tick_label_node.scale = SCNVector3(x: 0.003, y: 0.003, z: 0.003)
                        axis_node.addChildNode(tick_label_node)
                        tick_label_nodes.append(tick_label_node)
                }

                return (axis_node, text_node, tick_label_nodes)
        }

        func create_sphere_node(radius radius: CGFloat, color: UIColor, x: Double, y: Double, z: Double) -> SCNNode {
                let sphere_geometry = SCNSphere(radius: radius)
                sphere_geometry.firstMaterial?.diffuse.contents = color
                let sphere_node = SCNNode(geometry: sphere_geometry)
                sphere_node.position = SCNVector3(x: Float(x), y: Float(y), z: Float(z))

                return sphere_node
        }
}
