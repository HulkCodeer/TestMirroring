//
//  ChargerImageViewController.swift
//  evInfra
//
//  Created by Shin Park on 25/01/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Charts

class ChargerImageViewController: UIViewController {
    
    var charger: Charger? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(charger: Charger, index: Int) {
        super.init(nibName: nil, bundle: nil)
        
        self.charger = charger
        
        if index == 0 {
            getSatellite()
        } else if !(self.charger?.usage.isEmpty)! {
            getChart()
        }
    }
    
    // 인공위성 사진
    func getSatellite() {
        let satelliteUrl = URL(string: Const.IMG_URL_SATELLITE + (self.charger?.chargerId)! + ".jpg")
        Server.getData(url: satelliteUrl!) { (isSuccess, responseData) in
            if isSuccess {
                // Show the downloaded image:
                if let data = responseData {
                    print("download image size = \(data)")
                    let imageView = UIImageView()
                    self.view.addSubview(imageView)
                    self.view.constrainToEdges(imageView)
                    if(data.count != 243) {
                        imageView.image = UIImage(data: data)
                    } else {
                        imageView.image = UIImage(named: "ready_image")
                        imageView.contentMode = .scaleAspectFit
                    }
                }
            }
            
        }
    }
    
    // 이용률 그래프
    func getChart() {
        let chartView = BarChartView()
        self.view.addSubview(chartView)
        self.view.constrainToEdges(chartView)
        
        setup(barLineChartView: chartView)
        setAxis(barLineChartView: chartView)
        setDataCount(chartView: chartView, 24)
        
//        chartView.drawBarShadowEnabled = false
//        chartView.drawValueAboveBarEnabled = false
    }
    
    func setup(barLineChartView chartView: BarLineChartViewBase) {
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = false
        
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        
        chartView.maxVisibleCount = 60
    }
    
    func setAxis(barLineChartView chartView: BarLineChartViewBase) {
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 12
        xAxis.valueFormatter = HourAxisValueFormatter()
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = "%"
        leftAxisFormatter.positiveSuffix = "%"
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        leftAxis.axisMaximum = 100
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.drawLabelsEnabled = false
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 100
    }
    
    func setDataCount(chartView: BarLineChartViewBase, _ count: Int) {
        let start = 0
        
        let yVals = (start..<start + count).map { (i) -> BarChartDataEntry in
            let val = self.charger?.usage[i]
            return BarChartDataEntry(x: Double(i), y: Double(val!))
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "The year 2019")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            chartView.data = data
        }
    }
}

extension ChargerImageViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        NSLog("chartValueSelected");
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected");
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}
