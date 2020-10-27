//
//  ReportChargeViewController.swift
//  evInfra
//
//  Created by 이신광 on 2018. 9. 13..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import Motion
import SwiftyJSON
import DropDown

class ReportChargeViewController: UIViewController {
    
    var delegate:ReportChargeViewDelegate? = nil

    var tMapView: TMapView? = nil
    var activeTextView: Any? = nil
    
    var charger: ChargerStationInfo? = nil
    var info = ReportData.ReportChargeInfo()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var serverComIndicator: UIActivityIndicatorView!
    
    //commonView
    //tmap container view
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var locationSelectBtn: UIButton!
    
    @IBOutlet weak var addressTextView: UITextView!

    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var operationBtn: UIButton!
    @IBOutlet weak var operationTextView: UITextField!
    
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func onClickApplyBtn(_ sender: Any) {
        sendReportToServer()
    }
    
    @IBAction func onClickDeleteBtn(_ sender: Any) {
        sendDeleteToServer()
    }
    
    @IBAction func onClickSelectLocation(_ sender: UIButton) {
        getCenterPointLocation()
    }

    @IBAction func onClickSearchAddrBtn(_ sender: Any) {
        moveSearchAddressView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareCommonView()

        requestReportData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeObserver()
        
        if let delegate = self.delegate {
            delegate.getReportInfo()
        }
    }

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(onClickBackBtn), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "충전소 추가/정보 제보"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareCommonView() {
        prepareMapView()
        prepareChargerView()

        if info.type_id == Const.REPORT_CHARGER_TYPE_USER_MOD_DELETE {
            deleteBtn.isEnabled = false
        }
        
        if info.status_id != Const.REPORT_CHARGER_STATUS_CONFIRM {
            deleteBtn.isEnabled = false
        }

        addressTextView.layer.borderWidth = 0.5
        addressTextView.layer.borderColor = UIColor.white.cgColor
        addressTextView.layer.cornerRadius = 5
        addressTextView.delegate = self
        
        operationTextView.layer.borderWidth = 0.5
        operationTextView.layer.borderColor = UIColor.lightGray.cgColor
        operationTextView.layer.cornerRadius = 5
        operationTextView.delegate = self
        
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func prepareMapView() {
        tMapView = TMapView.init(frame: mapViewContainer.frame.bounds)
        guard let mapView = tMapView else {
            print("ReportCharger Map init fail")
            return
        }
        
        mapView.setSKTMapApiKey(Const.TMAP_APP_KEY)
        mapView.setZoomLevel(15)
        if let lat = info.lat, let lon = info.lon {
            mapView.setCenter(TMapPoint(lon: lon, lat: lat))
        } else {
            mapView.setTrackingMode(true)
        }
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapViewContainer.addSubview(mapView)
        
        locationSelectBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    
    func prepareChargerView() {
        printInfo()
        addressTextView.text = info.adr
        operationTextView.text = info.snm
        
        if let charger = self.charger {
            operationBtn.setTitle(charger.mStationInfoDto?.mOperator, for: UIControlState.normal)
        }
    }
    
    @objc
    fileprivate func onClickBackBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    func cancelReport() {
        Snackbar().show(message: "서버요청 중 오류가 발생하였습니다. 재시도 바랍니다.")
        dismiss(animated: true, completion: nil)
    }
    
    func getCenterPointLocation() {
        guard let tMapPoint = tMapView?.getCenterPoint() else {
            return
        }

        self.info.lat = tMapPoint.getLatitude()
        self.info.lon = tMapPoint.getLongitude()
        
        let tMapPathData: TMapPathData = TMapPathData.init()
        let addr = tMapPathData.reverseGeocoding(tMapPoint, addressType: "A04")
        
        guard let fullAddr = addr?["fullAddress"] else {
            Snackbar().show(message: "주소를 지정할 수 없는 위치입니다. 위치이동 후 재시도 바랍니다.")
            return
        }
        
        self.info.adr = fullAddr as? String
        self.addressTextView.text = fullAddr as? String
        
        let width = self.addressTextView.frame.size.width
        
        self.addressTextView.sizeToFit()
        self.addressTextView.frame.size = CGSize(width: width, height: self.addressTextView.frame.size.height)
    }
    
    func setVisableView(view:UIView, hidden:Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func sendDeleteToServer() {
        switch info.type_id {
        case Const.REPORT_CHARGER_TYPE_USER_MOD:
            if info.status_id == Const.REPORT_CHARGER_STATUS_CONFIRM {
                requestDeleteReport(typeID:Const.REPORT_CHARGER_TYPE_USER_MOD_DELETE)
            }
        default:
            Snackbar().show(message: "해당 항목은 삭제할 수 없습니다.")
        }
    }
    
    func sendReportToServer() {
        if checkDataField() {
            requestReportApply()
        }
    }

    // gps 좌표
    func checkDataField() -> Bool {
        //printInfo()
        guard let lat = info.lat, lat > 0.0 else {
            Snackbar().show(message: "추가/수정할 위치를 선택해 주세요.")
            return false
        }
        
        guard let lon = info.lon, lon > 0.0 else {
            Snackbar().show(message: "추가/수정할 위치를 선택해 주세요.")
            return false
        }
        
        guard  let adr = info.adr, !adr.isEmpty else {
            Snackbar().show(message: "추가/수정할 위치를 선택해주세요.")
            return false
        }
        
        return true
    }
    
    func moveSearchAddressView() {
        let searchVC:AddressToLocationController = self.storyboard?.instantiateViewController(withIdentifier: "AddressToLocationController") as! AddressToLocationController
        searchVC.delegate = self
        self.present(AppSearchBarController(rootViewController: searchVC), animated: true, completion: nil)
    }

    func indicatorControll(isStart: Bool) {
        if isStart {
            setVisableView(view: serverComIndicator, hidden: false)
            serverComIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            setVisableView(view: self.serverComIndicator, hidden: true)
            serverComIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func requestReportData() {
        if let chargerId = self.info.charger_id {
            if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
                self.charger = charger
                
                indicatorControll(isStart: true)
                Server.getReportInfo(chargerId: chargerId) { (isSuccess, value) in

                    self.indicatorControll(isStart: false)
                    if isSuccess {
                        print(value)
                        let json = JSON(value)
                        if json["code"].intValue == 1000 { // 기존에 제보한 내역이 있음
                            let report = json["report"]

                            self.info.report_id = report["report_id"].intValue
                            self.info.type_id = report["type_id"].intValue
                            self.info.status_id = report["status_id"].intValue
                            self.info.charger_id = report["charger_id"].stringValue
                            self.info.snm = report["snm"].stringValue
                            self.info.lat = report["lat"].doubleValue
                            self.info.lon = report["lon"].doubleValue
                            self.info.adr = report["adr"].stringValue
                            self.info.adr_dtl = report["adr_dtl"].stringValue
                        } else { // 처음 제보하는 충전소
                            self.info.report_id = 0
                            self.info.type_id = Const.REPORT_CHARGER_TYPE_USER_MOD
                            self.info.status_id = Const.REPORT_CHARGER_STATUS_FINISH

                            self.info.lat = charger.mStationInfoDto?.mLatitude
                            self.info.lon = charger.mStationInfoDto?.mLongitude
                            self.info.adr = charger.mStationInfoDto?.mAddress
                            self.info.adr_dtl = charger.mStationInfoDto?.mAddressDetail
                        }
                        self.moveToLocation(lat: self.info.lat!, lon: self.info.lon!)
                        self.prepareChargerView()
                    }
                }
            } else {
                cancelReport()
            }
        } else {
            cancelReport()
        }
    }
    
    func requestDeleteReport(typeID: Int) {
        self.indicatorControll(isStart: true)
        
        Server.deleteReport(key: info.report_id!, typeId: typeID) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    let resultCode = json["result_code"].stringValue
                    if resultCode == "2000" {
                        self.onClickBackBtn()
                    } else {
                        Snackbar().show(message: "서버요청 중 오류가 발생하였습니다. 재시도 바랍니다.")
                    }
                    print("requestDeleteReport-result_code:" + json["result_code"].stringValue)
                }
                self.indicatorControll(isStart: false)
            } else {
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 제보하기 종료 후 재시도 바랍니다.")
            }
        }
    }
    
    func requestReportApply() {
        self.indicatorControll(isStart: true)
        
        Server.modifyReport(info: self.info) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    let resultCode = json["result_code"].stringValue
                    if resultCode == "2000" {
                        self.onClickBackBtn()
                    } else {
                        Snackbar().show(message: "서버요청중 오류가 발생하였습니다. 재시도 바랍니다.")
                    }
                    print("GetReportInfo-result_code:" + json["result_code"].stringValue)
                }
                self.indicatorControll(isStart: false)
            } else {
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 제보하기 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func printInfo() {
        print("pkey: \(String(describing: info.report_id))")
        print("from: \(String(describing: info.from))")
        print("adr: \(String(describing: info.adr))")
        print("lat: \(String(describing: info.lat))")
        print("lon: \(String(describing: info.lon))")
        print("snm: \(String(describing: info.snm))")
        print("company id: \(String(describing: info.company_id))")
        print("std: \(String(describing: info.status_id))")
        print("type: \(String(describing: info.type_id))")
        print("utime: \(String(describing: info.utime))")
        print("pay: \(String(describing: info.pay))")
        print("tel: \(String(describing: info.tel))")
        print("clist: \(String(describing: info.clist.count))")
    }
}

extension ReportChargeViewController:  ReportChargerAddrSearchDelegate {
    func moveToLocation(lat:Double, lon:Double) {
        guard let mapView = tMapView else {
            print("ReportCharger Map init fail")
            return
        }
        mapView.setCenter(TMapPoint.init(lon: lon, lat: lat))
    }
}

extension ReportChargeViewController : UITextFieldDelegate, UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { notification in
            self.keyboardWillShow(notification : notification)
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { notification in
            self.keyboardWillHide(notification : notification)
        }
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification : Notification) {
        guard let userInfo = notification.userInfo, let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsert = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInsert
        scrollView.scrollIndicatorInsets = contentInsert
        
        if let active = activeTextView {
            if active is UITextView {
                self.scrollView.scrollToView(view: (active as! UIView).superview!)
            }
        }
    }
    
    func keyboardWillHide(notification : Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeTextView = textView
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextView = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextView = nil
    }
}
