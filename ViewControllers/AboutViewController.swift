//
//  AboutViewController.swift
//  TV Tracker
//
//  Created by Adeem on 10/26/18.
//  Copyright © 2018 Adeem. All rights reserved.
//

import UIKit
import StoreKit

class AboutViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var removeAdsButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    let iapProductID = "removeAds"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        removeAdsButton.layer.cornerRadius = 3
        removeAdsButton.layer.borderWidth = 1
        removeAdsButton.layer.borderColor = UIColor.white.cgColor
        removeAdsButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        restorePurchaseButton.layer.cornerRadius = 5
        restorePurchaseButton.layer.borderWidth = 1
        restorePurchaseButton.layer.borderColor = UIColor.white.cgColor
        restorePurchaseButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        let gradient1 = UIColor(red:0.06, green:0.10, blue:0.32, alpha:1.0)
        let gradient2 = UIColor(red:0.00, green:0.25, blue:0.49, alpha:1.0)
        let gradient3 = UIColor(red:0.00, green:0.41, blue:0.63, alpha:1.0)
        let gradient4 = UIColor(red:0.00, green:0.57, blue:0.71, alpha:1.0)
        let gradient5 = UIColor(red:0.00, green:0.73, blue:0.73, alpha:1.0)
        let gradient6 = UIColor(red:0.13, green:0.87, blue:0.71, alpha:1.0)
        
        let pastelView = PastelView(frame: view.bounds)
        pastelView.startPastelPoint = .topLeft
        pastelView.endPastelPoint = .bottomRight
        pastelView.animationDuration = 3.0
        pastelView.setColors([gradient1, gradient2, gradient3, gradient4, gradient5, gradient6, gradient5, gradient4, gradient3, gradient2])
        pastelView.startAnimation()
        
        view.insertSubview(pastelView, at: 0)
    }
    
    @IBAction func removeAdsClicked(_ sender: Any) {
        if (SKPaymentQueue.canMakePayments())
        {
            let productID = NSSet(object: iapProductID)
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    @IBAction func restorePurchaseClicked(_ sender: Any) {
        if (SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    func buyProduct(product: SKProduct){
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            let validProduct: SKProduct = response.products[0] as SKProduct
            
            if (validProduct.productIdentifier == self.iapProductID) {
                buyProduct(product: validProduct)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                    case .purchased:
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        UserDefaults.standard.set(true , forKey: "removeAds")
                        break;
                    
                    case .failed:
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        break;
                    
                    case .restored:
                        SKPaymentQueue.default().restoreCompletedTransactions()
                        UserDefaults.standard.set(true , forKey: "removeAds")
                        break;
                    
                    default:
                        break;
                }
            }
        }
    }
}

