//
//  ChargesViewController.swift
//  evInfra
//
//  Created by Shin Park on 25/06/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Material
import M13Checkbox

class ChargesViewController: UIViewController {

    @IBOutlet weak var textFieldStartDate: UITextField!
    @IBOutlet weak var textFieldEndDate: UITextField!
    
    @IBOutlet weak var checkBoxAllDuration: M13Checkbox!
    @IBOutlet weak var viewAllDuration: UIView!
    
    @IBOutlet weak var chargesTotalTime: UILabel!
    @IBOutlet weak var chargesTotalKwh: UILabel!
    @IBOutlet weak var chargesTotalFee: UILabel!

    @IBOutlet weak var tvResultMsg: UILabel!
    
    @IBOutlet weak var chargesTableView: UITableView!
    
    var textFieldDate: UITextField!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    var chargesList: Array<ChargingStatus> = Array<ChargingStatus>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareDatePicker()
        prepareCheckBox()
        prepareTableView()
        
        // 오늘 날짜
        let currentDate = Date()
        self.getCharges(isAllDate: false, startDate: currentDate, endDate: currentDate)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "충전이력 조회"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    fileprivate func prepareCheckBox() {
        checkBoxAllDuration.boxType = .square
        checkBoxAllDuration.checkState = .unchecked
        checkBoxAllDuration.tintColor = UIColor(named: "content-primary")
        
        viewAllDuration.addTapGesture(target: self, action: #selector(onClickCbAll(_:)))
    }
    
    @IBAction func onClickCbAll(_ sender: UITapGestureRecognizer) {
        checkBoxAllDuration.toggleCheckState(true)
    }
    
    // 조회
    @IBAction func onClickQuery(_ sender: Any) {
        let startDate = self.dateFormatter.date(from: self.textFieldStartDate.text!)!
        let endDate = self.dateFormatter.date(from: self.textFieldEndDate.text!)!
        
        let isAllDuration = self.checkBoxAllDuration.checkState == .checked ? true : false
        self.getCharges(isAllDate: isAllDuration, startDate: startDate, endDate: endDate)
    }
    
    // 당일
    @IBAction func onClickToday(_ sender: Any) {
        let currentDate = Date()
        self.getCharges(isAllDate: false, startDate: currentDate, endDate: currentDate)
    }

    // 당월
    @IBAction func onClickCurMonth(_ sender: Any) {
        let startDate = Date().getThisMonthStart()!
        let endDate = Date()
        self.getCharges(isAllDate: false, startDate: startDate, endDate: endDate)
    }
    
    // 전월
    @IBAction func onClickLastMonth(_ sender: Any) {
        let startDate = Date().getLastMonthStart()!
        let endDate = Date().getLastMonthEnd()!
        self.getCharges(isAllDate: false, startDate: startDate, endDate: endDate)
    }

    // 당해년도
    @IBAction func onClickThisYear(_ sender: Any) {
        let startDate = Date().getThisYearStart()!
        let endDate = Date()
        self.getCharges(isAllDate: false, startDate: startDate, endDate: endDate)
    }
}

// 조회 설정
extension ChargesViewController {
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
    
    fileprivate func getCharges(isAllDate: Bool, startDate: Date, endDate: Date) {
        self.textFieldStartDate.text = self.dateFormatter.string(from: startDate)
        self.textFieldEndDate.text =  self.dateFormatter.string(from: endDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let sDate = formatter.string(from: startDate) + " 00:00:00"
        let eDate = formatter.string(from: endDate) + " 23:59:59"
        
        Server.getCharges(isAllDate: isAllDate, sDate: sDate, eDate: eDate) { (isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    let chargeHistory = try! JSONDecoder().decode(ChargingHistoryList.self, from: data)
                    if chargeHistory.code != 1000 {
                        self.tvResultMsg.visible()
                        self.tvResultMsg.text = chargeHistory.msg
                    }
                    
                    // 조회한 총 이용내역
                    self.updateSumData(charges: chargeHistory);

                    // 이용요금 리스트
                    self.updateChargesList(charges: chargeHistory);
                }
            }
        }
    }
    
    fileprivate func updateSumData(charges: ChargingHistoryList) {
        self.chargesTotalTime.text = charges.total_time ?? "00:00:00"
        self.chargesTotalKwh.text = charges.total_kw ?? "0.00"
        self.chargesTotalFee.text = charges.total_pay?.currency() ?? "0"
    }
    
    fileprivate func updateChargesList(charges: ChargingHistoryList) {
        self.chargesList.removeAll()
        
        if let list = charges.list {
            if list.isEmpty {
                self.chargesTableView.isHidden = true
            } else {
                self.chargesList = list
                self.chargesTableView.isHidden = false
            }
        } else {
            self.chargesTableView.isHidden = true
        }
        self.chargesTableView.reloadData()
    }
}

extension ChargesViewController: UITableViewDelegate, UITableViewDataSource, ChargesTableViewCellDelegate {
    func prepareTableView() {
        self.chargesTableView.delegate = self
        self.chargesTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 196
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chargesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChargesTableViewCell", for: indexPath) as! ChargesTableViewCell
        cell.reloadChargeData(charge: self.chargesList[indexPath.row])
        cell.delegate = self

        return cell
    }
    
    func didSelectReceipt(charge: ChargingStatus) {
        let window = UIApplication.shared.keyWindow!
        let receiptView = ReceiptView(frame: window.bounds)
        receiptView.update(status: charge)
        receiptView.tag = 100
        receiptView.isUserInteractionEnabled = true
        window.addSubview(receiptView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeSubview))
        receiptView.addGestureRecognizer(tapGesture)
    }
    
    @objc func removeSubview() {
        let window = UIApplication.shared.keyWindow!
        if let receiptView = window.viewWithTag(100) {
            receiptView.removeFromSuperview()
        }
    }
}
