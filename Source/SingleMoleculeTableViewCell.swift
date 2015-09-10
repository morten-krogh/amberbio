import UIKit

let single_molecule_table_view_cell_height = 500 as CGFloat

class SingleMoleculeTableViewCell: UITableViewCell {

        var molecule_name = ""
        var factor_name: String?
        var annotation_names = [] as [String]
        var molecule_annotation_values = [] as [String]

        let inset_view = UIView()

        let info_label = UILabel()
        var pdf_txt_buttons: PdfTxtButtons!

        let tiled_scroll_view = TiledScrollView(frame: CGRect.zero)
        var single_molecule_plot: SingleMoleculePlot?

        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)

                contentView.backgroundColor = UIColor.whiteColor()

                inset_view.clipsToBounds = true
                inset_view.layer.cornerRadius = 20
                inset_view.layer.borderWidth = 1
                inset_view.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0).CGColor
                contentView.addSubview(inset_view)

                info_label.numberOfLines = 7
                info_label.textAlignment = .Center
                info_label.font = font_footnote
                inset_view.addSubview(info_label)

                pdf_txt_buttons = PdfTxtButtons(target: self, pdf_action: "pdf_action", txt_action: nil)
                inset_view.addSubview(pdf_txt_buttons)

                inset_view.addSubview(tiled_scroll_view)

        }

        required init(coder aDecoder: NSCoder) {fatalError("This initializer should not be called")}

        override func layoutSubviews() {
                super.layoutSubviews()

                inset_view.frame = CGRectInset(contentView.bounds, 10, 5)

                let inset_width = inset_view.frame.width
                let inset_height = inset_view.frame.height

                let top_margin = 5 as CGFloat
                let margin = 20 as CGFloat

                info_label.sizeToFit()

                info_label.center = CGPoint(x: inset_view.frame.width / 2.0, y: top_margin + info_label.frame.height / 2.0)

                var origin_y = CGRectGetMaxY(info_label.frame)

                pdf_txt_buttons.frame.size = pdf_txt_buttons.contentSize
                pdf_txt_buttons.frame.origin = CGPoint(x: (inset_width - pdf_txt_buttons.contentSize.width) / 2, y: origin_y)

                origin_y += pdf_txt_buttons.contentSize.height + 5

                if let single_molecule_plot = single_molecule_plot {
                        let single_molecule_rect = CGRect(x: margin, y: origin_y, width: inset_width - 2 * margin, height: inset_height - origin_y)

                        let zoom_horizontal = max(0.2, min(1, single_molecule_rect.width / single_molecule_plot.content_size.width))
                        let zoom_vertical = max(0.2, min(1, single_molecule_rect.height / single_molecule_plot.content_size.height))

                        single_molecule_plot.minimum_zoom_scale = min(zoom_horizontal, zoom_vertical)

                        tiled_scroll_view.frame = single_molecule_rect
                        tiled_scroll_view.scroll_view.zoomScale = single_molecule_plot.minimum_zoom_scale
                }
        }

        func update(molecule_name molecule_name: String, factor_name: String?, annotation_names: [String], molecule_annotation_values: [String], single_plot_names: [String], single_plot_colors: [[UIColor]], single_plot_values: [[Double]]) {
                self.molecule_name = molecule_name
                self.factor_name = factor_name
                self.annotation_names = annotation_names
                self.molecule_annotation_values = molecule_annotation_values
                var info = "Molecule name: \(molecule_name)"
                for i in 0 ..< min(annotation_names.count, 3) {
                        let annotation_name = annotation_names[i]
                        let value = molecule_annotation_values[i]
                        info += "\n\(annotation_name): \(value)"
                }
                info_label.text = info

                single_molecule_plot = SingleMoleculePlot(names: single_plot_names, colors: single_plot_colors, values: single_plot_values)
                tiled_scroll_view.delegate = single_molecule_plot
        }

        func pdf_action() {
                let file_name_stem = "single-molecule-plot"

                var description = "Plot of molecule \(molecule_name).\n"
                if let factor_name = factor_name {
                        description += " The factor is \(factor_name).\n"
                }

                for i in 0 ..< annotation_names.count {
                        let annotation_name = annotation_names[i]
                        let value = molecule_annotation_values[i]
                        let text = "\(annotation_name): \(value).\n"
                        description += text
                }

                if let single_molecule_plot = single_molecule_plot {
                        state.insert_pdf_result_file(file_name_stem: file_name_stem, description: description, content_size: single_molecule_plot.content_size, draw: single_molecule_plot.draw)
                }
                state.render()
                

        }
}
