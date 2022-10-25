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
import RxSwift

struct PointHistory: Decodable {
    var code: Int?
    var msg: String?
    var total_point = "0"
    var list: [EvPoint]?
    var expire_point = "0"
}

internal final class PointViewController: UIViewController {
    
    // MARK: UI
    
    private lazy var customNaviBar = CommonNaviView().then {
        $0.naviTitleLbl.text = "My 베리 내역"
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    private lazy var settingButton = UIButton().then {
        $0.setTitle("설정", for: .normal)
        $0.setTitleColor(UIColor(named: "content-primary")!, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    @IBOutlet weak var textFieldStartDate: UITextField!
    @IBOutlet weak var textFieldEndDate: UITextField!
    
    @IBOutlet weak var btnAllBerry: UIButton!
    
    @IBOutlet weak var btnSaveBerry: UIButton!
    
    @IBOutlet weak var btnUseBerry: UIButton!
    
    @IBOutlet weak var labelTotalPoint: UILabel!
    @IBOutlet weak var labelExpirePoint: UILabel!
    @IBOutlet weak var labelResultMsg: UILabel!
    
    @IBOutlet weak var pointTableView: UITableView!
    @IBOutlet weak var pointUseGuideBtn: UIButton!
    
    // add..
    
    private var textFieldDate: UITextField!

    private let datePicker = UIDatePicker()
    private let dateFormatter = DateFormatter()
    
    // btn click state
    private let FILTER_POINT_ALL: Int = 0
    private let FILTER_POINT_SAVE: Int = 1
    private let FILTER_POINT_USED: Int = 2
    
    private var selectiedFilter: Int = 0
            
    private var evPointList: Array<EvPoint> = Array<EvPoint>()
    
    private var pointHistory = PointHistory()
    private let disposeBag = DisposeBag()
    
    
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = Colors.backgroundPrimary.color

        settingButton.addTarget(self, action: #selector(handleSettingButton), for: .touchUpInside)
        customNaviBar.backClosure = { [weak self] in
            self?.navigationController?.pop()
        }
        
        view.addSubview(customNaviBar)
        customNaviBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(Constants.view.naviBarHeight)
        }
        
        customNaviBar.addSubview(settingButton)
        settingButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(Constants.view.naviBarItemPadding)
            $0.size.equalTo(Constants.view.naviBarItemWidth)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareDatePicker()
        prepareTableView()
                
        let property: [String: Any] = ["berryAmount": "\(MemberManager.shared.berryPoint)"]
        PaymentEvent.viewMyBerry.logEvent(property: property)

        // 오늘 포인트 이력 가져오기
        btnAllBerry.isSelected = true
        
        pointUseGuideBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let viewcon = PointUseGuideViewController()
                self.navigationController?.push(viewController: viewcon)
            })
            .disposed(by: self.disposeBag)

//        // Bg color change
        btnAllBerry.setBackgroundColor(UIColor(hex: "#CECECE"), for: .selected)
        btnSaveBerry.setBackgroundColor(UIColor(hex: "#CECECE"), for: .selected)
        btnUseBerry.setBackgroundColor(UIColor(hex: "#CECECE"), for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                let currentDate = Date()
                self.getPointHistory(isAllDate: false, startDate: currentDate, endDate: currentDate)
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }
    
    @objc
    fileprivate func handleSettingButton() {
        let preUsePointVC = self.storyboard?.instantiateViewController(withIdentifier: "PreUsePointViewController") as! PreUsePointViewController
        navigationController?.push(viewController: preUsePointVC)
    }
    
    // Get all berry
    @IBAction func onClickAllBerry(_ sender: Any) {
        selectiedFilter = FILTER_POINT_ALL
        updateFilteredPointList()
    }
    
    // Get use berry
    @IBAction func onClickUseBerry(_ sender: Any) {
        selectiedFilter = FILTER_POINT_USED
        updateFilteredPointList()
    }
    
    // Get save berry
    @IBAction func onClickSaveBerry(_ sender: Any) {
        selectiedFilter = FILTER_POINT_SAVE
        updateFilteredPointList()
    }
}

extension PointViewController {
    fileprivate func prepareDatePicker() {
        textFieldStartDate.tintColor = UIColor.clear
        textFieldEndDate.tintColor = UIColor.clear
        
        let locale = Locale(identifier: "ko_KO")
        
        self.datePicker.datePickerMode = .date
        self.datePicker.locale = locale
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        
        self.dateFormatter.dateStyle = .medium
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
        self.datePicker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        self.textFieldDate.inputAccessoryView = toolbar
        self.textFieldDate.inputView = self.datePicker
    }
    
