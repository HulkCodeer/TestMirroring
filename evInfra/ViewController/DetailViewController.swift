//
//  DetailViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 3. 13..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import Motion
import SwiftyJSON
import JJFloatingActionButton

class DetailViewController: UIViewController, MTMapViewDelegate {
    
    @IBOutlet weak var detailView: UIView!
//    @IBOutlet weak var vieagerContainer: UIView!

    @IBOutlet weak var companyView: UIView!             // 운영기관
    @IBOutlet weak var operatorLabel: UILabel!          // 운영기관 이름
    @IBOutlet weak var addressLabel: CopyableLabel!    // 충전소 주소
    @IBOutlet weak var dstLabel: UILabel!               // 현 위치에서 거리
    @IBOutlet var indoorView: UIView!                   // 설치형태(실내)
    @IBOutlet var outdoorView: UIView!                  // 설치형태(실외)
    @IBOutlet var canopyView: UIView!                   // 설치형태(캐노피)
    @IBOutlet var checkingView: UIView!                 // 설치형태(확인중)
    @IBOutlet var callOutFavorite: UIButton!            // 즐겨찾기
    @IBOutlet var chargerPowerLb: UILabel!              // 충전속도
    @IBOutlet var chargerStatusImg: UIImageView!        // 충전상태(마커이미지)
    
    
    
    @IBOutlet var startPointBtn: UIButton!
    @IBOutlet var endPointBtn: UIButton!
    @IBOutlet var naviBtn: UIButton!
    
    @IBOutlet weak var memoLabel: UILabel!     // 메모
    @IBOutlet var memoView: UIStackView!
    
    // 이용시간: visible, gone 처리를 위해 subview 모두 연결함
//    @IBOutlet weak var timeImage: UIImageView!
//    @IBOutlet weak var timeFixLabel: UILabel!
//    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var callOutTitle: UILabel!
    @IBOutlet var callOutStatus: UILabel!
    
    @IBOutlet var kakaoMapView: UIView!
    
    // 지킴이
    @IBOutlet weak var guardView: UIView!
    @IBOutlet weak var guardImage: UIImageView!
    @IBOutlet weak var guardFixLabel: UILabel!
    @IBOutlet weak var guardReportBtn: UIButton!
    @IBOutlet weak var guardEnvBtn: UIButton!
    @IBOutlet weak var guardKepcoBtn: UIButton!
    
    @IBOutlet weak var boardTableView: BoardTableView!
    @IBOutlet weak var cidTableView: CidTableView!

    @IBOutlet weak var CidTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var callLb: UILabel!
    
    
    var mainViewDelegate: MainViewDelegate?
    var charger: ChargerStationInfo?
    var checklistUrl: String?
    
    // Charge station info(summary)
    var stationInfoArr = [String:String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var boardList: Array<BoardData> = Array<BoardData>()
    
    fileprivate var moveHomePageBtn: FABButton!
    fileprivate var moveAppStoreBtn: FABButton!
    
    private var phoneNumber:String? = nil
    private var homePage:String? = nil
    private var appStore:String? = nil
    
    private var rcInfo = ReportData.ReportChargeInfo()
    
    var shareUrl = ""
    let dbManager = DataBaseHelper.sharedInstance
    
    var myGradeStarPoint: Int = 0
    
    var mapView:MTMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()
        prepareBoardTableView()
        preparePagingView()
    
        prepareGuard()
        prepareGradeStar()
         
        getChargerInfo()
        getReportInfo()
        getMyGrade()
        
        setDetailLb()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.boardTableView.setNeedsDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func viewWillLayoutSubviews() {
        
        self.mapView = MTMapView(frame: self.kakaoMapView.bounds)
        let testPoint:MTMapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude:  37.4911458, longitude: 127.030325))
//        37.491145, 127.030325
        
        if let mapView = mapView{
            
            mapView.delegate = self
//            mapView.baseMapType = .hybrid
            mapView.baseMapType = .standard
            mapView.setMapCenter(MTMapPoint(geoCoord:.init(latitude: 37.491145,longitude: 127.030325)), zoomLevel: 2, animated: true)
            
            let poiItem = MTMapPOIItem()
            poiItem.itemName = "test"
            poiItem.markerType = MTMapPOIItemMarkerType.bluePin
            poiItem.tag = 1
            poiItem.showAnimationType = .dropFromHeaven
            poiItem.mapPoint = testPoint
//            poiItem.customImage =
            mapView.add(poiItem)
//            mapView.add(<#T##poiItem: MTMapPOIItem!##MTMapPOIItem!#>)
            
            self.kakaoMapView.addSubview(self.mapView!)
        }
        
