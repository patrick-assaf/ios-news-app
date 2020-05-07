//
//  TrendingViewController.swift
//  ios-news-app
//
//  Created by Patrick Assaf on 4/20/20.
//  Copyright © 2020 patrickassaf. All rights reserved.
//

import UIKit
import Charts

class TrendingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textBox: UITextField!
    @IBOutlet weak var chartView: LineChartView!
    
    var numbers : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textBox.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    @IBAction func textFieldAction(_ sender: Any) {
        self.view.endEditing(true)
        let input = Double(textBox.text!)
        numbers.append(input!)
        if(textBox.text != "") {
            updateChart()
        }
    }
    
    func updateChart() {
        
        var lineChartPoints  = [ChartDataEntry]()
        
        for i in 0..<numbers.count {
            let value = ChartDataEntry(x: Double(i), y: numbers[i])
            lineChartPoints.append(value)
        }
        
        let line = LineChartDataSet(entries: lineChartPoints, label: "Number")
        line.colors = [UIColor.systemBlue]
        line.circleColors = [UIColor.systemBlue]
        line.circleHoleColor = UIColor.systemBlue
        
        let data = LineChartData()
        data.addDataSet(line)
        
        chartView.data = data
    }
    

}
