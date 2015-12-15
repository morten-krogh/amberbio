import UIKit

class ModuleStoreState: PageState {

        override init() {
                super.init()
                name = "module_store"
                title = astring_body(string: "Donations")
                info = "The Amberbio app is free to use.\n\nDonations support hosting and development of the app.\n\nWith donations, the app can be free and benefit people across the world.\n\nPlease consider donating if the app is useful to you."

                state.store.request_products()
        }
}

class ModuleStore: Component, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

        let collection_view = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

        override func viewDidLoad() {
                super.viewDidLoad()
                
                collection_view.backgroundColor = UIColor.whiteColor()
                
                collection_view.registerClass(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
                collection_view.registerClass(CenteredViewCell.self, forCellWithReuseIdentifier: "centered cell")
                collection_view.registerClass(DonationViewCell.self, forCellWithReuseIdentifier: "donation cell")
                
                collection_view.dataSource = self
                collection_view.delegate = self
                
                view.addSubview(collection_view)
        }
        
        override func render() {
                collection_view.reloadData()
        }
        
        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()


                collection_view.collectionViewLayout.invalidateLayout()

                collection_view.frame = view.bounds
        }
        
        func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
                return 1
        }
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
                return CGSize(width: view.frame.width, height: 80)
        }
        
        func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
                let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath) as! HeaderReusableView
                let text = "Donations support the development of the app"
                header.update_normal(text: text)
                return header
        }

        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return state.store.request_products_pending ? 1 : state.store.products.count
        }
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
                if state.store.request_products_pending {
                        return CGSize(width: view.frame.width, height: 56)
                } else {
                        return CGSize(width: 175, height: 145)
                }
        }
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
                return state.store.request_products_pending ? UIEdgeInsetsZero : UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        }
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
                if state.store.request_products_pending {
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("centered cell", forIndexPath: indexPath) as! CenteredViewCell
                        let text = "Waiting for the server"
                        cell.update_unselected(text: text)
                        return cell
                } else {
                        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("donation cell", forIndexPath: indexPath) as! DonationViewCell
                        let color = color_from_hex(hex: color_brewer_qualitative_9_pastel1[5])
                        cell.update(product: state.store.products[indexPath.row], color: color)
                        return cell
                }
        }
}