        self.startPointBtn.setBorderRadius([.bottomLeft, .topLeft], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
        self.endPointBtn.setBorderRadius([.bottomRight, .topRight], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
        self.naviBtn.setBorderRadius(.allCorners, radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
    }
    
    // MARK: - Action for button
    @IBAction func onClickBookmark(_ sender: Any) {
        self.bookmark()
    }

    @IBAction func onClickStartPoint(_ sender: Any) {
        self.mainViewDelegate?.setStartPoint()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickEndPoint(_ sender: Any) {
        self.mainViewDelegate?.setEndPoint()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickNavi(_ sender: UIButton) {
        self.mainViewDelegate?.showNavigation()
    }
    
    @IBAction func onClickKakaoShareBtn(_ sender: UIButton) {
        self.shareForKakao()
    }
    
    @IBAction func onClickReportBtn(_ sender: Any) {
        self.onClickReportChargeBtn()
    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // DetailView reSize
    func detailViewResize(view:UIView) {
        self.detailView.frame.size = CGSize(width: self.detailView.frame.size.width, height: self.detailView.frame.size.height-view.frame.size.height)
    }
    
    func getChargerInfo() {
        getStationDetailInfo()
        getFirstBoardData()
    }
    
    func preparePagingView() {
        let viewPagerController = ViewPagerController(charger: self.charger!)
        addChildViewController(viewPagerController)
        self.setCallOutFavoriteIcon(charger: self.charger!)
//        self.callOutTitle.text = selectCharger?.mStationInfoDto?.mSnm
//        viewPagerContainer.addSubview(viewPagerController.view)
//        viewPagerContainer.constrainToEdges(viewPagerController.view)
        
//        self.cardPriceView.removeFromSuperview();
//        self.cardPriceViewTitle.removeFromSuperview();
//        viewPagerContainer.addSubview(viewPagerController.view)
//        viewPagerContainer.constrainToEdges(viewPagerController.view)
    }
    
    // MARK: - Server Communications
    
    func getStationDetailInfo() {
        Server.getStationDetail(chargerId: (charger?.mChargerId)!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let list = json["list"]
                
                for (_, item):(String, JSON) in list {
                    self.setStationInfo(json: item)
                    break
                }
            }
        }
    }
    
    func setStationInfo(json: JSON) {
        // 운영기관
        self.operatorLabel.text = json["op"].stringValue
        
        // 이용시간
        if json["ut"].stringValue.isEmpty{
            self.timeLabel.text = "-"
        }else{
            self.timeLabel.text = json["ut"].stringValue
        }
        
        // 메모
        let memo = json["mm"].stringValue
        
        if !memo.isEmpty{
            if memo.equals("") {
                detailViewResize(view: memoView)
                self.memoView.isHidden = true
                self.memoView.gone()
            }else{
                self.memoLabel.text = memo
            }
        }else{
            self.memoView.isHidden = true
            self.memoView.gone()
//            detailViewResize(view: memoView)
        }
        
        // 센터 전화번호
        self.phoneNumber = json["tel"].stringValue
        self.callLb.text = self.phoneNumber
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapFunction))
        self.callLb.isUserInteractionEnabled = true
        self.callLb.addGestureRecognizer(tap)
        
        // 평점
        self.charger?.mGpa = Float(json["gpa"].stringValue)!
        self.charger?.mGpaCnt = Int(json["cnt"].stringValue)!
        self.setChargeGPA()
        
        // 충전기 정보
        let clist = json["cl"]
        var cidList = [CidInfo]()
        for (_, item):(String, JSON) in clist {
            let cidInfo = CidInfo.init(cid: item["cid"].stringValue, chargerType: item["tid"].intValue, cst: item["cst"].stringValue, recentDate: item["rdt"].stringValue, power: item["p"].intValue)
            cidList.append(cidInfo)
        }
        var stationSt = cidList[0].status!
        for cid in cidList {
            if (stationSt != cid.status) {
                if(cid.status == Const.CHARGER_STATE_WAITING) {
                    stationSt = cid.status!
                    break
                }
            }
        }
        ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: self.charger!.mChargerId!)?.changeStatus(status: stationSt)
        self.mainViewDelegate?.redrawCalloutLayer()
        self.cidTableView.setCidList(chargerList: cidList)
        self.cidTableView.reloadData()
        self.adjustHeightOfTableview()
        
        self.showMenuBtn()
    }
    
    func setDetailLb() {
        // 충전 속도
        self.chargerPowerLb.text = self.charger?.getChargerPower(power: (charger?.mPower)!, type: (charger?.mTotalType)!)
        
        // 충전소 이름
        self.callOutTitle.text = self.charger?.mStationInfoDto?.mSnm
        
        // 충전기 상태
        self.callOutStatus.text = self.charger?.cidInfo.cstToString(cst: self.charger?.mTotalStatus ?? 2)
        
        // 충전기 상태별 마커 이미지
        let chargeState = self.callOutStatus.text
        stationInfoArr[chargeState ?? ""] = "chargeState"
        
        self.chargerStatusImg.image = self.charger?.getChargeStateImg(type: chargeState!)
        
        // 주소
        self.addressLabel.text = (self.charger?.mStationInfoDto?.mAddress)!
        self.addressLabel.sizeToFit()
        
        // 설치 형태
        self.stationArea()
        
        // 충전소 거리
        if let currentLocatin = MainViewController.currentLocation {
            getDistance(curPos: currentLocatin, desPos: self.charger!.marker.getTMapPoint())
        } else {
            self.dstLabel.text = "현재 위치를 받아오지 못했습니다."
        }
    }
    
    func getDistance(curPos: TMapPoint, desPos: TMapPoint) {
        if desPos.getLatitude() == 0 || desPos.getLongitude() == 0 {
            self.dstLabel.text = "현재 위치를 받아오지 못했습니다."
        } else {
            self.dstLabel.text = "계산중"
            
            DispatchQueue.global(qos: .background).async {
                let tMapPathData = TMapPathData.init()
                if let path = tMapPathData.find(from: curPos, to: desPos) {
                    let distance = Double(path.getDistance() / 1000).rounded()

                    DispatchQueue.main.async {
                        self.dstLabel.text = "| \(distance) Km"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.dstLabel.text = "거리를 계산할 수 없습니다."
                    }
                }
            }
        }
    }
    
    func stationArea() {
        let roof = String(self.charger?.mStationInfoDto?.mRoof ?? "")

        self.indoorView.isHidden = true
        self.outdoorView.isHidden = true
        self.canopyView.isHidden = true
        
        if (roof.equals("0")){
            //indoor
            self.indoorView.isHidden = false
            
        }else if (roof.equals("1")){
            //outdoor
            self.outdoorView.isHidden = false
            
        }else if (roof.equals("2")){
            //canopy
            self.canopyView.isHidden = false
            
        }else if (roof.equals("N")){
            //Checking
        }
    }
    
    // TODO: bookmark
    func bookmark() {
        if MemberManager().isLogin() {
            ChargerManager.sharedInstance.setFavoriteCharger(charger: self.charger!) { (charger) in
                 self.setCallOutFavoriteIcon(charger: charger)
            }
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
        if charger.mFavorite {
            self.callOutFavorite.setImage(UIImage(named: "bookmark_on"), for: .normal)
        } else {
            self.callOutFavorite.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    // MARK: - TableView Height
    
    func adjustHeightOfTableview() {
        let contentHeight = self.cidTableView.contentSize.height
        let expectedFrame = CGRect(x: 0, y: 0, width: self.detailView.frame.width, height: self.detailView.frame.height - CidTableView.Constants.cellHeight + contentHeight)
        if !self.detailView.frame.equalTo(expectedFrame) {
            self.detailView.frame = expectedFrame
        }
        
        // set the height constraint accordingly
        UIView.animate(withDuration: 0.25, animations: {
            self.CidTableHeightConstraint.constant = contentHeight;
            self.view.needsUpdateConstraints()
            self.boardTableView.reloadData()
        }, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Finish Edit Board
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.onClickCallBtn()
    }
}

extension DetailViewController {
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.text = (self.charger?.mStationInfoDto?.mSnm)!
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop(transitionType: kCATransitionReveal, subtype: kCATransitionFromBottom)
    }
}

extension DetailViewController: BoardTableViewDelegate {
    
    fileprivate func prepareBoardTableView() {
        // UITableView cell 높이를 자동으로 설정
        self.boardTableView.tableViewDelegate = self
        self.cidTableView.rowHeight = UITableViewAutomaticDimension
        self.cidTableView.estimatedRowHeight = CidTableView.Constants.cellHeight
        self.cidTableView.separatorStyle = .none
        
        self.boardTableView.rowHeight = UITableViewAutomaticDimension
        self.boardTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.boardTableView.separatorStyle = .none
        
        self.boardTableView.allowsSelection = false
        
        // Table header 추가
        self.boardTableView.tableHeaderView = detailView
        self.boardTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.boardTableView.estimatedSectionHeaderHeight = 25;
    }
    
    func getFirstBoardData() {
        Server.getChargerBoard(chargerId: (charger?.mChargerId)!) { (isSuccess, value) in
            if isSuccess {
                self.boardList.removeAll()
                let json = JSON(value)
                let boardJson = json["list"]
                for json in boardJson.arrayValue {
                    let boardData = BoardData(bJson: json)
                    self.boardList.append(boardData)
                }
                self.boardTableView.boardList = self.boardList
                self.boardTableView.reloadData()
            }
        }
    }
    
    func getNextBoardData() {
    }
    
    func boardEdit(tag: Int) {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_EDIT_MODE
        editVC.charger = self.charger
        editVC.originBoardData = self.boardList[tag]
        editVC.editViewDelegate = self

        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    func boardDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            Server.deleteBoard(category: BoardData.BOARD_CATEGORY_CHARGER, boardId: self.boardList[tag].boardId!) { (isSuccess, value) in
                if isSuccess {
                    self.getFirstBoardData()
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
            print("Cancel button tapped")
        })
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func replyEdit(tag: Int) {
        let section = tag / 1000
        let row = tag % 1000
        let replyValue = self.boardList[section].reply![row]
        
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.REPLY_EDIT_MODE
        editVC.originReplyData = replyValue
        editVC.editViewDelegate = self
        
        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    func replyDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "댓글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            let section = tag / 1000
            let row = tag % 1000
            let replyValue = self.boardList[section].reply![row]
            Server.deleteReply(category: BoardData.BOARD_CATEGORY_CHARGER, boardId: replyValue.replyId!) { (isSuccess, value) in
                if isSuccess {
                    self.getFirstBoardData()
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (ACTION) -> Void in
            print("Cancel button tapped")
        })
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func makeReply(tag: Int) {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.REPLY_NEW_MODE
        editVC.originBoardId = tag
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    func goToStation(tag: Int) {}
}

extension DetailViewController: EditViewDelegate {
    
    func postBoardData(content: String, hasImage: Int, picture: Data?) {
        Server.postBoard(category: BoardData.BOARD_CATEGORY_CHARGER, chargerId: (self.charger?.mChargerId)!, content: content, hasImage: hasImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if hasImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture{
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if(isSuccess){
                                self.getFirstBoardData()
                            }else{
                                print("upload image Error : \(json)")
                            }
                            
                        })
                    }
                    
    
                } else {
                    self.getFirstBoardData()
                }
            }
        }
    }
    
    func editBoardData(content: String, boardId: Int, editImage: Int, picture: Data?) {
        Server.editBoard(category: BoardData.BOARD_CATEGORY_CHARGER, boardId: boardId, content: content, editImage: editImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if editImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture {
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, completion: { (isSuccess, value) in
                            let json = JSON(value)
                            if isSuccess {
                                self.getFirstBoardData()
                            } else {
                                print("upload image Error : \(json)")
                            }
                        })
                    }
                } else {
                    self.getFirstBoardData()
                }
            }
        }
    }
    
