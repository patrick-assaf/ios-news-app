//
//  FirstViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import CoreLocation

struct WeatherInfo:Decodable {
    var temp: Int
    var main: String
}

enum WeatherError:Error {
    case noDataAvailable
    case canNotProcessData
}

struct WeatherRequest {
    let url: URL
    let api_key = "9031b6d8f8514c01eeaaf398a4188f8b"
    
    init(city: String) {
        let resourceURL = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(api_key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: resourceURL!)
        self.url = url!
    }
    
    func getWeather (completion: @escaping(Result<WeatherInfo, WeatherError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherInfo = try decoder.decode(WeatherInfo.self, from: jsonData)
                let weatherDetails = weatherInfo
                completion(.success(weatherDetails))
            } catch {
                completion(.failure(.canNotProcessData))
                return
            }
            
        }
        dataTask.resume()
    }
}

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    var weatherList = [WeatherInfo]()

    let locationManager = CLLocationManager()
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
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
                DispatchQueue.main.async {
                    self.cityLabel.text = "\(city)"
                    self.stateLabel.text = "\(state)"
                }
                
                let weatherRequest = WeatherRequest(city: city)
                weatherRequest.getWeather { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let weather):
                        self?.weatherList[0] = weather
                    }
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
