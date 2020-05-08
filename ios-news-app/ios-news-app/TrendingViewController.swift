//
//  TrendingViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON
import SwiftSpinner

class TrendingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var chartView: LineChartView!
    
    var numbers: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textBox.delegate = self
        
        SwiftSpinner.show(duration: 3.0, title:"Loading Trending Page...")
        
        let googleTrendsURL = "http://assafp-nodejs.us-east-1.elasticbeanstalk.com/google-coronavirus"
        AF.request(googleTrendsURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.numbers.removeAll()
                let googleJSON: JSON = JSON(value)
                for i in 0..<googleJSON.count {
                    let value: String = googleJSON[i].string!
                    if let number = Double(value) {
                        self.numbers.append(number)
                    }
                }
                self.updateChart(keyword: "Coronavirus")
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    @IBAction func textFieldAction(_ sender: Any) {
        self.view.endEditing(true)
        let input = String(textBox.text!)
        if(textBox.text != "") {
            fetchNewKeywordTrend(keyword: input)
        }
    }
    
    func fetchNewKeywordTrend(keyword: String) {
        let googleTrendsURL = "http://assafp-nodejs.us-east-1.elasticbeanstalk.com/google-\(keyword)"
        AF.request(googleTrendsURL).responseJSON { response in
            switch response.result {
            case let .success(value):
                self.numbers.removeAll()
                let googleJSON: JSON = JSON(value)
                for i in 0..<googleJSON.count {
                    let value: String = googleJSON[i].string!
                    if let number = Double(value) {
                        self.numbers.append(number)
                    }
                }
                self.updateChart(keyword: keyword)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func updateChart(keyword: String) {
        
        var lineChartPoints  = [ChartDataEntry]()
        
        for i in 0..<numbers.count {
            let value = ChartDataEntry(x: Double(i), y: numbers[i])
            lineChartPoints.append(value)
        }
        
        let line = LineChartDataSet(entries: lineChartPoints, label: "Trending Chart for \(keyword)")
        line.colors = [UIColor.systemBlue]
        line.circleColors = [UIColor.systemBlue]
        line.circleHoleColor = UIColor.systemBlue
        
        let data = LineChartData()
        data.addDataSet(line)
        
        chartView.data = data
    }
    

}
