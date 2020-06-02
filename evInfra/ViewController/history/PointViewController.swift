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
    
    @IBOutlet weak var btnAllBerry: UIButton!
    
    @IBOutlet weak var btnSaveBerry: UIButton!
    
    @IBOutlet weak var btnUseBerry: UIButton!
    
    @IBOutlet weak var labelTotalPoint: UILabel!
    @IBOutlet weak var labelResultMsg: UILabel!
    
    @IBOutlet weak var pointTableView: UITableView!
    
    var textFieldDate: UITextField!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    // btn click state
    let FILTER_POINT_ALL = 0
    let FILTER_POINT_SAVE = 1
    let FILTER_POINT_USED = 2
    
    var selectiedFilter:Int = 0
    
    var evPointList: Array<EvPoint> = Array<EvPoint>()
    var pointData: [EvPoint] = []
    
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
        prepareTableView()
        
        // 오늘 포인트 이력 가져오기
        let currentDate = Date()
        getPointHistory(isAllDate: false, startDate: currentDate, endDate: currentDate)
        
        // btn border, change color
        btnState()
        
        // change btn selected default
        btnAllBerry.isSelected = true
        btnUseBerry.isSelected = false
    }
    func btnState() {
        // border
        btnAllBerry.roundCorners([.topLeft, .bottomLeft], radius: 8, borderColor: hexStringToUIColor(hex: "#CECECE"), borderWidth:2)
        btnAllBerry.clipsToBounds = true
        btnUseBerry.roundCorners(.allCorners, radius: 0, borderColor: hexStringToUIColor(hex: "#CECECE"), borderWidth:2)
        btnUseBerry.clipsToBounds = true
        btnSaveBerry.roundCorners([.topRight, .bottomRight], radius: 8, borderColor: hexStringToUIColor(hex: "#CECECE"), borderWidth:2)
        btnSaveBerry.clipsToBounds = true
        
        // Bg color change
        btnAllBerry.setBackgroundColor(hexStringToUIColor(hex: "#CECECE"), for: .selected)
        btnSaveBerry.setBackgroundColor(hexStringToUIColor(hex: "#CECECE"), for: .selected)
        btnUseBerry.setBackgroundColor(hexStringToUIColor(hex: "#CECECE"), for: .selected)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "MY 베리 내역"
        navigationController?.isNavigationBarHidden = false
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @IBAction func onClickAllBerry(_ sender: Any) {
        selectiedFilter = FILTER_POINT_ALL
        updatePointList()
    }
    
    @IBAction func onClickUseBerry(_ sender: Any) {
        selectiedFilter = FILTER_POINT_USED
        updatePointList()
    }
    
    @IBAction func onClickSaveBerry(_ sender: Any) {
        selectiedFilter = FILTER_POINT_SAVE
        updatePointList()
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
    
    func pickedData() {
        let startDate = dateFormatter.date(from: textFieldStartDate.text!)!
        let endDate = dateFormatter.date(from: textFieldEndDate.text!)!
        var pointHistory = PointHistory()
        pointHistory.list = nil
        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
    }
    
    @objc func donePressed(_ sender: Any) {
        self.textFieldDate.text = self.dateFormatter.string(from: self.datePicker.date)
        self.view.endEditing(true)
        pickedData()
        // change btn selected default
        btnAllBerry.isSelected = true
        btnUseBerry.isSelected = false
    }
    
    fileprivate func getPointHistory(isAllDate: Bool, startDate: Date, endDate: Date) {
        evPointList.removeAll()
        
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
                    if let point = pointHistory.list{
                        self.pointData.removeAll()
                        self.pointData.append(contentsOf: point)
                    }
                    // 나의 잔여 포인트
                    self.labelTotalPoint.text = "\(pointHistory.total_point)".currency()
                    self.updatePointList(pointHistory: pointHistory)
                }
            }
        }
        updatePointList()
    }
    
    // 모든베리(사용,적립)
    func getAllPointList() -> PointHistory {
        var pointHistory = PointHistory()
        pointHistory.list = nil
        pointHistory.list = pointData
        
        return pointHistory
    }
    
    // 사용베리
    func getUsedPointList() -> PointHistory{
        var evFilteredList:[EvPoint] = []
        var pointHistory = PointHistory()
        pointHistory.list = nil
            for i in self.pointData {
                if i.action == "used"{
                    evFilteredList.append(i)
                }
            }
        pointHistory.list = evFilteredList
        return pointHistory
    }
    
    // 적립베리
    func getSavePointList() -> PointHistory{
        var evFilteredList:[EvPoint] = []
        var pointHistory = PointHistory()
        pointHistory.list = nil
            for i in self.pointData {
                if i.action == "save"{
                    evFilteredList.append(i)
                }
            }
        pointHistory.list = evFilteredList
        return pointHistory
    }

    fileprivate func updatePointList(){
        btnAllBerry.isSelected = false
        btnUseBerry.isSelected = false
        btnSaveBerry.isSelected = false
        
        switch selectiedFilter {
        case FILTER_POINT_ALL:
            btnAllBerry.isSelected = true
            updatePointList(pointHistory: getAllPointList())
            break
        case FILTER_POINT_USED:
            btnUseBerry.isSelected = true
            updatePointList(pointHistory: getUsedPointList())
            break
        case FILTER_POINT_SAVE:
            btnSaveBerry.isSelected = true
            updatePointList(pointHistory: getSavePointList())
            break
        default:
            break
        }
    }
    
    fileprivate func updatePointList(pointHistory: PointHistory) {
        evPointList.removeAll()
        if let list = pointHistory.list {
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
    
    // Colot hexCode change to UIColor
    func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
           cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
           return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
           red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
           green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
           blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
           alpha: CGFloat(1.0)
        )
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

// set btn border, color
extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor?, borderWidth: CGFloat?) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask

        if borderWidth != nil {
            addBorder(mask, borderWidth: borderWidth!, borderColor:borderColor!)
        }
    }

    private func addBorder(_ mask: CAShapeLayer, borderWidth: CGFloat, borderColor: UIColor) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
}

