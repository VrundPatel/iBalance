//
//  ChartViewController.swift
//  iBalance
//
//  Created by Vrund Patel on 1/20/16.
//  Copyright © 2016 VrundPatel. All rights reserved.
//

import Foundation
import UIKit
import Charts

class ChartViewController: UIViewController {

    @IBOutlet var chartView: BarChartView!
    
    @IBAction func backButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    var time: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        time = ["0", "4", "8", "12", "16", "20"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        setChart(time, values: unitsSold)
    }
    
    
    func setChart(dataPoints: [String], values: [Double]) {
        chartView.noDataText = "You need to provide data for the chart."
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
