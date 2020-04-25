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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

    let locationManager = CLLocationManager()
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var weatherInformation: UIView!
    @IBOutlet weak var weatherBackground: UIImageView!
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