    func pickedData() {
        var startDate = dateFormatter.date(from: textFieldStartDate.text!)!
        let endDate = dateFormatter.date(from: textFieldEndDate.text!)!
        if startDate > endDate {
            startDate = dateFormatter.date(from: textFieldEndDate.text!)!
        }
        getPointHistory(isAllDate: false, startDate: startDate, endDate: endDate)
    }
    
    @objc func donePressed(_ sender: Any) {
        self.textFieldDate.text = self.dateFormatter.string(from: self.datePicker.date)
        self.view.endEditing(true)
        pickedData()
        
    }
    
    fileprivate func getPointHistory(isAllDate: Bool, startDate: Date, endDate: Date) {
        evPointList.removeAll()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        self.textFieldStartDate.text = self.dateFormatter.string(from: startDate)
        self.textFieldEndDate.text =  self.dateFormatter.string(from: endDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let sDate = formatter.string(from: startDate) + " 00:00:00"
        let eDate = formatter.string(from: endDate) + " 23:59:59"
        
        Server.getPointHistory(isAllDate: isAllDate, sDate: sDate, eDate: eDate) { (isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    self.pointHistory = try! JSONDecoder().decode(PointHistory.self, from: data)
                    printLog(out: "PARK TEST pointHistory : \(self.pointHistory)")
                    if self.pointHistory.code != 1000 {
                        self.labelResultMsg.visible()
                        self.labelResultMsg.text = self.pointHistory.msg
                    }
                    // 나의 잔여 포인트
                    self.labelTotalPoint.text = "\(self.pointHistory.total_point)".currency()
                    self.updateFilteredPointList()
                    
                    let currMonth = Calendar.current.component(.month, from: Date())
                    var expireMsg = String(format:"%0d월 소멸예정 베리 ", currMonth)
                    let expirePoint = "\(self.pointHistory.expire_point)".currency() + " 베리"
                    expireMsg.append(expirePoint)
                    let range = (expireMsg as NSString).range(of: expirePoint)
                    let mutableAttributedString = NSMutableAttributedString.init(string: expireMsg)
                    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)

                    self.labelExpirePoint.attributedText = mutableAttributedString
                }
            }
        }
    }
    
    // save + used
    func getAllPointList() -> [EvPoint] {
        var pointList: [EvPoint] = []
        if let list = self.pointHistory.list {
            pointList = list
        }
        return pointList
    }
    
    // used
    func getUsedPointList() -> [EvPoint] {
        var evFilteredList:[EvPoint] = []

        if let list = self.pointHistory.list {
            for item in list {
                if item.action == "used" {
                    evFilteredList.append(item)
                }
            }
        }
        return evFilteredList
    }
    
    // save
    func getSavePointList() -> [EvPoint] {
        var evFilteredList:[EvPoint] = []
        if let list = self.pointHistory.list {
            for item in list {
                if item.action == "save" {
                    evFilteredList.append(item)
                }
            }
        }
        return evFilteredList
    }

    fileprivate func updateFilteredPointList() {
        btnAllBerry.isSelected = false
        btnUseBerry.isSelected = false
        btnSaveBerry.isSelected = false

        switch selectiedFilter {
        case FILTER_POINT_ALL:
            btnAllBerry.isSelected = true
            updatePointList(pointList: getAllPointList())
            break
        case FILTER_POINT_USED:
            btnUseBerry.isSelected = true
            updatePointList(pointList: getUsedPointList())
            break
        case FILTER_POINT_SAVE:
            btnSaveBerry.isSelected = true
            updatePointList(pointList: getSavePointList())
            break
        default:
            break
        }
    }
    
    fileprivate func updatePointList(pointList: [EvPoint]) {
        evPointList.removeAll()
        
        if pointList.isEmpty {
            pointTableView.isHidden = true
        } else {
            evPointList = pointList
            pointTableView.isHidden = false
        }

        pointTableView.reloadData()
    }
}

extension PointViewController: UITableViewDelegate, UITableViewDataSource {
    func prepareTableView() {
        pointTableView.delegate = self
        pointTableView.dataSource = self
        
        pointTableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evPointList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointTableViewCell", for: indexPath) as! PointTableViewCell
        cell.reloadData(pointList: evPointList, position: indexPath.row)
        cell.selectionStyle = .none
        return cell
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