// change button color according to state
extension UIButton {
    func setBgColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

//=============ChckBox=======================================================================================

//    fileprivate func prepareCheckBox() {
//        cbAllDuration.boxType = .square
//        cbAllDuration.checkState = .unchecked
//        cbAllDuration.tintColor = UIColor(rgb: 0x15435C)
//
//        cbSaveDuration.boxType = .square
//        cbSaveDuration.checkState = .unchecked
//        cbSaveDuration.tintColor = UIColor(rgb: 0x15435C)
//
//        cbUseDuration.boxType = .square
//        cbUseDuration.checkState = .unchecked
//        cbUseDuration.tintColor = UIColor(rgb: 0x15435C)
//
//        viewAllDuration.addTapGesture(target: self, action: #selector(onClickCbAllDuration(_:)))
//        viewSaveDuration.addTapGesture(target: self, action: #selector(onClickCbSaveDuration(_:)))
//        viewUseDuration.addTapGesture(target: self, action: #selector(onClickCbUseDuration(_:)))
//
//    }
    
//    @objc fileprivate func onClickCbAllDuration(_ sender: UITapGestureRecognizer) {
//            cbAllDuration.toggleCheckState(true)
//    }
//
//    @objc fileprivate func onClickCbSaveDuration(_ sender: UITapGestureRecognizer) {
//            cbSaveDuration.toggleCheckState(true)
//    }
//
//    @objc fileprivate func onClickCbUseDuration(_ sender: UITapGestureRecognizer) {
//            cbUseDuration.toggleCheckState(true)
//    }
    
    // 조회
//    @IBAction func onClickQuery(_ sender: Any) {
//        let startDate = dateFormatter.date(from: textFieldStartDate.text!)!
//        let endDate = dateFormatter.date(from: textFieldEndDate.text!)!
//    getPointHistory(isAllDate: isAllDuration, startDate: startDate, endDate: endDate)
////        let isAllDuration = cbAllDuration.checkState == .checked ? true : false
////        let isSavePoint = cbSaveDuration.checkState == .checked ? true : false
////        let isUsePoint = cbUseDuration.checkState == .checked ? true : false
//
//        if isAllDuration == true {
//            getPointHistory(isAllDate: isAllDuration, startDate: startDate, endDate: endDate)
//        }
//    }
    
    // 당일
//    @IBAction func onClickToday(_ sender: Any) {
//        cbAllDuration.checkState = .unchecked
//
//        let currentDate = Date()
//        getPointHistory(isAllDate: false, startDate: currentDate, endDate: currentDate)
//    }

    // 당월
//    @IBAction func onClickCurMonth(_ sender: Any) {
//        cbAllDuration.checkState = .unchecked
//
//        let startDate = Date().getThisMonthStart()!
//        let endDate = Date()
//        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
//    }
    
    // 전월
//    @IBAction func onClickLastMonth(_ sender: Any) {
//        cbAllDuration.checkState = .unchecked
//
//        let startDate = Date().getLastMonthStart()!
//        let endDate = Date().getLastMonthEnd()!
//        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
//    }

    // 당해년도
//    @IBAction func onClickThisYear(_ sender: Any) {
//        cbAllDuration.checkState = .unchecked
//
//        let startDate = Date().getThisYearStart()!
//        let endDate = Date()
//        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
//    }
