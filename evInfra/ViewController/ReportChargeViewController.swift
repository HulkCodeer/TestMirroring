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
    
    private let dropDownUsedTime = DropDown()
    private let dropDownOperation = DropDown()
    
    private let dbManager = DBManager.sharedInstance
    
    var detailGetInfoDelegate:ReportChargeViewDelegate?
    var reportCListGetInfoDelegate:ReportChargeViewDelegate?
    var info = ReportData.ReportChargeInfo()

    private var tMapView: TMapView? = nil
    
    var activeTextView: Any? = nil
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var serverComIndicator: UIActivityIndicatorView!
    //commonView
    //tmap container view
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var operationBtn: UIButton!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var operationTextView: UITextField!
    @IBOutlet weak var locationSelectBtn: UIButton!
    
    //report charger view
    @IBOutlet weak var reportChargerView: UIView!
    @IBOutlet weak var chargerView: UIView!
    @IBOutlet weak var chargerLabel: UILabel!
    @IBOutlet weak var chargerSubView: UIView!
    @IBOutlet weak var usedTimeSpinnerBtn: UIButton!
    @IBOutlet weak var usedTimeTextView: UITextField!
    @IBOutlet weak var phoneNumView: UITextField!
    
    @IBOutlet weak var payLabel: UILabel!
    @IBOutlet weak var payOnBtn: UIButton!
    @IBOutlet weak var payFreeBtn: UIButton!
    
    @IBOutlet weak var usedTimeView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var payView: UIView!
    
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func onClickPayOnBtn(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            sender.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
        }
        
        if self.payFreeBtn.isSelected {
            self.payFreeBtn.isSelected = false
            self.payFreeBtn.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
        }
    }
    
    @IBAction func onClickPayFreeBtn(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            sender.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
        }

        if self.payOnBtn.isSelected {
            self.payOnBtn.isSelected = false
            self.payOnBtn.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
        }
    }
    
    @IBAction func onClickApplyBtn(_ sender: Any) {
        sendReportToServer()
    }
    
    @IBAction func onClickDeleteBtn(_ sender: Any) {
        sendDeleteToServer()
    }
    
    @IBAction func onClickChargerAdd(_ sender: UIButton) {
        addChargerChildView(type:0)
    }
    
    @IBAction func onClickSelectLocation(_ sender: UIButton) {
        getCenterPointLocation()
    }
    
    @IBAction func onClickOperationBtn(_ sender: UIButton) {
        self.dropDownOperation.show()
    }
    
    @IBAction func onClickUsedTimeBtn(_ sender: UIButton) {
        self.dropDownUsedTime.show()
    }
    
    @IBAction func onClickSearchAddrBtn(_ sender: Any) {
        moveSearchAddressView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar()
        
        setVisableView(view: serverComIndicator, hidden: true)

        prepareCommonView()
        prepareInitView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
        self.detailGetInfoDelegate?.getReportInfo()
        self.reportCListGetInfoDelegate?.getReportInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
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

extension ReportChargeViewController {
    func printInfo() {
        print("pkey\(String(describing: info.pkey))")
        print("from\(String(describing: info.from))")
        print("adr\(String(describing: info.adr))")
        print("lat\(String(describing: info.lat))")
        print("lon\(String(describing: info.lon))")
        print("snm\(String(describing: info.snm))")
        print("std\(String(describing: info.status_id))")
        print("type\(String(describing: info.type))")
        print("utime\(String(describing: info.utime))")
        print("pay\(String(describing: info.pay))")
        print("tel\(String(describing: info.tel))")
        print("clist\(String(describing: info.clist.count))")
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
    
    func prepareInitView() {
        switch info.from {
        case Const.REPORT_CHARGER_FROM_MAIN:
            prepareNewReportChargerView()
        case Const.REPORT_CHARGER_FROM_LIST:
            if !isRequestReportInfo() {
                prepareNewReportChargerView()
                getCurrentReportInfo()
            }
        case Const.REPORT_CHARGER_FROM_DETAIL:
            if !isRequestReportInfo() {
                prepareNewReportChargerView()
                getCurrentReportInfo()
            }
        default:
            print("Call View is error")
        }
    }
    
    func prpareDropDownInit() {
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor(rgb: 0x15435C)
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.85)
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 36
    }
    
    func prepareCommonView() {
        prepareMapView()
        prpareDropDownInit()
        
        dropDownOperation.anchorView = self.operationBtn
        var list:Array<String> = dbManager.getCompanyNameList()
        list.remove(at: 0)
        dropDownOperation.dataSource = list
        dropDownOperation.width = operationBtn.frame.width
        dropDownOperation.selectionAction = { [unowned self] (index:Int, item:String) in
            self.operationBtn.setTitle(item, for: UIControlState.normal)
        }
        dropDownOperation.selectRow(0)
        operationBtn.setTitle(self.dropDownOperation.selectedItem, for: UIControlState.normal)
        
        if info.from == Const.REPORT_CHARGER_FROM_MAIN {
            info.type = Const.REPORT_CHARGER_TYPE_ETC
            info.pkey = 0
        }

        switch info.type {
        case Const.REPORT_CHARGER_TYPE_ETC:
            setVisableView(view: reportChargerView, hidden: false)
            reportChargerView.visible()
            deleteBtn.isEnabled = false
            prepareLabelInit(isNew: true)
        case Const.REPORT_CHARGER_TYPE_USER_ADD:
            setVisableView(view: reportChargerView, hidden: false)
            reportChargerView.visible()
            prepareLabelInit(isNew: true)
        case Const.REPORT_CHARGER_TYPE_USER_ADD_MOD:
            setVisableView(view: reportChargerView, hidden: false)
            reportChargerView.visible()
            prepareLabelInit(isNew: true)
        case Const.REPORT_CHARGER_TYPE_USER_ADD_DELETE:
            setVisableView(view: reportChargerView, hidden: false)
            reportChargerView.visible()
            prepareLabelInit(isNew: true)
            deleteBtn.isEnabled = false
        case Const.REPORT_CHARGER_TYPE_USER_MOD:
            setVisableView(view: reportChargerView, hidden: true)
            reportChargerView.gone()
            setLocationReportTypeView()
            prepareLabelInit(isNew: false)
        case Const.REPORT_CHARGER_TYPE_USER_MOD_DELETE:
            setVisableView(view: reportChargerView, hidden: true)
            reportChargerView.gone()
            setLocationReportTypeView()
            deleteBtn.isEnabled = false
            prepareLabelInit(isNew: false)
        default:
            print("제보하기 타입 오류")
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
        //operationTextView.layer.cornerRadius = 5
        operationTextView.delegate = self
        
        phoneNumView.layer.borderWidth = 0.5
        phoneNumView.layer.borderColor = UIColor.lightGray.cgColor
        //phoneNumView.layer.cornerRadius = 5
        phoneNumView.delegate = self
        scrollView.keyboardDismissMode = .onDrag
    }
    
    func setLocationReportTypeView() {
        addressTextView.text = info.adr
//        setVisableView(view: operationBtn, hidden: true)
//        operationBtn.gone()
        operationBtn.isEnabled = false
        if let cmId = info.companyID {
            let companyName = dbManager.getCompanyName(companyId: cmId)
            var cnt = 0
            var index = -1
            for name in dropDownOperation.dataSource {
                if(companyName == name) {
                    index = cnt
                }
                cnt += 1
            }
            if( index > 0 ) {
                dropDownOperation.selectRow(index)
                operationBtn.setTitle(self.dropDownOperation.selectedItem, for: UIControlState.normal)
            }
        }
        
        operationTextView.text = info.snm
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
    
    func getCenterPointLocation() {
        var mapPoint:TMapPoint? = nil
        mapPoint = tMapView?.getCenterPoint()
        
        guard let tMapPoint = mapPoint  else {
            print("TMapView is nil")
            return
        }
        self.info.lat = tMapPoint.getLatitude()
        self.info.lon = tMapPoint.getLongitude()
        
        let tMapPathData: TMapPathData = TMapPathData.init()
        let addr = tMapPathData.reverseGeocoding(tMapPoint, addressType: "A04")
        
        guard let fullAddr = addr?["fullAddress"] else {
            Snackbar().show(message: "주소를 지정할수 없는 위치입니다. 위치이동후 재시도 바랍니다")
            return
        }
        
        self.info.adr = fullAddr as? String
        self.addressTextView.text = fullAddr as? String
        
        let width = self.addressTextView.frame.size.width
        
        self.addressTextView.sizeToFit()
        self.addressTextView.frame.size = CGSize(width: width, height: self.addressTextView.frame.size.height)
    }
    
    func prepareNewReportChargerView() {
        dropDownUsedTime.anchorView = self.usedTimeSpinnerBtn
        
        dropDownUsedTime.dataSource = [
            "이용시간을 선택하세요",
            "주중/주말 24시간 이용가능",
            "주중 24시간 이용가능",
            "09:00-18:00",
            "09:00-22:00",
            "09:00-23:00",
            "10:00-23:00",
            "10:00-00:00",
            "직접입력"
        ]
        dropDownUsedTime.width = usedTimeSpinnerBtn.frame.width
        dropDownUsedTime.selectionAction = { [unowned self] (index:Int, item:String) in
            self.usedTimeSpinnerBtn.setTitle(item, for: UIControlState.normal)
            let idx = self.dropDownUsedTime.dataSource.count
            if idx == (index + 1) {
                self.usedTimeTextView.visible()
            } else {
                self.usedTimeTextView.gone()
            }
        }
        usedTimeTextView.gone()
        dropDownUsedTime.selectRow(0)
        usedTimeSpinnerBtn.setTitle(self.dropDownUsedTime.selectedItem, for: UIControlState.normal)
        
        onClickPayFreeBtn(payFreeBtn)
    }
    
    func prepareTextLabelMutiColorInit(text:String, label: UILabel) {
        let attributeString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: (text as NSString).range(of:"(필수)"))
        
        label.attributedText = attributeString
    }
    
    func prepareLabelInit(isNew: Bool) {
        if isNew {
            prepareTextLabelMutiColorInit(text: "운영기관 (필수)", label: operationLabel)
            operationBtn.isEnabled = true
        }
        prepareTextLabelMutiColorInit(text: addressLabel.text!, label: addressLabel)
        prepareTextLabelMutiColorInit(text: chargerLabel.text!, label: chargerLabel)
        prepareTextLabelMutiColorInit(text: payLabel.text!, label: payLabel)
    }
    
    func prepareRefreshReportChargerView() {
        addressTextView.text = info.adr
        operationTextView.text = info.snm
        
        if let cmId = info.companyID {
            let companyName = dbManager.getCompanyName(companyId: cmId)
            var cnt = 0
            var index = -1
            for name in dropDownOperation.dataSource {
                if(companyName == name) {
                    index = cnt
                }
                cnt += 1
            }
            if( index > 0 ) {
                dropDownOperation.selectRow(index)
                operationBtn.setTitle(self.dropDownOperation.selectedItem, for: UIControlState.normal)
            }
        }
        
        let listCnt = info.clist.count
        if listCnt > 0 {
            for list in info.clist {
                addChargerChildView(type:list)
            }
        }
        let lastIndex = dropDownUsedTime.dataSource.count - 1
        dropDownUsedTime.selectRow(lastIndex)
        usedTimeSpinnerBtn.setTitle(self.dropDownUsedTime.selectedItem, for: UIControlState.normal)
        usedTimeTextView.visible()
        usedTimeTextView.text = info.utime
        
        phoneNumView.text = info.tel
        
        if let isPay = info.pay {
            if isPay == "Y" {
                onClickPayOnBtn(payOnBtn)
            } else {
                onClickPayFreeBtn(payFreeBtn)
            }
        } else {
            onClickPayFreeBtn(payFreeBtn)
        }
    }
    
    func setVisableView(view:UIView, hidden:Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func addChargerChildView(type: Int) {
        var cp: CGPoint = self.chargerSubView.frame.origin
        let cSize: CGSize = self.chargerSubView.frame.size

        let cv = ReportChargerChildCell()
        cp.y = (CGFloat(self.chargerSubView.subviews.count) * cv.frame.size.height)
        cv.frame.origin = CGPoint(x: cp.x, y: cp.y)
        cv.frame.size = CGSize(width: cSize.width, height: cv.frame.size.height)
        cv.removeBtn.addTarget(self, action: #selector(self.onClickChargerRemove), for: .touchUpInside)

        switch type {
        case Const.CHARGER_TYPE_DCDEMO:            // DC차데모
            cv.dcDemoImg.isHighlighted = true
        case Const.CHARGER_TYPE_SLOW:              // 완속
            cv.slowImg.isHighlighted = true
        case Const.CHARGER_TYPE_DCDEMO_AC:         // DC차데모+AC상
            cv.dcDemoImg.isHighlighted = true
            cv.ac3Img.isHighlighted = true
        case Const.CHARGER_TYPE_DCCOMBO:           // DC콤보
            cv.dcCommboImg.isHighlighted = true
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO:    // DC차데모 + DC콤보
            cv.dcDemoImg.isHighlighted = true
            cv.dcCommboImg.isHighlighted = true
        case Const.CHARGER_TYPE_DCDEMO_DCCOMBO_AC: // DC차데모 + AC상 + DC콤보
            cv.dcDemoImg.isHighlighted = true
            cv.dcCommboImg.isHighlighted = true
            cv.ac3Img.isHighlighted = true
        case Const.CHARGER_TYPE_AC:                // AC상
            cv.ac3Img.isHighlighted = true
        case Const.CHARGER_TYPE_DCCOMBO_AC:        // DC콤보+AC3상
            cv.dcCommboImg.isHighlighted = true
            cv.ac3Img.isHighlighted = true
        case Const.CHARGER_TYPE_SUPER_CHARGER:     // 수퍼차저
            cv.superImg.isHighlighted = true
        case Const.CHARGER_TYPE_DESTINATION:       // 데스티네이션
            cv.destinationImg.isHighlighted = true
        default:
            print("충전 타입 오류 \(type)")
        }
        
        self.chargerSubView.addSubview(cv)
        chargerSubViewAddResize(height:cv.frame.size.height)
    }
    
    func chargerSubViewAddResize(height:CGFloat) {
        self.chargerSubView.translatesAutoresizingMaskIntoConstraints = true
        self.chargerSubView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        self.reportChargerView.translatesAutoresizingMaskIntoConstraints = true
        
        var cp: CGPoint = self.usedTimeView.frame.origin
        cp.y = cp.y + height
        var cSize = self.usedTimeView.frame.size
        self.usedTimeView.frame = CGRect(x: cp.x, y: cp.y, width: cSize.width, height: cSize.height)
        
        cp = self.phoneView.frame.origin
        cp.y = cp.y + height
        cSize = self.phoneView.frame.size
        self.phoneView.frame = CGRect(x: cp.x, y: cp.y, width: cSize.width, height: cSize.height)
       
        cp = self.payView.frame.origin
        cp.y = cp.y + height
        cSize = self.payView.frame.size
        self.payView.frame = CGRect(x: cp.x, y: cp.y, width: cSize.width, height: cSize.height)
      
        let fSize: CGSize = self.reportChargerView.frame.size
        self.reportChargerView.frame.size = CGSize(width: fSize.width, height: (fSize.height + height))
    }
    
    func chargerSubViewRemoveResize() {
        let chargerSubCnt = self.chargerSubView.subviews.count
        let firstSize: CGSize = self.chargerView.frame.size
        var firstPoint: CGPoint = self.chargerView.frame.origin
        firstPoint.y += firstSize.height
        var chargerSubHeight:CGFloat = 0.0
        
        if chargerSubCnt > 0 {
            var count:Int = 0
            for v in self.chargerSubView.subviews {
                chargerSubHeight = v.frame.size.height
                let yDelta = CGFloat(count) * chargerSubHeight
                let subSize:CGSize = v.frame.size
                var subPoint:CGPoint = v.frame.origin
                subPoint.y = yDelta
                
                v.frame = CGRect(x: subPoint.x, y: subPoint.y, width: subSize.width, height: subSize.height)
                count += 1
            }
        }
       
        self.chargerSubView.translatesAutoresizingMaskIntoConstraints = true
        self.chargerSubView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.reportChargerView.translatesAutoresizingMaskIntoConstraints = true

        var cp: CGPoint = self.usedTimeView.frame.origin
        cp.y = firstPoint.y + (CGFloat(chargerSubCnt) * chargerSubHeight)
        var cSize = self.usedTimeView.frame.size
        self.usedTimeView.frame = CGRect(x: cp.x, y: cp.y, width: cSize.width, height: cSize.height)

        cp.y = cp.y + cSize.height
        cSize = self.phoneView.frame.size
        self.phoneView.frame = CGRect(x: cp.x, y: cp.y, width: cSize.width, height:cSize.height)
        
        cp.y = cp.y + cSize.height
        cSize = self.payView.frame.size
        self.payView.frame = CGRect(x: cp.x, y: cp.y, width: cSize.width, height: cSize.height)
        
        var fSize: CGSize = self.reportChargerView.frame.size
        fSize.height = cp.y + cSize.height
        self.reportChargerView.frame.size = CGSize(width: fSize.width, height: fSize.height)
    }
    
    func isRequestReportInfo() -> Bool {
        var isRequest: Bool = true
        switch info.type {
        case Const.REPORT_CHARGER_TYPE_USER_ADD:
            isRequest = false
        case Const.REPORT_CHARGER_TYPE_USER_ADD_MOD:
            isRequest = false
        case Const.REPORT_CHARGER_TYPE_USER_ADD_DELETE:
            isRequest = false
        default:
            isRequest = true
        }
        return isRequest
    }
    
    func sendDeleteToServer() {
        switch info.type {
        case Const.REPORT_CHARGER_TYPE_USER_ADD:
            requestDeleteReport(typeID:Const.REPORT_CHARGER_TYPE_USER_ADD_DELETE)
        case Const.REPORT_CHARGER_TYPE_USER_ADD_MOD:
            requestDeleteReport(typeID:Const.REPORT_CHARGER_TYPE_USER_ADD_DELETE)
        case Const.REPORT_CHARGER_TYPE_USER_MOD:
            if info.status_id == Const.REPORT_CHARGER_STATUS_CONFIRM {
                requestDeleteReport(typeID:Const.REPORT_CHARGER_TYPE_USER_MOD_DELETE)
            }
        default:
            Snackbar().show(message: "해당 항목은 삭제할 수 없습니다.")
        }
    }
    
    func sendReportToServer() {
        var isNewReport: Bool = false
        
        switch info.type {
        case Const.REPORT_CHARGER_TYPE_ETC:
            isNewReport = true
        case Const.REPORT_CHARGER_TYPE_USER_ADD:
            isNewReport = true
        case Const.REPORT_CHARGER_TYPE_USER_ADD_MOD:
            isNewReport = true
        case Const.REPORT_CHARGER_TYPE_USER_ADD_DELETE:
            isNewReport = true
        case Const.REPORT_CHARGER_TYPE_USER_MOD:
            isNewReport = false
        case Const.REPORT_CHARGER_TYPE_USER_MOD_DELETE:
            isNewReport = false
        default:
            Snackbar().show(message: "설정에 오류가 있습니다. 관리자에게 문의 바랍니다.")
            return
        }
        
        if checkDataField(isNew: isNewReport) {
            let typeID = initSendTypeID(isNew: isNewReport)
            switch typeID {
            case Const.REPORT_CHARGER_TYPE_USER_ADD:
                self.info.type = typeID
                requestReportNewAddApply(typeID: typeID)
            case Const.REPORT_CHARGER_TYPE_USER_ADD_MOD:
                self.info.type = typeID
                requestReportNewAddApply(typeID: typeID)
            case Const.REPORT_CHARGER_TYPE_USER_MOD:
                self.info.type = typeID
                requestReportApply(typeID: typeID)
            default:
                print("타입 설정 로직 오류")
            }
        }
    }
    
    func initSendTypeID(isNew: Bool) -> Int {
        var type = 0
        if isNew {
            if info.type == Const.REPORT_CHARGER_TYPE_ETC {
                type = Const.REPORT_CHARGER_TYPE_USER_ADD
            } else {
                type = Const.REPORT_CHARGER_TYPE_USER_ADD_MOD
            }
        } else {
            type = Const.REPORT_CHARGER_TYPE_USER_MOD
        }
        return type;
    }
    
    func checkDataField(isNew: Bool) -> Bool {
        // gps 좌표
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
    
        if !isNew {
            return true
        }
        guard let companyName = dropDownOperation.selectedItem else {
            Snackbar().show(message: "운영기관 선택이 잘못되었습니다. 재설정 바랍니다")
            return false
        }
        
        guard let companyId = dbManager.getCompanyId(name: companyName), !companyId.isEmpty else {
            Snackbar().show(message: "운영기관 선택이 잘못되었습니다. 재설정 바랍니다")
            return false
        }
        info.companyID = companyId
        
        if let snm = operationTextView.text {
            info.snm = snm
        }
        
        if chargerSubView.subviews.count <= 0 {
            Snackbar().show(message: "충전기를 추가 후 타입을 설정해 주세요")
            return false
        }
        info.clist.removeAll()
        
        for view in chargerSubView.subviews {
            if let v = view as? ReportChargerChildCell {
                var type = 0
                if info.companyID == "I" { // 테슬라
                    if v.superImg.isHighlighted {
                        type = Const.CTYPE_SUPER_CHARGER
                    }
                    if v.destinationImg.isHighlighted {
                        type |= Const.CTYPE_DESTINATION
                    }
                } else { // 테슬라 이외
                    if v.dcDemoImg.isHighlighted {
                        type = Const.CTYPE_DCDEMO
                    }
                    if v.ac3Img.isHighlighted {
                        type |= Const.CTYPE_AC
                    }
                    if v.dcCommboImg.isHighlighted {
                        type |= Const.CTYPE_DCCOMBO
                    }
                    if v.slowImg.isHighlighted {
                        type |= Const.CTYPE_SLOW
                    }
                }
                let type_id: Int = getChargerTypeId(type: type)
                
                if type_id <= 0 {
                    Snackbar().show(message: "충전기 타입을 잘못 설정하셨습니다. 재설정 후 시도바랍니다.")
                    return false
                }
                info.clist.append(type_id)
            } else {
                print("충전기 타입 Get Fail")
            }
        }
        
        if info.clist.count <= 0 {
            Snackbar().show(message: "충전기 추가/타입설정이 완료되지 않았습니다. 재설정 바랍니다.")
            return false
        }
        
        if let utimeSelectIndex = dropDownUsedTime.indexForSelectedRow, utimeSelectIndex >= 0  {
            if utimeSelectIndex == (dropDownUsedTime.dataSource.count - 1) {
                if let utime = usedTimeTextView.text, !utime.isEmpty {
                    info.utime = utime
                } else {
                    info.utime = ""
                }
            } else {
                info.utime = dropDownUsedTime.selectedItem
            }
        } else {
            info.utime = ""
        }
        
        if let tel = phoneNumView.text, !tel.isEmpty {
            info.tel = tel
        } else {
            info.tel = ""
        }
        
        if payOnBtn.isSelected {
            info.pay = "Y"
        } else {
            info.pay = "N"
        }
        
        return true
    }
    
    func getChargerTypeId(type:Int) -> Int {
        var typeId = 0;
        switch type {
        case Const.CTYPE_DCDEMO:
            typeId = Const.CHARGER_TYPE_DCDEMO
        case Const.CTYPE_SLOW:
            typeId = Const.CHARGER_TYPE_SLOW
        case Const.CTYPE_DCDEMO | Const.CTYPE_AC:
            typeId = Const.CHARGER_TYPE_DCDEMO_AC
        case Const.CTYPE_AC:
            typeId = Const.CHARGER_TYPE_AC
        case Const.CTYPE_DCDEMO | Const.CTYPE_DCCOMBO:
            typeId = Const.CHARGER_TYPE_DCDEMO_DCCOMBO
        case Const.CTYPE_DCDEMO | Const.CTYPE_AC | Const.CTYPE_DCCOMBO:
            typeId = Const.CHARGER_TYPE_DCDEMO_DCCOMBO_AC
        case Const.CTYPE_DCCOMBO:
            typeId = Const.CHARGER_TYPE_DCCOMBO
        case Const.CTYPE_DCCOMBO | Const.CTYPE_AC:
            typeId = Const.CHARGER_TYPE_DCCOMBO_AC
        case Const.CTYPE_SUPER_CHARGER:
            typeId = Const.CHARGER_TYPE_SUPER_CHARGER
        case Const.CTYPE_DESTINATION:
            typeId = Const.CHARGER_TYPE_DESTINATION
        default:
            typeId = 0
        }
        return typeId;
    }
 
    @objc
    fileprivate func onClickBackBtn() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func onClickChargerRemove(_ sender: UIButton) {
        sender.superview?.superview?.superview?.removeFromSuperview()
        chargerSubViewRemoveResize()
    }
}

extension ReportChargeViewController {
    func indicatorControll(isStart: Bool) {
        if isStart {
            setVisableView(view: serverComIndicator, hidden: false)
            serverComIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            serverComIndicator.stopAnimating()
            setVisableView(view: self.serverComIndicator, hidden: true)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

    func getCurrentReportInfo() {
        indicatorControll(isStart: true)
        
        Server.getReportCurInfo(key: info.pkey!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    self.info.pkey = 0
                    print("GetReportInfo-result_code:" + json["result_code"].stringValue)
                } else {
                    self.info.pkey = json["pkey"].intValue
                    self.info.lat = json["lat"].doubleValue
                    self.info.lon = json["lon"].doubleValue
                    self.info.type = json["type_id"].intValue
                    self.info.status_id = json["status_id"].intValue
                    self.info.adr = json["adr"].stringValue
                    self.info.snm = json["snm"].stringValue
                    self.info.chargerID = json["charger_id"].stringValue
                    self.info.companyID = json["company_id"].stringValue
                    self.info.utime = json["utime"].stringValue
                    self.info.tel = json["tel"].stringValue
                    self.info.pay = json["pay"].stringValue
                    
                    if let childList = json["clist"].arrayObject as? [Int] {
                        self.info.clist = childList
                    }
                    self.prepareRefreshReportChargerView()
                }
                self.indicatorControll(isStart: false)
            } else {
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 제보하기 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func requestDeleteReport(typeID: Int) {
        self.indicatorControll(isStart: true)
        
        Server.deleteReport(key: info.pkey!, typeId: typeID) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    let resultCode = json["result_code"].stringValue
                    if resultCode == "2000" {
                        self.onClickBackBtn()
                    } else {
                        Snackbar().show(message: "서버요청중 오류가 발생하였습니다. 재시도바랍니다.")
                    }
                    print("requestDeleteReport-result_code:" + json["result_code"].stringValue)
                }
                self.indicatorControll(isStart: false)
            } else {
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 제보하기 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func requestReportNewAddApply(typeID:Int) {
        self.indicatorControll(isStart: true)
        
        Server.addReport(info: self.info, typeId: typeID) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    let result_code = json["result_code"].stringValue
                    if result_code == "2000" {
                        self.onClickBackBtn()
                    } else {
                        Snackbar().show(message: "서버요청중 오류가 발생하였습니다. 재시도바랍니다.")
                    }
                    print("requestReportApply-charger_id:" + json["charger_id"].stringValue)
                }
                self.indicatorControll(isStart: false)
            } else {
                self.indicatorControll(isStart: false)
                Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 제보하기 페이지 종료후 재시도 바랍니다.")
            }
        }
    }
    
    func requestReportApply(typeID:Int) {
        self.indicatorControll(isStart: true)
        
        Server.modifyReport(info: self.info) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    let resultCode = json["result_code"].stringValue
                    if resultCode == "2000" {
                        self.onClickBackBtn()
                    } else {
                        Snackbar().show(message: "서버요청중 오류가 발생하였습니다. 재시도바랍니다.")
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
}

extension ReportChargeViewController {
    func moveSearchAddressView() {
        let searchVC:AddressToLocationController = self.storyboard?.instantiateViewController(withIdentifier: "AddressToLocationController") as! AddressToLocationController
        searchVC.delegate = self
        self.present(AppSearchBarController(rootViewController: searchVC), animated: true, completion: nil)
    }
}

extension ReportChargeViewController:  ReportChargerAddrSearchDelegate{
    func moveToLocation(lat:Double, lon:Double) {
        guard let mapView = tMapView else {
            print("ReportCharger Map init fail")
            return
        }
        mapView.setCenter(TMapPoint.init(lon: lon, lat: lat))
    }
}
