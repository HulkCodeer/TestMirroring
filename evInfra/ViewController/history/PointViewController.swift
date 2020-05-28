//
//  PointViewController.swift
//  evInfra
//
//  Created by Shin Park on 11/10/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

import UIKit
import M13Checkbox
import Material
import SwiftyJSON

class PointViewController: UIViewController {
    
    @IBOutlet weak var textFieldStartDate: UITextField!
    @IBOutlet weak var textFieldEndDate: UITextField!
    
    @IBOutlet weak var cbAllDuration: M13Checkbox!
    @IBOutlet weak var viewAllDuration: UIView!
    
    @IBOutlet weak var cbSaveDuration: M13Checkbox!
    @IBOutlet weak var viewSaveDuration: UIView!
    
    @IBOutlet weak var cbUseDuration: M13Checkbox!
    @IBOutlet weak var viewUseDuration: UIView!
    
    
    
    @IBOutlet weak var labelTotalPoint: UILabel!
    @IBOutlet weak var labelResultMsg: UILabel!
    
    @IBOutlet weak var pointTableView: UITableView!
    
    var textFieldDate: UITextField!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let FILTER_POINT_USED = 0
    let FILTER_POINT_SAVE = 1
    let FILTER_POINT_ALL = 2
    
    var selectiedFilter:Int = 0
    
    var evPointList: Array<EvPoint> = Array<EvPoint>()
    var evFilteredList:[EvPoint] = []
    
    struct PointHistory: Decodable {
        var code: Int?
        var msg: String?
        var total_point = "0"
        var list: [EvPoint]?
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareDatePicker()
        prepareCheckBox()
        prepareTableView()
        
