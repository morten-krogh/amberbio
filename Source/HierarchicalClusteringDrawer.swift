import UIKit

class HierarchicalClusteringDrawer: TiledScrollViewDelegate {

        var content_size = CGSize.zero
        var maximum_zoom_scale = 1 as CGFloat
        var minimum_zoom_scale = 1 as CGFloat

        let hierarchical_clustering: HierarchicalClustering
        let sample_names: [String]
        let factor_names: [String]
        let level_colors: [[UIColor]]
        let molecule_names: [String]
        let heatmap_colors: [[UIColor]]
        let color_key: ColorKey

        let margin_dendrogram = 10 as CGFloat

        var sample_width = 40 as CGFloat
        let total_cluster_height = 200 as CGFloat
        var distance_unit_height = 50 as CGFloat
        let factor_height = 30 as CGFloat
        let factor_separation = 2 as CGFloat
        let color_separation = 2 as CGFloat
        let margin_factor_name = 15 as CGFloat

        let molecule_height = 20 as CGFloat
        let molecule_separation = 1 as CGFloat

        let color_key_width = 400 as CGFloat
        let color_key_color_height = 30 as CGFloat

        init(hierarchical_clustering: HierarchicalClustering, sample_names: [String], factor_names: [String], level_colors: [[UIColor]], molecule_names: [String], heatmap_colors: [[UIColor]], color_key: ColorKey) {
                self.hierarchical_clustering = hierarchical_clustering
                self.sample_names = sample_names
                self.factor_names = factor_names
                self.level_colors = level_colors
                self.molecule_names = molecule_names
                self.heatmap_colors = heatmap_colors
                self.color_key = color_key

                let greatest_distance = CGFloat(hierarchical_clustering.distances[hierarchical_clustering.parents1.count - 1])
                if greatest_distance > 0 {
                        distance_unit_height = total_cluster_height / greatest_distance
                }

                var maximum_text_width = 0 as CGFloat
                for factor_name in factor_names {
                        let width = astring_body(string: factor_name).size().width
                        if width > maximum_text_width {
                                maximum_text_width = width
                        }
                }
                for molecule_name in molecule_names {
                        let width = astring_body(string: molecule_name).size().width
                        if width > maximum_text_width {
                                maximum_text_width = width
                        }
                }

                var content_width = margin_dendrogram + CGFloat(hierarchical_clustering.number_of_points) * sample_width + margin_dendrogram + maximum_text_width + margin_dendrogram

                if !molecule_names.isEmpty {
                        content_width = max(color_key_width, content_width)
                }

                var content_height = 4 * margin_dendrogram + distance_unit_height * greatest_distance + (factor_height + factor_separation) * CGFloat(factor_names.count) + CGFloat(molecule_names.count) * molecule_height

                var maximum_sample_name_width = 0 as CGFloat
                for sample_name in sample_names {
                        let width = astring_body(string: sample_name).size().width
                        if width > maximum_sample_name_width {
                                maximum_sample_name_width = width
                        }
                }

                content_height += margin_dendrogram + maximum_sample_name_width

                if !molecule_names.isEmpty {
                        content_height += 3 * margin_dendrogram + height_of_color_key()
                }

                content_height += margin_dendrogram

                content_size = CGSize(width: content_width, height: content_height)
        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}
        
        func draw(context context: CGContext, rect: CGRect) {
                CGContextSaveGState(context)

                var position_y = margin_dendrogram
                draw_cluster(context: context, cluster: hierarchical_clustering.parents1.count - 1, position_y: position_y)
                position_y += margin_dendrogram + distance_unit_height * CGFloat(hierarchical_clustering.distances[hierarchical_clustering.parents1.count - 1])
                draw_factors(context: context, position_y: position_y)
                position_y += (factor_height + factor_separation) * CGFloat(factor_names.count) + margin_dendrogram
                draw_heatmap(context: context, rect: rect, position_y: position_y)
                position_y += CGFloat(molecule_names.count) * molecule_height + margin_dendrogram
                let sample_names_height = draw_sample_names(context: context, rect: rect, position_y: position_y)
                position_y += sample_names_height + margin_dendrogram
                if !molecule_names.isEmpty {
                        position_y += 3 * margin_dendrogram
                        draw_color_key(context: context, rect: rect, position_y: position_y)
                }

                CGContextRestoreGState(context)

        }

