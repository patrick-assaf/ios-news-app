//
//  DetailedArticleViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 5/5/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit

class DetailedArticleViewController: UIViewController {
    
    var articleID: String = ""
    @IBOutlet weak var LabelArticleID: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LabelArticleID.text = articleID
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