    func postReplyData(content: String,  boardId: Int) {
        Server.postReply(category: BoardData.BOARD_CATEGORY_CHARGER, boardId: boardId, content: content) { (isSuccess, value) in
            if isSuccess {
                self.getFirstBoardData()
            }
        }
    }
    
    func editReplyData(content: String, replyId: Int) {
        Server.editReply(category: BoardData.BOARD_CATEGORY_CHARGER, replyId: replyId, content: content) { (isSuccess, value) in
            if isSuccess {
                self.getFirstBoardData()
            }
        }
    }
}

extension DetailViewController {
    fileprivate func showMenuBtn() {
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = UIColor.clear
        actionButton.buttonImage = UIImage(named: "detail_plus")
//        actionButton.buttonImageSize = actionButton.buttonImage?.size ?? CGSize.init(width:  74.55, height:  74.55)
        if let image = actionButton.buttonImage {
            actionButton.buttonImageSize = image.size
        }
//        actionButton.buttonImageSize = CGSize.init(width: 56, height: 136)
        
        let ret = prepareCallItem()
        if ret {
            actionButton.addItem(title: "전화하기", image: #imageLiteral(resourceName: "detail_quick_icon")) { item in
                self.onClickCallBtn()
            }
        }
        actionButton.addItem(title: "제보하기", image: #imageLiteral(resourceName: "detail_quick_icon_report")) { item in
            self.onClickReportChargeBtn()
        }
        
        actionButton.addItem(title: "글쓰기", image: #imageLiteral(resourceName: "detail_quick_icon_pen")) { item in
            self.onClickEditBtn()
        }

        for item in actionButton.items {
            item.buttonColor = Color.white
            
//            item.buttonImageColor = Color.white
        }
    
        actionButton.display(inViewController: self)
    }