        // 오늘 포인트 이력 가져오기
        let currentDate = Date()
        getPointHistory(isAllDate: false, startDate: currentDate, endDate: currentDate)
        
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "포인트 조회"
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    fileprivate func prepareCheckBox() {
        cbAllDuration.boxType = .square
        cbAllDuration.checkState = .unchecked
        cbAllDuration.tintColor = UIColor(rgb: 0x15435C)
        
        cbSaveDuration.boxType = .square
        cbSaveDuration.checkState = .unchecked
        cbSaveDuration.tintColor = UIColor(rgb: 0x15435C)
        
        cbUseDuration.boxType = .square
        cbUseDuration.checkState = .unchecked
        cbUseDuration.tintColor = UIColor(rgb: 0x15435C)
        
        viewAllDuration.addTapGesture(target: self, action: #selector(onClickCbAllDuration(_:)))
        viewSaveDuration.addTapGesture(target: self, action: #selector(onClickCbSaveDuration(_:)))
        viewUseDuration.addTapGesture(target: self, action: #selector(onClickCbUseDuration(_:)))
        
    }
    
    @objc fileprivate func onClickCbAllDuration(_ sender: UITapGestureRecognizer) {
            cbAllDuration.toggleCheckState(true)
    }
    
    @objc fileprivate func onClickCbSaveDuration(_ sender: UITapGestureRecognizer) {
            cbSaveDuration.toggleCheckState(true)
    }
    
    @objc fileprivate func onClickCbUseDuration(_ sender: UITapGestureRecognizer) {
            cbUseDuration.toggleCheckState(true)
    }
    
    // 조회
    @IBAction func onClickQuery(_ sender: Any) {
        let startDate = dateFormatter.date(from: textFieldStartDate.text!)!
        let endDate = dateFormatter.date(from: textFieldEndDate.text!)!
        let isAllDuration = cbAllDuration.checkState == .checked ? true : false
        let isSavePoint = cbSaveDuration.checkState == .checked ? true : false
        let isUsePoint = cbUseDuration.checkState == .checked ? true : false
        
        if isAllDuration == true {
            getPointHistory(isAllDate: isAllDuration, startDate: startDate, endDate: endDate)
        }
        if isSavePoint == true && isUsePoint == false{
            selectiedFilter = FILTER_POINT_SAVE
            updatePointList()
        }
        if isUsePoint == true && isSavePoint == false{
            selectiedFilter = FILTER_POINT_USED
            updatePointList()
        }
        if isSavePoint == true && isUsePoint == true {
            selectiedFilter = FILTER_POINT_ALL
            updatePointList()
        }
    }
    
    // 당일
    @IBAction func onClickToday(_ sender: Any) {
        cbAllDuration.checkState = .unchecked
        
        let currentDate = Date()
        getPointHistory(isAllDate: false, startDate: currentDate, endDate: currentDate)
    }

    // 당월
    @IBAction func onClickCurMonth(_ sender: Any) {
        cbAllDuration.checkState = .unchecked
        
        let startDate = Date().getThisMonthStart()!
        let endDate = Date()
        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
    }
    
    // 전월
    @IBAction func onClickLastMonth(_ sender: Any) {
        cbAllDuration.checkState = .unchecked
        
        let startDate = Date().getLastMonthStart()!
        let endDate = Date().getLastMonthEnd()!
        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
    }

    // 당해년도
    @IBAction func onClickThisYear(_ sender: Any) {
        cbAllDuration.checkState = .unchecked
        
        let startDate = Date().getThisYearStart()!
        let endDate = Date()
        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
    }
}

extension PointViewController {
    fileprivate func prepareDatePicker() {
        let locale = Locale(identifier: "ko_KO")
        
        self.datePicker.datePickerMode = .date
        self.datePicker.locale = locale
        
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.locale = locale
    }
    
    @IBAction func onClickStartDate(_ sender: Any) {
        self.textFieldDate = textFieldStartDate
        createDatePicker()
    }
    
    @IBAction func onClickEndDate(_ sender: Any) {
        self.textFieldDate = textFieldEndDate
        createDatePicker()
    }
    
    fileprivate func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([btnDone], animated: false)
        
        self.datePicker.date = self.dateFormatter.date(from: self.textFieldDate.text!)!
        
        self.textFieldDate.inputAccessoryView = toolbar
        self.textFieldDate.inputView = self.datePicker
    }
    
    @objc func donePressed(_ sender: Any) {
        self.textFieldDate.text = self.dateFormatter.string(from: self.datePicker.date)
        self.view.endEditing(true)
    }
    
    fileprivate func getPointHistory(isAllDate: Bool, startDate: Date, endDate: Date) {
//        evPointList.removeAll()
        self.textFieldStartDate.text = self.dateFormatter.string(from: startDate)
        self.textFieldEndDate.text =  self.dateFormatter.string(from: endDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let sDate = formatter.string(from: startDate) + " 00:00:00"
        let eDate = formatter.string(from: endDate) + " 23:59:59"
        
        Server.getPointHistory(isAllDate: isAllDate, sDate: sDate, eDate: eDate) { (isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    let pointHistory = try! JSONDecoder().decode(PointHistory.self, from: data)
                    if pointHistory.code != 1000 {
                        self.labelResultMsg.visible()
                        self.labelResultMsg.text = pointHistory.msg
                    }
                    
                    // 나의 잔여 포인트
                    self.labelTotalPoint.text = "\(pointHistory.total_point)".currency()
                    self.updatePointList(pointHistory: pointHistory);
                    print("getPointHistory_server")
                }
            }
        }
        updatePointList()
    }
//
    func getUsedPointList() -> PointHistory{
//        if let list = evFilteredList.list{
        var pointHistory = PointHistory()
        for i in self.evPointList {
            if i.action == "used"{
                evFilteredList.append(i)
                }
            }
//        }
       pointHistory.list = evFilteredList
        print("getUsedPointList")
        return pointHistory
    }
//
    func getSavePointList() -> PointHistory{
         var pointHistory = PointHistory()
            for i in self.evPointList {
                if i.action == "save"{
                    evFilteredList.append(i)
                    }
                }
        pointHistory.list = evFilteredList
        print("getSavePointList")
        return pointHistory
    }
//
    fileprivate func updatePointList(){
        
        switch selectiedFilter {
        case FILTER_POINT_USED:
            updatePointList(pointHistory: getUsedPointList())
            print("updatePointList -> FILTER_POINT_USED")
            break
        case FILTER_POINT_SAVE:
            updatePointList(pointHistory: getSavePointList())
            print("updatePointList -> FILTER_POINT_SAVE")
            break
        case FILTER_POINT_ALL:
            print("updatePointList -> FILTER_POINT_ALL")
            updatePointList(pointHistory: PointHistory())
            break
            
        default:
            print("updatePointList_default")
            break
        }
    }
    
    fileprivate func updatePointList(pointHistory: PointHistory) {
        evPointList.removeAll()
        if let list = pointHistory.list {
            print("updatePointList_pointHistory_list", list)
            
            if list.isEmpty {
                pointTableView.isHidden = true
            } else {
                evPointList = list
                pointTableView.isHidden = false
            }
        } else {
            pointTableView.isHidden = true
        }
        pointTableView.reloadData()
    }
}

extension PointViewController: UITableViewDelegate, UITableViewDataSource {
    func prepareTableView() {
        pointTableView.delegate = self
        pointTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evPointList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointTableViewCell", for: indexPath) as! PointTableViewCell
        cell.reloadData(evPoint: evPointList[indexPath.row])
        
        return cell
    }
}

