//
//  SecondViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import XLPagerTabStrip

class HeadlinesViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 16)
        settings.style.selectedBarHeight = 3.0
        settings.style.selectedBarBackgroundColor = UIColor.systemBlue
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.gray
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.gray
            newCell?.label.textColor = UIColor.systemBlue
        }
        
        SwiftSpinner.show(duration: 3.0, title:"Loading Headlines Page...")
        
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let world = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WORLD")
        let business = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BUSINESS")
        let politics = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "POLITICS")
        let sports = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SPORTS")
        let technology = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TECHNOLOGY")
        let science = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SCIENCE")
        return [world, business, politics, sports, technology, science]
    }

}

