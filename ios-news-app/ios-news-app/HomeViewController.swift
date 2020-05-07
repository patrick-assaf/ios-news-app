//
//  FirstViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftSpinner

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var homeArticles: [Article] = []
    var articleID: String = ""
    var refreshControl = UIRefreshControl()

    let locationManager = CLLocationManager()
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var weatherInformation: UIView!
    @IBOutlet weak var weatherBackground: UIImageView!
    @IBOutlet weak var homeArticlesTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                let placemark = placemarks?.first
                let city = placemark?.locality ?? ""
                let state = placemark?.administrativeArea ?? ""
                var temperature: Int = 0
                var summary: String = ""
                
                let weatherAPIKey = "9031b6d8f8514c01eeaaf398a4188f8b"
                let weatherURL = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(weatherAPIKey)"
                let requestURL = weatherURL.replacingOccurrences(of: " ", with: "%20")
                AF.request(requestURL).responseJSON { response in
                    switch response.result {
                    case let .success(value):
                        let weatherJSON: JSON = JSON(value)
                        summary = weatherJSON["weather"][0]["main"].stringValue
                        temperature = Int(weatherJSON["main"]["temp"].doubleValue)
                        self.temperatureLabel.text = "\(temperature)°C"
                        self.summaryLabel.text = "\(summary)"
                        
                        switch summary {
                        case "Clouds":
                            self.weatherBackground.image = UIImage(named: "cloudy_weather")
                        case "Clear":
                            self.weatherBackground.image = UIImage(named: "clear_weather")
                        case "Snow":
                            self.weatherBackground.image = UIImage(named: "snowy_weather")
                        case "Rain":
                            self.weatherBackground.image = UIImage(named: "rainy_weather")
                        case "Thunderstorm":
                            self.weatherBackground.image = UIImage(named: "thunder_weather")
                        default:
                            self.weatherBackground.image = UIImage(named: "sunny_weather")
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
                
                DispatchQueue.main.async {
                    self.cityLabel.text = "\(city)"
                    self.stateLabel.text = "\(state)"
                }
                
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! HomeArticlesTableViewCell
        
        let index: Int = indexPath.row
        
        articleCell.articleTitle?.text = homeArticles[index].title
        articleCell.articleDate?.text = homeArticles[index].date
        articleCell.articleSection?.text = "| " + homeArticles[index].section
        displayArticleImage(index, articleCell: articleCell)
        
        return articleCell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let index: Int = indexPath.row

        let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) {_ in
            let text = "Check out this Article!"
            let shareURL = "https://twitter.com/intent/tweet?text=\(text)&url=\(self.homeArticles[index].url)&hashtags=CSCI_571_NewsApp"
            let escapedURL = shareURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            UIApplication.shared.open(URL(string: escapedURL)!)
        }
        
        let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) {_ in
            print("bookmarking" + self.homeArticles[index].id)
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "Menu", children: [share, bookmark])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = homeArticlesTable.cellForRow(at: indexPath as IndexPath)
        homeArticlesTable.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let index: Int = indexPath.row
        self.articleID = homeArticles[index].id

        performSegue(withIdentifier: "detailedArticleSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailedArticleViewController
        vc.articleID = self.articleID
    }
    
    func displayArticleImage(_ row: Int, articleCell: HomeArticlesTableViewCell) {
        if(homeArticles[row].imageURL != "undefined") {
            let url: String = (URL(string: homeArticles[row].imageURL)?.absoluteString)!
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
        
        let guardianURL = "http://localhost:5000/guardian-home"
        AF.request(guardianURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.homeArticles.removeAll()
                let guardianJSON: JSON = JSON(value)
                for (key, article) in guardianJSON {
                    let id: String = article["id"].string!
                    let title: String = article["title"].string!
                    let date: String = article["date"].string!
                    let section: String = article["section"].string!
                    let img: String = article["img"].string!
                    let url: String = article["url"].string!
                    self.homeArticles.append(Article(key: key, id: id, title: title, date: date, section: section, imageURL: img, description: "", url: url))
                }
                self.homeArticlesTable.reloadData()
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
        let guardianURL = "http://localhost:5000/guardian-home"
        AF.request(guardianURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.homeArticles.removeAll()
                let guardianJSON: JSON = JSON(value)
                for (key, article) in guardianJSON {
                    let id: String = article["id"].string!
                    let title: String = article["title"].string!
                    let date: String = article["date"].string!
                    let section: String = article["section"].string!
                    let img: String = article["img"].string!
                    let url: String = article["url"].string!
                    self.homeArticles.append(Article(key: key, id: id, title: title, date: date, section: section,  imageURL: img, description: "", url: url))
                }
                self.homeArticlesTable.reloadData()
                self.refreshControl.endRefreshing()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show(duration: 3.0, title:"Loading Home Page...")
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        searchBar.delegate = self
        weatherInformation.layoutIfNeeded()
        weatherInformation.layer.cornerRadius = 10
        weatherInformation.layer.masksToBounds = true
        refreshControl.attributedTitle = NSAttributedString()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        homeArticlesTable.addSubview(refreshControl)
        
    }

    
    
}
