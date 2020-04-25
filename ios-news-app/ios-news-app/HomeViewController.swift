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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var homeArticles: [Article] = []

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
        articleCell.articleSection?.text = homeArticles[index].section
        displayArticleImage(index, articleCell: articleCell)
        
        return articleCell
    }
    
    func displayArticleImage(_ row: Int, articleCell: HomeArticlesTableViewCell) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        homeArticlesTable.reloadData()
        
        let guardianURL = "http://assafp-nodejs.us-east-1.elasticbeanstalk.com/guardian-home"
        AF.request(guardianURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                let guardianJSON: JSON = JSON(value)
                print(guardianJSON)
                
            case let .failure(error):
                print(error)
            }
        }
        
        if homeArticles.count == 0 {
            homeArticles.append(Article(key: "", id: "0", title: "Dummy Article", date: "Today", section: "Testing", imageURL: "https://assets.guim.co.uk/images/eada8aa27c12fe2d5afa3a89d3fbae0d/fallback-logo.png", description: ""))
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        searchBar.delegate = self
        weatherInformation.layoutIfNeeded()
        weatherInformation.layer.cornerRadius = 10
        weatherInformation.layer.masksToBounds = true
    }


}
