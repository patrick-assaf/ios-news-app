//
//  DetailedArticleViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 5/5/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DetailedArticleViewController: UIViewController {
    
    var articleID: String = ""
    var articleURL: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var sectionView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let guardianURL = "http://localhost:5000/guardian-\(articleID.replacingOccurrences(of: "/", with: "~"))"
        AF.request(guardianURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                let article: JSON = JSON(value)
                
                let img: String = article["img"].string!
                let title: String = article["title"].string!
                let description: String = article["description"].string!
                let date: String = article["date"].string!
                let section: String = article["section"].string!
                let url: String = article["url"].string!
                
                self.titleView.text = title
                self.sectionView.text = section
                self.dateView.text = date
                self.descriptionView.text = description
                self.articleURL = url
                
                if(img != "undefined") {
                    let url: String = img
                    URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
                        if error != nil {
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async(execute: {
                            let image = UIImage(data: data!)
                            self.imageView.image = image
                        })
                    }).resume()
                }
                else {
                    let image = UIImage(named: "default-guardian")
                    self.imageView.image = image
                }
                
            case let .failure(error):
                print(error)
            }
        }
        
        super.viewWillAppear(animated)
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
