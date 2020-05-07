//
//  Science.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 5/6/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import XLPagerTabStrip
import Toast_Swift

class Science: UITableViewController, IndicatorInfoProvider {

    var scienceArticles: [Article] = []
    var bookmarks: [Article] = []
    var article: Article?
    var tableRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var scienceArticlesTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show(duration: 3.0, title:"Loading SCIENCE Headlines...")
        
        tableRefreshControl.attributedTitle = NSAttributedString()
        tableRefreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        scienceArticlesTable.addSubview(tableRefreshControl)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scienceArticles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ScienceTableViewCell
        
        articleCell.bookmarkButton.addTarget(self, action: #selector(bookmark(sender:)), for: .touchUpInside)
        articleCell.bookmarkButton.tag = indexPath.row
        
        let index: Int = indexPath.row
        
        articleCell.articleTitle?.text = scienceArticles[index].title
        articleCell.articleDate?.text = scienceArticles[index].date
        articleCell.articleSection?.text = "| " + scienceArticles[index].section
        displayArticleImage(index, articleCell: articleCell)
        
        return articleCell
    }
    
    @objc func bookmark(sender: UIButton!) {
        let buttonTag = sender.tag
        if(bookmarks.first(where: { $0.id == self.scienceArticles[buttonTag].id }) != nil) {
            bookmarks.removeAll(where: { $0.id == self.scienceArticles[buttonTag].id })
            sender.setImage(UIImage(systemName: "bookmark"), for: .normal)
            self.scienceArticles[buttonTag].bookmarked = false
            self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
        }
        else {
            bookmarks.append(self.scienceArticles[buttonTag])
            sender.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            self.scienceArticles[buttonTag].bookmarked = true
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index: Int = indexPath.row

        let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) {_ in
            let text = "Check out this Article!"
            let shareURL = "https://twitter.com/intent/tweet?text=\(text)&url=\(self.scienceArticles[index].url)&hashtags=CSCI_571_NewsApp"
            let escapedURL = shareURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            UIApplication.shared.open(URL(string: escapedURL)!)
        }
        
        let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) {_ in
            let buttonTag = index
            if(self.bookmarks.first(where: { $0.id == self.scienceArticles[buttonTag].id }) != nil) {
                self.bookmarks.removeAll(where: { $0.id == self.scienceArticles[buttonTag].id })
                self.scienceArticles[buttonTag].bookmarked = false
                self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
            }
            else {
                self.bookmarks.append(self.scienceArticles[buttonTag])
                self.scienceArticles[buttonTag].bookmarked = true
                self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
            }
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "Menu", children: [share, bookmark])
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = scienceArticlesTable.cellForRow(at: indexPath as IndexPath)
        scienceArticlesTable.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let index: Int = indexPath.row
        self.article = scienceArticles[index]

        performSegue(withIdentifier: "detailedArticleSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailedArticleViewController
        vc.article = self.article
    }
    
    func displayArticleImage(_ row: Int, articleCell: ScienceTableViewCell) {
        if(scienceArticles[row].imageURL != "undefined") {
            let url: String = (URL(string: scienceArticles[row].imageURL)?.absoluteString)!
            URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: {
                    let image = UIImage(data: data!)
                    articleCell.articleImage?.image = image
                })
            }).resume()
        }
        else {
            let image = UIImage(named: "default-guardian")
            articleCell.articleImage?.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let guardianURL = "http://localhost:5000/guardian-science"
        AF.request(guardianURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.scienceArticles.removeAll()
                let guardianJSON: JSON = JSON(value)
                for (key, article) in guardianJSON {
                    let id: String = article["id"].string!
                    let title: String = article["title"].string!
                    let date: String = article["date"].string!
                    let section: String = article["section"].string!
                    let img: String = article["img"].string!
                    let url: String = article["url"].string!
                    self.scienceArticles.append(Article(key: key, id: id, title: title, date: date, section: section, imageURL: img, description: "", url: url))
                }
                self.scienceArticlesTable.reloadData()
            case let .failure(error):
                print(error)
            }
        }
        
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        let guardianURL = "http://localhost:5000/guardian-science"
        AF.request(guardianURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.scienceArticles.removeAll()
                let guardianJSON: JSON = JSON(value)
                for (key, article) in guardianJSON {
                    let id: String = article["id"].string!
                    let title: String = article["title"].string!
                    let date: String = article["date"].string!
                    let section: String = article["section"].string!
                    let img: String = article["img"].string!
                    let url: String = article["url"].string!
                    self.scienceArticles.append(Article(key: key, id: id, title: title, date: date, section: section,  imageURL: img, description: "", url: url))
                }
                self.scienceArticlesTable.reloadData()
                self.tableRefreshControl.endRefreshing()
            case let .failure(error):
                print(error)
            }
        }
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SCIENCE")
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