    fileprivate func prepareCallItem() -> Bool {
        if let phoneNum = self.phoneNumber {
            if(phoneNum.count > 8) {
                return true
            }
        }
        return false
    }
    
    @objc
    fileprivate func onClickCallBtn() {
        if let phoneNum = self.phoneNumber {
            if(phoneNum.count > 8) {
                callToPhoneApp(number: phoneNum)
            }
        }
    }
    
    fileprivate func callToPhoneApp(number:String) {
        if let phoneCallUrl = URL(string: "tel://\(number)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallUrl)) {
                application.open(phoneCallUrl, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc
    fileprivate func onClickEditBtn() {
        let editVC:EditViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_NEW_MODE
        editVC.charger = self.charger
        editVC.editViewDelegate = self //EditViewDelegate
        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    @objc
    fileprivate func onClickReportChargeBtn() {
        if MemberManager().isLogin() {
            let reportChargeVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
            
            reportChargeVC.detailGetInfoDelegate = self
            reportChargeVC.info.from = Const.REPORT_CHARGER_FROM_DETAIL
            reportChargeVC.info.pkey = self.rcInfo.pkey
            if reportChargeVC.info.pkey! <= 0 {
                reportChargeVC.info.type = Const.REPORT_CHARGER_TYPE_USER_MOD
                reportChargeVC.info.lat = self.charger?.mStationInfoDto?.mLatitude
                reportChargeVC.info.lon = self.charger?.mStationInfoDto?.mLongitude
                reportChargeVC.info.status_id = Const.REPORT_CHARGER_STATUS_FINISH
                reportChargeVC.info.adr = self.charger?.mStationInfoDto?.mAddress
                reportChargeVC.info.companyID = self.charger?.mStationInfoDto?.mCompanyId
            } else {
                reportChargeVC.info.type = self.rcInfo.type
                reportChargeVC.info.lat = self.rcInfo.lat
                reportChargeVC.info.lon = self.rcInfo.lon
                reportChargeVC.info.status_id = self.rcInfo.status_id
                reportChargeVC.info.adr = self.rcInfo.adr
                reportChargeVC.info.companyID = self.rcInfo.companyID
            }
            reportChargeVC.info.chargerID = self.charger?.mChargerId
            reportChargeVC.info.snm = self.charger?.mStationInfoDto?.mSnm
            
            self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
        } else {
            MemberManager().showLoginAlert(vc:self)
        }
    }
}

extension DetailViewController: ReportChargeViewDelegate {
    func getReportInfo() {
        Server.getReportInfo(chargerId: (self.charger?.mChargerId)!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["result_code"].exists() {
                    self.rcInfo.pkey = 0
                    print("GetReportInfo-result_code:" + json["result_code"].stringValue)
                    return;
                }
                self.rcInfo.pkey = json["pkey"].intValue
                self.rcInfo.lat = json["lat"].doubleValue
                self.rcInfo.lon = json["lon"].doubleValue
                self.rcInfo.type = json["type_id"].intValue
                self.rcInfo.status_id = json["status_id"].intValue
                self.rcInfo.adr = json["adr"].stringValue
            }
        }
    }
}

extension DetailViewController {
//    fileprivate func showMoveHomePageBtn() {
//        if let strUrl = self.homePage {
//            if isCanOpenUrl(strUrl: strUrl) {
//                let img:UIImage? = UIImage(named:"ic_web_browser")
//                moveHomePageBtn = FABButton(image: img)
//                moveHomePageBtn.setImage(img, for: .normal)
//                moveHomePageBtn.addTarget(self, action: #selector(self.onClickMoveCompanyHomePage(_sender:)), for: .touchUpInside)
//                companyView.layout(moveHomePageBtn).width(32).height(32).right(10).centerVertically()
//            }
//        }
//    }
//
//    fileprivate func showMoveAppStoreBtn() {
//        var rMagin = 10
//        if let _ = self.moveHomePageBtn {
//            rMagin = Int(10 + self.moveHomePageBtn.frame.width + 5)
//        }
//
//        if let strUrl = self.appStore {
//            if isCanOpenUrl(strUrl: strUrl) {
//                let img:UIImage? = UIImage(named:"ic_app_store")
//                moveAppStoreBtn = FABButton(image: img)
//                moveAppStoreBtn.setImage(img, for: .normal)
//                moveAppStoreBtn.addTarget(self, action: #selector(self.onClickMoveAppStore(_sender:)), for: .touchUpInside)
//                companyView.layout(moveAppStoreBtn).width(32).height(32).right(CGFloat(rMagin)).centerVertically()
//            }
//        }
//    }
    
    @objc
    func onClickMoveCompanyHomePage(_sender:UIButton) {
        if let strUrl = self.homePage {
            moveToUrl(strUrl: strUrl)
        }
    }
    
    @objc
    func onClickMoveAppStore(_sender:UIButton) {
        if let strUrl = self.appStore {
            moveToUrl(strUrl: strUrl)
        }
    }
    
    func moveToUrl(strUrl:String) {
        let encode_url = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = NSURL(string: encode_url) {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(url as URL)) {
                application.open(url as URL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func isCanOpenUrl(strUrl:String) -> Bool {
        let encode_url = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if let url = NSURL(string: encode_url) {
            let application:UIApplication = UIApplication.shared
            if application.canOpenURL(url as URL) {
                return true
            }
        }
        return false
    }
}

extension DetailViewController {
    func sendToKakaoTalk() {
        let templateId = "10575"
        var shareList = [String: String]()
        shareList["width"] = "480"
        shareList["height"] = "290"
        shareList["imageUrl"] = shareUrl
        shareList["title"] = "충전소 상세 정보";
        if let stationName = charger?.mStationInfoDto?.mSnm {
            shareList["stationName"] = stationName;
        } else {
            shareList["stationName"] = "";
        }
        if let stationId = charger?.mChargerId {
            shareList["scheme"] = "charger_id=\(stationId)"
            shareList["ischeme"] = "charger_id=\(stationId)"
        }
        
        shareList["appstore"] = "https://itunes.apple.com/kr/app/ev-infra/id1206679515?mt=8";
        shareList["market"] = "https://play.google.com/store/apps/details?id=com.client.ev.activities";
        
//        let shareCenter = KLKTalkLinkCenter.init()
        
        KLKTalkLinkCenter.shared().sendCustom(withTemplateId: templateId, templateArgs: shareList, success: { (warnimgMsg, argMsg) in
            print("warning message: \(String(describing: warnimgMsg?.description))")
            print("argument message: \(String(describing: argMsg?.description))")
        }) { (error) in
            print("error \(error)")
        }
    }
    
    func shareForKakao() {
        let shareImage: UIImage!
        let size = CGSize(width: 480.0, height: 290.0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        UIImage(named: "menu_top_bg.jpg")?.draw(in: rect)
        shareImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
//        let sharedStorage = KLKImageStorage.init()

        KLKImageStorage.shared().upload(with: shareImage, success: { (imageInfo) in
            self.shareUrl = "\(imageInfo.url)"
            self.sendToKakaoTalk()
        }) { (error) in
            self.shareUrl = Const.urlShareImage
            self.sendToKakaoTalk()
            print("makeImage Error \(error)")
        }
    }
}

// MARK: - 지킴이
extension DetailViewController {
    fileprivate func prepareGuard() {
        if let chargerForGuard = self.charger?.mGuard {
            if chargerForGuard && MemberManager().isGuard() {
                guardReportBtn.addTarget(self, action: #selector(self.onClickGuardReport), for: .touchUpInside)
                guardEnvBtn.addTarget(self, action: #selector(self.onClickEnv), for: .touchUpInside)
                guardKepcoBtn.addTarget(self, action: #selector(self.onClickKepco), for: .touchUpInside)
            } else {
                guardKepcoBtn.gone(spaces: [.top, .bottom])
                guardEnvBtn.gone(spaces: [.top, .bottom])
                guardReportBtn.gone(spaces: [.top, .bottom])
                guardFixLabel.gone(spaces: [.top, .bottom])
                guardImage.gone(spaces: [.top, .bottom])
                guardView.gone(spaces: [.top, .bottom])
               
                detailViewResize(view: guardView)
            }
        }
    }
    
    @objc
    fileprivate func onClickGuardReport() {
        if let url = checklistUrl {
            moveToUrl(strUrl: url)
        } else {
            Snackbar().show(message: "현장점검표 주소를 받아오지 못했습니다. 앱 종료 후 다시 실행해 주세요.")
        }
    }
    
    @objc
    fileprivate func onClickEnv() {
        moveToUrl(strUrl: "https://www.ev.or.kr/mobile/main2")
    }
    
    @objc
    fileprivate func onClickKepco() {
        moveToUrl(strUrl: "https://evc.kepco.co.kr:4445/mobile/main.do")
    }
}

// 별점주기
extension DetailViewController {
    func prepareGradeStar() {
        myGradeStarPoint = 0
        setGradeButtonRegMode()
        let gradeImgStar1 = UITapGestureRecognizer(target: self, action: #selector(self.onClickGradeStart1Btn))
//        gradeStarImage1.isUserInteractionEnabled = true
//        gradeStarImage1.addGestureRecognizer(gradeImgStar1)

        let gradeImgStar2 = UITapGestureRecognizer(target: self, action: #selector(self.onClickGradeStart2Btn))
//        gradeStarImage2.isUserInteractionEnabled = true
//        gradeStarImage2.addGestureRecognizer(gradeImgStar2)

        let gradeImgStar3 = UITapGestureRecognizer(target: self, action: #selector(self.onClickGradeStart3Btn))
//        gradeStarImage3.isUserInteractionEnabled = true
//        gradeStarImage3.addGestureRecognizer(gradeImgStar3)

        let gradeImgStar4 = UITapGestureRecognizer(target: self, action: #selector(self.onClickGradeStart4Btn))
//        gradeStarImage4.isUserInteractionEnabled = true
//        gradeStarImage4.addGestureRecognizer(gradeImgStar4)

        let gradeImgStar5 = UITapGestureRecognizer(target: self, action: #selector(self.onClickGradeStart5Btn))
//        gradeStarImage5.isUserInteractionEnabled = true
//        gradeStarImage5.addGestureRecognizer(gradeImgStar5)
    }
    
    @objc func onClickGradeStart1Btn(sender: UITapGestureRecognizer) {
        setGrade(point: 1)
    }
    
    @objc func onClickGradeStart2Btn(sender: UITapGestureRecognizer) {
        setGrade(point: 2)
    }
    
    @objc func onClickGradeStart3Btn(sender: UITapGestureRecognizer) {
        setGrade(point: 3)
    }
    
    @objc func onClickGradeStart4Btn(sender: UITapGestureRecognizer) {
        setGrade(point: 4)
    }
    
    @objc func onClickGradeStart5Btn(sender: UITapGestureRecognizer) {
        setGrade(point: 5)
    }
    
    func setGradeButtonRegMode() {
//        gradeRegBtn.isEnabled = false
//        gradeRegBtn.isHidden = false
//        gradeDelBtn.isHidden = true
//        gradeModBtn.isHidden = true
    }
    
    func setGradeButtonModifyMode() {
//        gradeRegBtn.isHidden = true
//        gradeDelBtn.isHidden = false
//        gradeModBtn.isHidden = false
    }
    
    func setGrade(point: Int) {
//        gradeRegBtn.isEnabled = true
        myGradeStarPoint = point
        drawMyGrade(point: myGradeStarPoint)
    }
    
    func drawMyGrade(point:Int) {
        clearMyGrade()
        
        switch point {
//        case 1:
//            setStarBg(view: gradeStarImage1)
//        case 2:
//            setStarBg(view: gradeStarImage1)
//            setStarBg(view: gradeStarImage2)
//        case 3:
//            setStarBg(view: gradeStarImage1)
//            setStarBg(view: gradeStarImage2)
//            setStarBg(view: gradeStarImage3)
//        case 4:
//            setStarBg(view: gradeStarImage1)
//            setStarBg(view: gradeStarImage2)
//            setStarBg(view: gradeStarImage3)
//            setStarBg(view: gradeStarImage4)
//        case 5:
//            setStarBg(view: gradeStarImage1)
//            setStarBg(view: gradeStarImage2)
//            setStarBg(view: gradeStarImage3)
//            setStarBg(view: gradeStarImage4)
//            setStarBg(view: gradeStarImage5)
        default:
            print("drawGrade() point is 0")
        }
    }
    
    func clearMyGrade() {
//        clearStarBg(view: gradeStarImage1)
//        clearStarBg(view: gradeStarImage2)
//        clearStarBg(view: gradeStarImage3)
//        clearStarBg(view: gradeStarImage4)
//        clearStarBg(view: gradeStarImage5)
    }
    
    func clearStarBg(view:UIImageView) {
        view.backgroundColor = UIColor.clear
    }
    
    func setStarBg(view:UIImageView) {
        view.backgroundColor = UIColor(rgb: 0xA0A0A0)
    }
    
    func getMyGrade() {
        if !MemberManager().isLogin() {
            return
        }
        
        self.clearMyGrade()
        self.myGradeStarPoint = 0
        Server.getGrade(chargerId: (self.charger?.mChargerId)!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].exists() {
                    if json["code"].intValue == 1000 {
                        self.myGradeStarPoint = json["sp"].intValue
                        if self.myGradeStarPoint > 0 {
                            self.setGradeButtonModifyMode()
                        } else {
                            self.setGradeButtonRegMode()
                        }
                        self.drawMyGrade(point: self.myGradeStarPoint)
                    }
                }
            }
        }
    }
    
    func addChargeGrade() {
        if !MemberManager().isLogin() {
            MemberManager().showLoginAlert(vc: self)
            return
        }
        
        if self.myGradeStarPoint <= 0 {
            Snackbar().show(message: "별점을 하나 이상 선택해야 합니다.")
            return
        }
        
        Server.addGrade(chargerId: (self.charger?.mChargerId)!, point: self.myGradeStarPoint) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].exists() {
                    if json["code"].intValue == 1000 {
                        Snackbar().show(message: "평점을 등록하였습니다.")
                        self.setGradeButtonModifyMode()
                        
                        // 평균 평점 수정
                        self.charger?.mGpa = Float(json["gpa"].stringValue)!
                        self.charger?.mGpaCnt = Int(json["cnt"].stringValue)!
                        self.setChargeGPA()
                    }
                }
            }
        }
    }

    func delChargeGrade() {
        if !MemberManager().isLogin() {
            MemberManager().showLoginAlert(vc: self)
            return
        }
        
        Server.deleteGrade(chargerId: (self.charger?.mChargerId)!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if json["code"].exists() {
                    if json["code"].intValue == 1000 {
                        Snackbar().show(message: "평점을 삭제하였습니다.")
                        self.myGradeStarPoint = 0
                        self.setGradeButtonRegMode()
                        self.drawMyGrade(point: self.myGradeStarPoint)

                        // 평균 평점 수정
                        self.charger?.mGpa = Float(json["gpa"].stringValue)!
                        self.charger?.mGpaCnt = Int(json["cnt"].stringValue)!
                        self.setChargeGPA()
                    }
                }
            }
        }
    }

    // 충전소 평점 표시
    func setChargeGPA() {
//        if let gradePointAvg = charger?.gpa, gradePointAvg > 0 {
//            gpaLabelView.text = String(format:"%.1f", gradePointAvg)
//            personCntLabelView.text = String(format:"%d 명", (charger?.gpaPersonCnt)!)
//            drawGpaStar(point: gradePointAvg)
//        } else {
//            gpaLabelView.text = String(format:"%.1f", 0.0)
//            personCntLabelView.text = String(format:"%d 명", 0)
//            drawGpaStar(point: 0)
//        }
    }
    
    func drawGpaStar(point:Double) {
//        clearStarBg(view: gpaStarImage1)
//        clearStarBg(view: gpaStarImage2)
//        clearStarBg(view: gpaStarImage3)
//        clearStarBg(view: gpaStarImage4)
//        clearStarBg(view: gpaStarImage5)
        
        let gpaIntPart = Int(floor(point))
        var gpaFloatPart = Int(floor(point * 10.0))
        gpaFloatPart = gpaFloatPart % 10
       
        switch gpaIntPart {
//        case 1:
//            setStarBg(view: gpaStarImage1)
//            drawGpaStarFloatAreaBackground(point: gpaFloatPart, view: gpaStarImage2)
//        case 2:
//            setStarBg(view: gpaStarImage1)
//            setStarBg(view: gpaStarImage2)
//            drawGpaStarFloatAreaBackground(point: gpaFloatPart, view: gpaStarImage3)
//        case 3:
//            setStarBg(view: gpaStarImage1)
//            setStarBg(view: gpaStarImage2)
//            setStarBg(view: gpaStarImage3)
//            drawGpaStarFloatAreaBackground(point: gpaFloatPart, view: gpaStarImage4)
//        case 4:
//            setStarBg(view: gpaStarImage1)
//            setStarBg(view: gpaStarImage2)
//            setStarBg(view: gpaStarImage3)
//            setStarBg(view: gpaStarImage4)
//            drawGpaStarFloatAreaBackground(point: gpaFloatPart, view: gpaStarImage5)
//        case 5:
//            setStarBg(view: gpaStarImage1)
//            setStarBg(view: gpaStarImage2)
//            setStarBg(view: gpaStarImage3)
//            setStarBg(view: gpaStarImage4)
//            setStarBg(view: gpaStarImage5)
        default:
            print("drawGpaStarBackground() gpaIntPart is 0")
        }
    }
    
    func drawGpaStarFloatAreaBackground(point:Int, view:UIImageView) {
        if point <= 0 {
            clearStarBg(view: view)
            return
        }
        
        let realWidth = view.frame.size.width
        let pxToWidth = 9.0/UIScreen.main.scale
        let cvWidth = realWidth - (pxToWidth * 2.0)
        
        var alphaWidth = (cvWidth / 10.0) * CGFloat(point)
        alphaWidth = round(alphaWidth)
        
        UIGraphicsBeginImageContext(view.frame.size)
        UIGraphicsGetCurrentContext()?.setFillColor(UIColor(rgb: 0xA0A0A0).cgColor)
        
        let rect = CGRect(x: 0, y: 0, width: alphaWidth+pxToWidth, height: view.frame.size.height)
        UIGraphicsGetCurrentContext()?.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)
    }
}
