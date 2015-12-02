//
//  ViewController.swift
//  Copyright (c) 2014 Purple Brain. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AdBuddizDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // OPTIONAL, to get more info about the SDK behavior
        AdBuddiz.setDelegate(self);
        
        // add button on screen
        let showAdButton = UIButton.buttonWithType(.System) as UIButton
        showAdButton.setTitle("Show Ad", forState: .Normal)
        showAdButton.frame = CGRectMake(30, 30, 100, 50)
        showAdButton.addTarget(self, action: "showAdClicked:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(showAdButton)
    }
    
    func showAdClicked(sender: UIButton!) {
        AdBuddiz.showAd();
    }
    
    func didCacheAd() {
        println("AdBuddizDelegate: didCacheAd")
    }
    
    func didShowAd() {
        println("AdBuddizDelegate: didShowAd")
    }
    
    func didFailToShowAd(error: AdBuddizError) {
        println("AdBuddizDelegate: didFailToShowAd : " + AdBuddiz.nameForError(error))
    }
    
    func didClick() {
        println("AdBuddizDelegate: didClick")
    }
    
    func didHideAd() {
        println("AdBuddizDelegate: didHideAd")
    }
}

