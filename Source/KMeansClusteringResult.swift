import UIKit

class KMeansClusteringResultState: PageState {

        let k_means: KMeans

        init(k_means: KMeans) {
                self.k_means = k_means
                super.init()
                name = "k_means_clustering_result"
                title = astring_body(string: "k means clustering")
                info = "Create a new factor from the clusters by tapping the button \"Create new factor\".\n\nEach cluster will become a level.\n\nEdit the new factor on the page \"Edit factors\" if necessary."

                png_enabled = true
                full_screen = .Conditional
                prepared = false
        }

        override func prepare() {
                k_means.cluster()

                prepared = true
        }
}

class KMeansClusteringResult: Component, UICollectionViewDataSource, UICollectionViewDelegate {

        var k_means: KMeans!

        let create_new_factor_button = UIButton(type: .System)
        let collection_view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

        override func viewDidLoad() {
                super.viewDidLoad()

                create_new_factor_button.setAttributedTitle(astring_body(string: "Create new factor"), forState: .Normal)
                create_new_factor_button.addTarget(self, action: "create_new_factor_action", forControlEvents: .TouchUpInside)
                view.addSubview(create_new_factor_button)

                collection_view.backgroundColor = UIColor.whiteColor()
                collection_view.registerClass(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
                collection_view.registerClass(TwoLabelColorCellView.self, forCellWithReuseIdentifier: "cell")
                view.addSubview(collection_view)
        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()

                let width = view.frame.width
                let height = view.frame.height

                create_new_factor_button.sizeToFit()
                create_new_factor_button.frame.origin = CGPoint(x: (width - create_new_factor_button.frame.width) / 2, y: 20)

                let origin_y = CGRectGetMaxY(create_new_factor_button.frame) + 20

                collection_view.frame = CGRect(x: 0, y: origin_y, width: width, height: height - origin_y)
        }

        override func render() {
                self.k_means = (state.page_state as! KMeansClusteringResultState).k_means
                collection_view.dataSource = self
                collection_view.delegate = self
        }

        func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
                return k_means.clusters.count
        }

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
                return CGSize(width: view.frame.width, height: 50)
        }

        func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! HeaderView

                let section = indexPath.section + 1
                let title = "Cluster \(section)"
                header.update(title: title)

                return header
        }

        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return k_means.clusters[section].count
        }

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
                return two_label_color_cell_view_size
        }

        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
                return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)

        }

        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TwoLabelColorCellView

                let sample_index = k_means.clusters[indexPath.section][indexPath.row]
                let sample_name = state.sample_names[sample_index]
                let level_name: String?
                let color: UIColor
                if k_means.selected_row == 0 {
                        level_name = nil
                        color = color_success
                } else {
                        let factor_index = k_means.selected_row - 1
                        level_name = state.level_names_by_factor_and_sample[factor_index][sample_index]
                        color = color_from_hex(hex: state.level_colors_by_factor_and_sample[factor_index][sample_index])
                }

                cell.update(text_1: sample_name, text_2: level_name, color: color)

                return cell
        }

        func create_new_factor_action() {
                let factor_name = "\(k_means.k) k-mean-clusters"
                var level_names_of_samples = [] as [String]
                for cluster in k_means.cluster_for_sample {
                        let level_name = "cluster \(cluster + 1)"
                        level_names_of_samples.append(level_name)
                }
                let factor_id = state.insert_factor(project_id: state.project_id, factor_name: factor_name, level_names_of_samples: level_names_of_samples)
                let page_state = FactorSummaryDetailState(factor_id: factor_id)
                state.navigate(page_state: page_state)
                state.render()
        }

        func png_action() {
                let frame = collection_view.frame
                let super_view = collection_view.superview

                let view = UIView(frame: CGRect(origin: CGPoint.zero, size: collection_view.contentSize))
                collection_view.removeFromSuperview()
                collection_view.frame = view.frame
                view.addSubview(collection_view)

                UIGraphicsBeginImageContext(collection_view.contentSize)
                let context = UIGraphicsGetCurrentContext()!
                collection_view.layer.renderInContext(context)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                collection_view.removeFromSuperview()
                super_view?.addSubview(collection_view)
                collection_view.frame = frame

                if let data = UIImagePNGRepresentation(image) {
                        state.insert_png_result_file(file_name_stem: "k-means-clustering", file_data: data)
                }
                state.render()
        }
}