        func draw_cluster(context context: CGContext, cluster: Int, position_y: CGFloat) {
                if cluster < hierarchical_clustering.number_of_points {
                        return
                }

                let distance = hierarchical_clustering.distances[cluster]

                let parent1 = hierarchical_clustering.parents1[cluster]!
                let distance1 = hierarchical_clustering.distances[parent1]

                let parent2 = hierarchical_clustering.parents2[cluster]!
                let distance2 = hierarchical_clustering.distances[parent2]

                let position_x_1 = margin_dendrogram + sample_width * CGFloat(hierarchical_clustering.cluster_average_position[parent1])
                let position_x_2 = margin_dendrogram + sample_width * CGFloat(hierarchical_clustering.cluster_average_position[parent2])

                let y_distance1 = distance - distance1
                let y_distance2 = distance - distance2

                let position_y_1 = position_y + distance_unit_height * CGFloat(y_distance1)
                let position_y_2 = position_y + distance_unit_height * CGFloat(y_distance2)

                CGContextSetLineWidth(context, 1)
                CGContextBeginPath(context)
                CGContextMoveToPoint(context, position_x_1, position_y_1)
                CGContextAddLineToPoint(context, position_x_1, position_y)
                CGContextAddLineToPoint(context, position_x_2, position_y)
                CGContextAddLineToPoint(context, position_x_2, position_y_2)

                CGContextStrokePath(context)

                draw_cluster(context: context, cluster: parent1, position_y: position_y_1)
                draw_cluster(context: context, cluster: parent2, position_y: position_y_2)
        }

        func draw_factors(context context: CGContext, position_y: CGFloat) {
                CGContextSetLineWidth(context, 0)
                for i in 0 ..< factor_names.count {
                        for j in 0 ..< level_colors[0].count {
                                CGContextSetFillColorWithColor(context, level_colors[i][j].CGColor)
                                let cell_position_x = margin_dendrogram + sample_width * CGFloat(j) + color_separation
                                let cell_position_y = position_y + (factor_separation + factor_height) * CGFloat(i)

                                CGContextBeginPath(context)
                                CGContextMoveToPoint(context, cell_position_x, cell_position_y)
                                CGContextAddLineToPoint(context, cell_position_x + sample_width - 2 * color_separation, cell_position_y)
                                CGContextAddLineToPoint(context, cell_position_x + sample_width - 2 * color_separation, cell_position_y + factor_height)
                                CGContextAddLineToPoint(context, cell_position_x, cell_position_y + factor_height)
                                CGContextClosePath(context)

                                CGContextFillPath(context)
                        }

                        let astring = astring_body(string: factor_names[i])
                        let text_position_x = margin_dendrogram + sample_width * CGFloat(level_colors[0].count) + margin_factor_name
                        let text_position_y = position_y + (factor_separation + factor_height) * CGFloat(i) + (factor_height - astring.size().height) / 2
                        astring.drawAtPoint(CGPoint(x: text_position_x, y: text_position_y))
                }
        }

        func draw_sample_names(context context: CGContext, rect: CGRect, position_y: CGFloat) -> CGFloat{
                var height = 0 as CGFloat

                if position_y > CGRectGetMaxY(rect) {
                        return height
                }
                for i in 0 ..< sample_names.count {
                        let astring = astring_body(string: sample_names[i])
                        height = max(height, astring.size().width)
                        let text_position_x = margin_dendrogram + sample_width * CGFloat(i) + (sample_width + astring.size().height) / 2
                        Drawing.drawAttributedText(context: context, attributedText: astring, origin: CGPoint(x: text_position_x, y: position_y), horizontal: false)
                }
                return height
        }

