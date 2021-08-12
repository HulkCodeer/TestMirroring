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

    
//    @IBOutlet var chargerStatusImg: UIImageView!        // 충전기 상태(이미지)
//    @IBOutlet var callOutStatus: UILabel!               // 충전기 상태
//    @IBOutlet weak var dstLabel: UILabel!               // 현 위치에서 거리
    // 충전소 정보
//    @IBOutlet var powerLb: UILabel!                     // 충전속도
//    @IBOutlet var priceLb: UILabel!                     // 충전가격
    
//    @IBOutlet var powerView: UILabel!                   // 충전속도(view)
    @IBOutlet weak var companyLabel: UILabel!           // 운영기관(이름)
                    
    @IBOutlet var companyView: UIStackView!             // 운영기관(view)
    @IBOutlet weak var timeLabel: UILabel!              // 운영시간
    @IBOutlet weak var callLb: UILabel!                 // 전화번호
//    @IBOutlet var indoorView: UIView!                   // 설치형태(실내)
//    @IBOutlet var outdoorView: UIView!                  // 설치형태(실외)
//    @IBOutlet var canopyView: UIView!                   // 설치형태(캐노피)
    @IBOutlet var checkingView: UILabel!                 // 설치형태(확인중)
    @IBOutlet var kakaoMapView: UIView!                 // 스카이뷰(카카오맵)
    
    @IBOutlet weak var memoLabel: UILabel!              // 메모
    @IBOutlet var memoView: UIStackView!                // 메모(view)

    @IBOutlet var reportBtn: UIView!                    // 제보하기
    
    // 지킴이
//    @IBOutlet weak var guardView: UIView!
//    @IBOutlet weak var guardImage: UIImageView!
//    @IBOutlet weak var guardFixLabel: UILabel!
//    @IBOutlet weak var guardReportBtn: UIButton!
//    @IBOutlet weak var guardEnvBtn: UIButton!
//    @IBOutlet weak var guardKepcoBtn: UIButton!
    
    // 충전기 정보(list)
    @IBOutlet weak var boardTableView: BoardTableView!
    @IBOutlet weak var cidTableView: CidTableView!
    @IBOutlet weak var CidTableHeightConstraint: NSLayoutConstraint!
 
    var mainViewDelegate: MainViewDelegate?
    var charger: ChargerStationInfo?
    var checklistUrl: String?
    var isExistAddBtn = false
    
    // Charge station info(summary)
    var stationInfoArr = [String:String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var boardList: Array<BoardItem> = Array<BoardItem>()
    
    fileprivate var moveHomePageBtn: FABButton!
    fileprivate var moveAppStoreBtn: FABButton!
    
    private var phoneNumber:String? = nil
    private var homePage:String? = nil
    private var appStore:String? = nil
    
    var shareUrl = ""
    
    var mapView:MTMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareActionBar()
        prepareBoardTableView()
        preparePagingView()
//        prepareGuard()  지킴이 삭제

        getChargerInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.boardTableView.setNeedsDisplay()
    }
    
    override func viewWillLayoutSubviews() {
        // btn border
//        self.startPointBtn.setBorderRadius([.bottomLeft, .topLeft], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
//        self.endPointBtn.setBorderRadius([.bottomRight, .topRight], radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
//        self.naviBtn.setBorderRadius(.allCorners, radius: 3, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
//        self.addPointBtn.setBorderRadius(.allCorners, radius: 0, borderColor: UIColor(hex: "#C8C8C8"), borderWidth: 1)
// self.reportBtn.setBorderRadius(.allCorners, radius: 3, borderColor: UIColor(hex: "#33A2DA"), borderWidth: 1)
        // install round
//        self.indoorView.roundCorners(.allCorners, radius: 3)
//        self.outdoorView.roundCorners(.allCorners, radius: 3)
//        self.canopyView.roundCorners(.allCorners, radius: 3)
        
        // charger power round
//        self.powerView.roundCorners(.allCorners, radius: 3)
//        if isExistAddBtn {
//            self.addPointBtn.isHidden = false
//            self.naviBtn.isHidden = true
//        }else if !isExistAddBtn{
//            self.addPointBtn.isHidden = true
//            self.naviBtn.isHidden = false
//        }
    }
    
    @objc func mapViewTap(gesture : UIPanGestureRecognizer!) {
        gesture.cancelsTouchesInView = false
    }
    
    // MARK: - Action for button
