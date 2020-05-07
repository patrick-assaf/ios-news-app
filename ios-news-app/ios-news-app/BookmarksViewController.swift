//
//  BookmarksViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import SwiftSpinner

class BookmarksViewController: UIViewController {
    
    var myHomeViewController: HomeViewController = HomeViewController(nibName: nil, bundle: nil)
    
    var articleID: String = ""
    var bookmarkedArticles: [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
         SwiftSpinner.show(duration: 3.0, title:"Loading Bookmarks Page...")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let homeArticles = myHomeViewController.bookmarks
        bookmarkedArticles.append(contentsOf: homeArticles)
    }
    
    


}
