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
    
    @IBOutlet weak var summaryLayout: UIView!
    @IBOutlet weak var companyLabel: UILabel!           // 운영기관(이름)
                    
    @IBOutlet weak var companyView: UIStackView!             // 운영기관(view)
    @IBOutlet weak var timeLabel: UILabel!              // 운영시간
    @IBOutlet weak var callLb: UILabel!                 // 전화번호

    @IBOutlet weak var accessWarningView: UIView!
    @IBOutlet weak var accessWarningImg: UIImageView!
    @IBOutlet weak var accessWarningLb: UILabel!
    
    @IBOutlet weak var checkingView: UILabel!                 // 설치형태(확인중)
    @IBOutlet weak var kakaoMapView: UIView!                 // 스카이뷰(카카오맵)
    @IBOutlet weak var mapSwitch: UISwitch!
    @IBOutlet weak var moveMapBtn: UIButton! // 충전소위치로 가기 버튼(카카오맵)
    @IBOutlet weak var call: UILabel!                        // 전화하기
    
    @IBOutlet weak var memoLabel: UILabel!              // 메모
    @IBOutlet weak var memoView: UIStackView!                // 메모(view)
    
    
    // 충전기 정보(list)
    @IBOutlet weak var boardTableView: BoardTableView!
    @IBOutlet weak var cidTableView: CidTableView!
    @IBOutlet weak var cidTableHeightConstraint: NSLayoutConstraint!
 
    var charger: ChargerStationInfo?
    var isExistAddBtn = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var boardList: Array<BoardItem> = Array<BoardItem>()
    
    private var phoneNumber:String? = nil
    private var homePage:String? = nil
    private var appStore:String? = nil
        
    var mapView:MTMapView?
    
    var summaryViewTag = 20
    var summaryView:SummaryView!
    var stationJson:JSON!
    
    var isRouteMode:Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareBoardTableView()
        prepareChargerInfo()
    }
    
    override func viewWillLayoutSubviews() {
        prepareSummaryView()
        self.accessWarningView.layer.cornerRadius = 16
    }
    
    @objc func mapViewTap(gesture : UIPanGestureRecognizer!) {
        gesture.cancelsTouchesInView = false
    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func prepareSummaryView() {
        let window = UIApplication.shared.keyWindow!
        var frameTest:CGRect = summaryLayout.frame
        frameTest.size.width = window.frame.bounds.width
        if summaryView == nil {
            summaryView = SummaryView(frame: frameTest)
        }
        summaryLayout.addSubview(summaryView)
        summaryView.delegate = self
        summaryView.setLayoutType(charger: charger!, type: SummaryView.SummaryType.DetailSummary)
//        summaryView.layoutDetailSummary()
        summaryView.layoutAddPathSummary(hiddenAddBtn: !isRouteMode)
    }
    
    func prepareChargerInfo() {
        setStationInfo()
        setDetailLb()
        getFirstBoardData()
        initKakaoMap()
    }
    
    func setDetailLb() {
        mapSwitch.transform = CGAffineTransform(scaleX: 0.7, y: 0.645)
        moveMapBtn.setCornerCircle(frame: moveMapBtn.frame)
        
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                // 설치 형태
                self.stationArea(stationDto: stationDto)
                
                self.callLb.text = "등록된 정보가 없습니다."
                self.call.isHidden = true
                if stationDto.mTel != nil {
                    if !stationDto.mTel!.isEmpty && !stationDto.mTel!.equalsIgnoreCase(compare: "null"){
                        self.call.isHidden = false
                        let tap = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.tapFunction))
                        self.call.isUserInteractionEnabled = true
                        self.call.addGestureRecognizer(tap)
                        
                        self.callLb.textColor = UIColor.init(named: "content-primary")
                        self.callLb.text = stationDto.mTel
                        self.phoneNumber = stationDto.mTel
                    }
                }else{
                    self.callLb.textColor = UIColor.init(named: "content-tertiary")
                }
                
                self.companyLabel.text = "기타"
                if stationDto.mOperator != nil {
                    if !stationDto.mOperator!.isEmpty && !stationDto.mOperator!.equalsIgnoreCase(compare: "null") {
                        self.companyLabel.text = stationDto.mOperator
                    }
                }
                
                self.timeLabel.text = "등록된 정보가 없습니다."
                if stationDto.mUtime != nil {
                    if !stationDto.mUtime!.isEmpty && !stationDto.mUtime!.equalsIgnoreCase(compare: "null"){
                        self.timeLabel.textColor = UIColor.init(named: "content-primary")
                        self.timeLabel.text = stationDto.mUtime
                    }else {
                        self.timeLabel.textColor = UIColor.init(named: "content-tertiary")
                    }
                }
                
                if stationDto.mMemo != nil {
                    if !stationDto.mMemo!.isEmpty && !stationDto.mMemo!.equalsIgnoreCase(compare: "null"){
                        self.memoLabel.text = stationDto.mMemo
                        self.memoView.visible()
                        self.memoView.isHidden = false
                        detailViewResize(viewHeight: -self.memoView.layer.height)
                    }else{
                        self.memoView.isHidden = true
                    }
                }
            }
        }
    }
    
    func stationArea(stationDto:StationInfoDto) {
        let roof = String(stationDto.mRoof ?? "N")
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
            area = "설치형태 확인중입니다."
            color = "content-tertiary"
        default:
            area = "설치형태 확인중입니다."
            color = "content-tertiary"
            break
        }
        self.checkingView.text = area
        self.checkingView.textColor = UIColor.init(named:color)
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
                    poiItem.customImage = UIImage(named: "marker_satellite")
                    mapView.add(poiItem)
                    
                    self.kakaoMapView.addSubview(self.mapView!)
                    let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(mapViewTap(gesture:)))
                    self.kakaoMapView.addGestureRecognizer(gesture)
                }
            }
        }
    }
    
    func setStationInfo() {
        if let chargerData = charger {
            ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerData.mChargerId!)?.changeStatus(status: chargerData.mTotalStatus!)
            
            
            self.cidTableView.setCidInfoList(infoList: chargerData.cidInfoList)
            
            self.accessWarningView.gone()
            if let limit = chargerData.mLimit, limit == "Y" {
                self.accessWarningView.visible()
            } else {
                self.accessWarningImg.isHidden = true
                self.accessWarningLb.isHidden = true
                detailViewResize(viewHeight: self.accessWarningView.layer.height)
            }
        }
        self.cidTableView.reloadData()
        self.adjustHeightOfTableview()
        
        self.showMenuBtn()
    }
    
    // DetailView reSize
    func detailViewResize(viewHeight:CGFloat) {
        self.detailView.frame.size = CGSize(width: self.detailView.frame.width, height: self.detailView.frame.height - viewHeight)
    }
    
    // MARK: - TableView Height
    
    func adjustHeightOfTableview() {
        let contentHeight = self.cidTableView.contentSize.height
        let expectedFrame = CGRect(x: 0, y: 0, width: self.detailView.frame.width, height: self.detailView.frame.height - self.cidTableHeightConstraint.constant + contentHeight)
        if !self.detailView.frame.equalTo(expectedFrame) {
            self.detailView.frame = expectedFrame
        }
        // set the height constraint accordingly
        UIView.animate(withDuration: 0.25, animations: {
            self.cidTableHeightConstraint.constant = contentHeight;
            self.view.needsUpdateConstraints()
            self.boardTableView.reloadData()
        }, completion: nil)
    }
    
    // [Map]
    // 충전소 위치 바로가기 버튼
    @IBAction func onClickMoveLocation(_ sender: Any) {
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                let mapPoint:MTMapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude:  (stationDto.mLatitude)!, longitude: (stationDto.mLongitude)!))
                mapView?.setMapCenter(mapPoint, animated: true)
            }
        }
    }
    // 맵 타입 변경 스위치
    @IBAction func onClickMapSwitch(_ sender: UISwitch) {
        if let map = mapView {
            if sender.isOn{
                map.baseMapType = .satellite
            }else{
                map.baseMapType = .standard
            }
        }
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.onClickCallBtn()
    }
}

extension DetailViewController {
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                navigationItem.hidesBackButton = true
                navigationItem.titleLabel.text = (stationDto.mSnm)!
                navigationItem.leftViews = [backButton]
                navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
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
        self.cidTableView.rowHeight = UITableViewAutomaticDimension
        self.cidTableView.separatorStyle = .none
        
        // UITableView cell(게시판) 높이를 자동으로 설정
        self.boardTableView.tableViewDelegate = self
        self.boardTableView.rowHeight = UITableViewAutomaticDimension
        self.boardTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.boardTableView.separatorStyle = .none
        
        self.boardTableView.allowsSelection = false
        
        // Table header 추가
        self.boardTableView.tableHeaderView = detailView
        self.boardTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.boardTableView.estimatedSectionHeaderHeight = 25  // 25
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
    
    func showImageViewer(url: URL) {
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let imageVC:EIImageViewerViewController = boardStoryboard.instantiateViewController(withIdentifier: "EIImageViewerViewController") as! EIImageViewerViewController
        imageVC.mImageURL = url;
    
        self.navigationController?.push(viewController: imageVC)
    }
    
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

extension DetailViewController : SummaryDelegate {
    func setCidInfoList() {
        self.setStationInfo()
    }
}
