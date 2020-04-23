//
//  FirstViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {

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
                let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?q="+city+"&units=metric&appid=9031b6d8f8514c01eeaaf398a4188f8b")!
                
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