//    @IBAction func onClickBookmark(_ sender: Any) {
//        self.bookmark()
//    }
//
//    @IBAction func onClickStartPoint(_ sender: Any) {
//        self.mainViewDelegate?.setStartPoint()
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func onClickEndPoint(_ sender: Any) {
//        self.mainViewDelegate?.setEndPoint()
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func onClickAddPoint(_ sender: Any) {
//        self.mainViewDelegate?.setStartPath()
//        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
//    }
    
//    @IBAction func onClickNavi(_ sender: UIButton) {
//        if let chargerData = charger {
//            if let stationDto = chargerData.mStationInfoDto {
//                let snm = callOutTitle.text ?? ""
//                let lng = stationDto.mLongitude ?? 0.0
//                let lat = stationDto.mLatitude ?? 0.0
//                UtilNavigation().showNavigation(vc: self, snm: snm, lat: lat, lng: lng)
//            }
//        }
//    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func preparePagingView() {
        let viewPagerController = ViewPagerController(charger: self.charger!)
        addChildViewController(viewPagerController)
//        self.setCallOutFavoriteIcon(charger: self.charger!)
//
//        let report = UITapGestureRecognizer(target: self, action: #selector(self.onClickReportChargeBtn))
//        self.reportBtn.addGestureRecognizer(report)
    }
    
    func getChargerInfo() {
        getStationDetailInfo()
        getFirstBoardData()
        setDetailLb()
        initKakaoMap()
    }
    
    func setDetailLb() {
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
//                // 충전소 이름
//                self.callOutTitle.text = stationDto.mSnm
//                // 주소
//                self.setAddr(stationDto: stationDto)
                // 설치 형태
                self.stationArea(stationDto: stationDto)
                // 충전 가격
//                setChargePrice(stationDto: stationDto)
            }
            
            // 운영기관 이미지
//            setCompanyIcon(chargerData: chargerData)
            
            // 충전기 상태
//            self.callOutStatus.text = chargerData.cidInfo.cstToString(cst: chargerData.mTotalStatus ?? 2)
            
            // 충전 속도
    //        self.powerLb.text = chargerData.getChargerPower(power: (chargerData.mPower)!, type: (chargerData.mTotalType)!)
            
            // 충전기 상태별 마커 이미지
    //        let chargeState = self.callOutStatus.text
    //        stationInfoArr[chargeState ?? ""] = "chargeState"
    //        self.chargerStatusImg.image = chargerData.getChargeStateImg(type: chargeState!)
            
            // 충전소 거리
//            if let currentLocatin = MainViewController.currentLocation {
//                getDistance(curPos: currentLocatin, desPos: chargerData.marker.getTMapPoint())
//            } else {
//                self.dstLabel.text = "현재 위치를 받아오지 못했습니다."
//            }
        }
    }
    
    
//    func setAddr(stationDto: StationInfoDto) {
//        if let addr = stationDto.mAddress{
//            if let addrDetail = stationDto.mAddressDetail{
//                self.addressLabel.text = addr+"\n"+addrDetail
//            }else{
//                self.addressLabel.text = addr
//            }
//        }else{
//            self.addressLabel.text = "신규 충전소로, 주소 업데이트 중입니다."
//        }
//    }
//    
    func stationArea(stationDto:StationInfoDto) {
        let roof = String(stationDto.mRoof ?? "확인중")
        let area:String!
        var color:String! = "content-primary"
        switch roof {
        case "0":  // outdoor
            area = "실외"
            break
        case "1":  // indoor
            area = "실내"
            break
        case "2":  // canopy
            area = "캐노피"
            break
        case "N": // Checking
            area = "확인중"
            color = "content-tertiary"
            break
        default:
            area = "확인중"
            color = "content-tertiary"
            break
        }
        self.checkingView.text = area
        self.checkingView.textColor = UIColor.init(named:color)
    }
    
    func setChargePrice(stationDto: StationInfoDto) {
//        switch stationDto.mPay {
//            case "Y":
//                self.priceLb.text = "유료"
//            case "N":
//                self.priceLb.text = "무료"
//            default:
//                self.priceLb.text = "시범운영"
//            }
    }
    
