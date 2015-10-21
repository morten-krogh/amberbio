//
//  Store.swift
//  Amberbio
//
//  Created by Morten Krogh on 21/10/15.
//  Copyright © 2015 Morten Krogh. All rights reserved.
//

import Foundation
import StoreKit

let store_product_ids = [
        "com.amberbio.product.svm",
        "com.amberbio.product.pca"
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

        var products = [] as [SKProduct]

        func fetch_products() {
                let products_request = SKProductsRequest(productIdentifiers: Set<String>(store_product_ids))
                products_request.delegate = self
                products_request.start()
        }

        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
                products = response.products
                for invalid_product_id in response.invalidProductIdentifiers {
                        print("Invalid product id: \(invalid_product_id)")
                }
        }



        func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        }






}