        func draw_heatmap(context context: CGContext, rect: CGRect, position_y: CGFloat) {
//                let rect_lower_x = CGRectGetMinX(rect)
//                let rect_upper_x = CGRectGetMaxX(rect)
                let rect_lower_y = CGRectGetMinY(rect)
                let rect_upper_y = CGRectGetMaxY(rect)

                for i in 0 ..< molecule_names.count {
                        let cell_position_y = position_y + molecule_height * CGFloat(i) + molecule_separation
                        if rect_upper_y < cell_position_y {
                                break
                        }
                        if rect_lower_y > cell_position_y + molecule_height {
                                continue
                        }
                        for j in 0 ..< heatmap_colors[0].count {
                                CGContextSetFillColorWithColor(context, heatmap_colors[i][j].CGColor)
                                let cell_position_x = margin_dendrogram + sample_width * CGFloat(j) + color_separation

                                CGContextBeginPath(context)
                                CGContextMoveToPoint(context, cell_position_x, cell_position_y)
                                CGContextAddLineToPoint(context, cell_position_x + sample_width - 2 * color_separation, cell_position_y)
                                CGContextAddLineToPoint(context, cell_position_x + sample_width - 2 * color_separation, cell_position_y + molecule_height - 2 * molecule_separation)
                                CGContextAddLineToPoint(context, cell_position_x, cell_position_y + molecule_height - 2 * molecule_separation)
                                CGContextClosePath(context)

                                CGContextFillPath(context)
                        }

                        let astring = astring_footnote(string: molecule_names[i])
                        let text_position_x = margin_dendrogram + sample_width * CGFloat(heatmap_colors[0].count) + margin_factor_name
                        let text_position_y = position_y + molecule_height * CGFloat(i) + (molecule_height - astring.size().height) / 2
                        astring.drawAtPoint(CGPoint(x: text_position_x, y: text_position_y))


                }
        }

        func height_of_color_key() -> CGFloat {
                var height = 0 as CGFloat

                height = astring_body(string: "Color Key").size().height + 20 + color_key_color_height + 5

                var max_text_height = 0 as CGFloat
                for i in 0 ..< color_key.break_points.count {
                        let astring = decimal_astring(number: color_key.break_points[i], fraction_digits: 1)
                        let height = astring.size().width
                        max_text_height = max(max_text_height, height)
                }
                height += max_text_height

                return height
        }

        func draw_color_key(context context: CGContext, rect: CGRect, position_y: CGFloat) {
                if position_y > CGRectGetMaxY(rect) {
                        return
                }

                var cell_position_y = position_y
                let margin_left = margin_dendrogram
                let space_per_color = (color_key_width - 2 * margin_left) / CGFloat(color_key.color_palette.count)

                let astring = astring_body(string: "Color Key")
                let position_astring = (color_key_width - astring.size().width) / 2
                Drawing.drawAttributedText(context: context, attributedText: astring, origin: CGPoint(x: position_astring, y: cell_position_y), horizontal: true)
                cell_position_y += astring.size().height + 20

                for i in 0 ..< color_key.color_palette.count {
                        let color = color_from_hex(hex: color_key.color_palette[i])

                        CGContextSetFillColorWithColor(context, color.CGColor)
                        let cell_position_x = margin_left + space_per_color * CGFloat(i)

                        CGContextBeginPath(context)
                        CGContextMoveToPoint(context, cell_position_x, cell_position_y)
                        CGContextAddLineToPoint(context, cell_position_x + space_per_color, cell_position_y)
                        CGContextAddLineToPoint(context, cell_position_x + space_per_color, cell_position_y + color_key_color_height)
                        CGContextAddLineToPoint(context, cell_position_x, cell_position_y + color_key_color_height)
                        CGContextClosePath(context)

                        CGContextFillPath(context)
                }

                cell_position_y += color_key_color_height + 5
                for i in 0 ..< color_key.break_points.count {
                        let astring = decimal_astring(number: color_key.break_points[i], fraction_digits: 1)
                        let text_position_x = margin_left + space_per_color * CGFloat(i) + astring.size().height / 2
                        Drawing.drawAttributedText(context: context, attributedText: astring, origin: CGPoint(x: text_position_x, y: cell_position_y), horizontal: false)
                }
        }

        func scroll_view_did_end_zooming(zoom_scale zoom_scale: CGFloat) {}
        func tap_action(location location: CGPoint) {}
}