//    func setCompanyIcon(chargerData: ChargerStationInfo) {
//        if chargerData.getCompanyIcon() != nil{
//            self.companyImg.image = chargerData.getCompanyIcon()
//        }else {
//            self.companyImg.image = UIImage(named: "icon_building_sm")
//        }
//    }
    
    func getDistance(curPos: TMapPoint, desPos: TMapPoint) {
        if desPos.getLatitude() == 0 || desPos.getLongitude() == 0 {
//            self.dstLabel.text = "현재 위치를 받아오지 못했습니다."
        } else {
//            self.dstLabel.text = "계산중"
            
            DispatchQueue.global(qos: .background).async {
                let tMapPathData = TMapPathData.init()
                if let path = tMapPathData.find(from: curPos, to: desPos) {
                    let distance = Double(path.getDistance() / 1000).rounded()

                    DispatchQueue.main.async {
//                        self.dstLabel.text = "여기서 \(distance) Km"
                    }
                } else {
                    DispatchQueue.main.async {
//                        self.dstLabel.text = "거리를 계산할 수 없습니다."
                    }
                }
            }
        }
    }
    
    func initKakaoMap(){
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                self.mapView = MTMapView(frame: self.kakaoMapView.bounds)
                let mapPoint:MTMapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude:  (stationDto.mLatitude)!, longitude: (stationDto.mLongitude)!))
                
                if let mapView = mapView {
                    mapView.delegate = self
                    mapView.baseMapType = .hybrid
                    mapView.setMapCenter(mapPoint, zoomLevel: 2, animated: true)

                    let poiItem = MTMapPOIItem()
                    poiItem.markerType = MTMapPOIItemMarkerType.customImage
                    poiItem.tag = 1
                    poiItem.showAnimationType = .dropFromHeaven
                    poiItem.mapPoint = mapPoint
                    poiItem.customImage = UIImage(named: "skyview_point")
                    mapView.add(poiItem)
                    
                    self.kakaoMapView.addSubview(self.mapView!)
                    let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(mapViewTap(gesture:)))
                    self.kakaoMapView.addGestureRecognizer(gesture)
                }
            }
        }
    }
    
    // MARK: - Server Communications
    
    func getStationDetailInfo() {
        if let chargerData = charger {
            Server.getStationDetail(chargerId: chargerData.mChargerId!) { (isSuccess, value) in
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
    }
    
    func setStationInfo(json: JSON) {
        // 운영기관
        if !json["op"].stringValue.isEmpty {
            self.companyLabel.text = json["op"].stringValue
        } else {
            self.companyView.isHidden = true
        }
        
        // 이용시간
        if json["ut"].stringValue.isEmpty {
            self.timeLabel.text = "-"
        } else {
            self.timeLabel.text = json["ut"].stringValue
        }
        
        // 메모
        let memo = json["mm"].stringValue
        if !memo.isEmpty {
            if memo.equals("") {
                self.memoView.isHidden = true
                detailViewResize(view: self.memoView)
            } else {
                self.memoLabel.text = memo
                self.memoView.visible()
            }
        } else {
            self.memoView.isHidden = true
            detailViewResize(view: self.memoView)
        }
        
        // 센터 전화번호
        if !json["tel"].stringValue.isEmpty {
            self.phoneNumber = json["tel"].stringValue
            self.callLb.text = self.phoneNumber
            let tap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapFunction))
            self.callLb.isUserInteractionEnabled = true
            self.callLb.addGestureRecognizer(tap)
        } else {
            self.callLb.text = "등록된 전화번호가 없습니다."
        }
        
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
        
        if let chargerData = charger {
            ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerData.mChargerId!)?.changeStatus(status: stationSt)
        }
        self.mainViewDelegate?.redrawCalloutLayer()
        self.cidTableView.setCidList(chargerList: cidList)
        self.cidTableView.reloadData()
        self.adjustHeightOfTableview()
        
        self.showMenuBtn()
    }
    
    // DetailView reSize
    func detailViewResize(view:UIView) {
        self.detailView.frame.size = CGSize(width: self.detailView.frame.size.width, height: self.detailView.frame.size.height-view.frame.size.height)
    }
    
    // TODO: bookmark
//    func bookmark() {
//        if MemberManager().isLogin() {
//            ChargerManager.sharedInstance.setFavoriteCharger(charger: self.charger!) { (charger) in
//                self.setCallOutFavoriteIcon(charger: charger)
//                if charger.mFavorite {
//                    Snackbar().show(message: "즐겨찾기에 추가하였습니다.")
//                } else {
//                    Snackbar().show(message: "즐겨찾기에서 제거하였습니다.")
//                }
//            }
//        } else {
//            MemberManager().showLoginAlert(vc: self)
//        }
//    }
    
//    func setCallOutFavoriteIcon(charger: ChargerStationInfo) {
//        if charger.mFavorite {
//            self.callOutFavorite.setImage(UIImage(named: "bookmark_on"), for: .normal)
//        } else {
//            self.callOutFavorite.setImage(UIImage(named: "bookmark"), for: .normal)
//        }
//    }
    
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
        
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                navigationItem.hidesBackButton = true
                navigationItem.titleLabel.text = (stationDto.mSnm)!
                navigationItem.leftViews = [backButton]
                navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
            }
        }
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
//        self.cidTableView.estimatedRowHeight = 50
//        self.cidTableView.estimatedRowHeight = CidTableView.Constants.cellHeight
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
        if let chargerData = charger {
            Server.getChargerBoard(chargerId: chargerData.mChargerId!) { (isSuccess, value) in
                if isSuccess {
                    self.boardList.removeAll()
                    let json = JSON(value)
                    let boardJson = json["list"]
                    for json in boardJson.arrayValue {
                        let boardData = BoardItem(bJson: json)
                        self.boardList.append(boardData)
                    }
                    self.boardTableView.boardList = self.boardList
                    self.boardTableView.reloadData()
                }
            }
        }
    }
    
    func getNextBoardData() {
    }
    
    func boardEdit(tag: Int) {
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let editVC:EditViewController = boardStoryboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_EDIT_MODE
        editVC.charger = self.charger
        editVC.originBoardData = self.boardList[tag]
        editVC.editViewDelegate = self

        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    func boardDelete(tag: Int) {
        let dialogMessage = UIAlertController(title: "Notice", message: "게시글을 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(ACTION) -> Void in
            Server.deleteBoard(category: Board.BOARD_CATEGORY_CHARGER, boardId: self.boardList[tag].boardId!) { (isSuccess, value) in
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
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let editVC:EditViewController = boardStoryboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
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
            Server.deleteReply(category: Board.BOARD_CATEGORY_CHARGER, boardId: replyValue.replyId!) { (isSuccess, value) in
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
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let editVC:EditViewController = boardStoryboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.REPLY_NEW_MODE
        editVC.originBoardId = tag
        editVC.editViewDelegate = self
        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    func goToStation(tag: Int) {}
}

extension DetailViewController: EditViewDelegate {
    
    func postBoardData(content: String, hasImage: Int, picture: Data?) {
        Server.postBoard(category: Board.BOARD_CATEGORY_CHARGER, bmId: -1, chargerId: (self.charger?.mChargerId)!, content: content, hasImage: hasImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if hasImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture{
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: json["board_id"].stringValue, completion: { (isSuccess, value) in
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
        Server.editBoard(category: Board.BOARD_CATEGORY_CHARGER, boardId: boardId, content: content, editImage: editImage) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                if editImage == 1 {
                    let filename =  json["file_name"].stringValue
                    if let data = picture {
                        Server.uploadImage(data: data, filename: "\(filename).jpg", kind: Const.CONTENTS_BOARD_IMG, targetId: json["board_id"].stringValue, completion: { (isSuccess, value) in
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
        Server.postReply(category: Board.BOARD_CATEGORY_CHARGER, boardId: boardId, content: content) { (isSuccess, value) in
            if isSuccess {
                self.getFirstBoardData()
            }
        }
    }
    
    func editReplyData(content: String, replyId: Int) {
        Server.editReply(category: Board.BOARD_CATEGORY_CHARGER, replyId: replyId, content: content) { (isSuccess, value) in
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
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let editVC:EditViewController = boardStoryboard.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        editVC.mode = EditViewController.BOARD_NEW_MODE
        editVC.charger = self.charger
        editVC.editViewDelegate = self //EditViewDelegate
        self.navigationController?.push(viewController: editVC, subtype: kCATransitionFromTop)
    }
    
    @objc
    fileprivate func onClickReportChargeBtn() {
        if MemberManager().isLogin() {
            if let chargerInfo = self.charger {
                let reportStoryboard = UIStoryboard(name : "Report", bundle: nil)
                let reportChargeVC = reportStoryboard.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
                reportChargeVC.info.charger_id = chargerInfo.mChargerId
                
                self.present(AppSearchBarController(rootViewController: reportChargeVC), animated: true, completion: nil)
            }
        } else {
            MemberManager().showLoginAlert(vc:self)
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
