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
 
    @IBOutlet weak var priceTypeLb: UILabel!
    @IBOutlet weak var priceTableView: UIStackView!
    @IBOutlet weak var priceBtnView: UIView!
    @IBOutlet weak var slowPriceLb: UILabel!
    @IBOutlet weak var fastPriceLb: UILabel!
    @IBOutlet weak var priceInfoBtn: UIButton!
    @IBOutlet weak var priceAlertLb: UILabel!
    @IBOutlet weak var priceTableHeader: UIStackView!
    @IBOutlet weak var priceTableHeight: NSLayoutConstraint!
    
    var charger: ChargerStationInfo?
    var boardList: [BoardListItem] = [BoardListItem]()
    
    private var phoneNumber:String? = nil
        
    var mapView:MTMapView?
    var summaryView:SummaryView!
    var isRouteMode: Bool = false
    var currentPage = 0

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareBoardTableView()
        prepareChargerInfo()
        prepareSummaryView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCompletion(_:)), name: Notification.Name("ReloadData"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        self.accessWarningView.layer.cornerRadius = 16
        self.priceInfoBtn.layer.cornerRadius = 6
        let view = UIView(frame:self.priceTableHeader.bounds)
        view.backgroundColor = UIColor(named: "background-tertiary")
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.priceTableHeader.insertSubview(view, at: 0)
    }
    
    @objc func mapViewTap(gesture : UIPanGestureRecognizer!) {
        gesture.cancelsTouchesInView = false
    }
    
    @objc func updateCompletion(_ notification: Notification) {
        fetchFirstBoard(mid: "station", sort: .LATEST, mode: Board.ScreenType.FEED.rawValue)
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
        summaryView.layoutAddPathSummary(hiddenAddBtn: !isRouteMode)
    }
    
    func prepareChargerInfo() {
        setStationInfo()
        setDetailLb()
        fetchFirstBoard(mid: "station", sort: .LATEST, mode: Board.ScreenType.FEED.rawValue)
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
        guard let charger = charger else { return }
        guard let stationDto = charger.mStationInfoDto else { return }
        let mapPoint: MTMapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: stationDto.mLatitude ?? .zero, longitude: stationDto.mLongitude ?? .zero))
        
        mapView = MTMapView(frame: kakaoMapView.frame)
        
        if let mapView = mapView {
            mapView.delegate = self
            mapView.baseMapType = .hybrid
            mapView.setMapCenter(mapPoint, zoomLevel: 4, animated: true)
            kakaoMapView.addSubview(mapView)
            
            let poiItem = MTMapPOIItem()
            poiItem.markerType = .customImage
            poiItem.mapPoint = mapPoint
            poiItem.customImage = UIImage(named: "marker_satellite")
            mapView.add(poiItem)
            
            let gesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(mapViewTap(gesture:)))
            kakaoMapView.addGestureRecognizer(gesture)
        }
    }
    
    func setStationInfo() {
        if let chargerData = charger {
            ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerData.mChargerId!)?.changeStatus(status: chargerData.mTotalStatus!, markerChange:  false)
            
            self.cidTableView.setCidInfoList(infoList: chargerData.cidInfoList)
            
            self.accessWarningView.gone()
            if let limit = chargerData.mLimit, limit == "Y" {
                self.accessWarningView.visible()
            } else {
                self.accessWarningImg.isHidden = true
                self.accessWarningLb.isHidden = true
                detailViewResize(viewHeight: self.accessWarningView.layer.height)
            }
            
            if chargerData.mStationInfoDto?.mPay == "Y" {
                if chargerData.hasPriceInfo {
                    if !chargerData.slowPrice.isEmpty {
                        self.slowPriceLb.text = chargerData.slowPrice
                        self.fastPriceLb.text = chargerData.fastPrice
                    } else {
                        if !self.priceTableView.isHidden {
                            detailViewResize(viewHeight: 80)
                        }
                        self.priceTableView.isHidden = true
                        self.priceTableHeight.constant = 88
                    }
                    self.priceAlertLb.isHidden = true
                    self.priceInfoBtn.isHidden = false
                } else {
                    if !self.priceTableView.isHidden {
                        detailViewResize(viewHeight: 80)
                    }
                    self.priceTableView.isHidden = true
                    self.priceTableHeight.constant = 88
                    self.priceAlertLb.isHidden = false
                    self.priceInfoBtn.isHidden = true
                }
            } else {
                if !self.priceTableView.isHidden && !self.priceBtnView.isHidden {
                    detailViewResize(viewHeight: 132)
                }
                self.priceTypeLb.text = "무료"
                self.priceTableView.isHidden = true
                self.priceBtnView.isHidden = true
                self.priceTableHeight.constant = 36
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
    
    @IBAction func onClickPriceInfo(_ sender: Any) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsViewControll = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        termsViewControll.tabIndex = .StationPrice
        termsViewControll.subParams = "company_id=" + (charger?.mStationInfoDto?.mCompanyId)!
        self.navigationController?.push(viewController: termsViewControll)
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
        MTMapView.clearMapTilePersistentCache()
        self.navigationController?.pop(transitionType: kCATransitionReveal, subtype: kCATransitionFromBottom)
    }
}

extension DetailViewController: BoardTableViewDelegate {
    func fetchFirstBoard(mid: String, sort: Board.SortType, mode: String) {
        if let chargerData = charger {
            self.currentPage = 1
            self.boardTableView.isNoneHeader = true
            Server.fetchBoardList(mid: "station", page: "\(self.currentPage)", mode: mode, sort: sort.rawValue, searchType: "station", searchKeyword: chargerData.mChargerId!) { (isSuccess, value) in
                
                if isSuccess {
                    guard let data = value else { return }
                    let decoder = JSONDecoder()
                    
                    do {
                        let result = try decoder.decode(BoardResponseData.self, from: data)
                        
                        if let updateList = result.list {
                            self.boardList.removeAll()
                            self.boardList += updateList
                              
                            self.boardTableView.category = Board.CommunityType.CHARGER.rawValue
                            self.boardTableView.communityBoardList = self.boardList
                            self.boardTableView.isFromDetailView = true
                            
                            DispatchQueue.main.async {
                                self.boardTableView.reloadData()
                            }
                        }
                    } catch {
                        debugPrint("error")
                    }
                } else {
                    self.boardTableView.category = Board.CommunityType.CHARGER.rawValue
                    self.boardTableView.communityBoardList = self.boardList
                    self.boardTableView.isFromDetailView = true
                }
            }
        }
    }
    
    func fetchNextBoard(mid: String, sort: Board.SortType, mode: String) {
        if let chargerData = charger {
            
            self.currentPage = self.currentPage + 1
            self.boardTableView.isNoneHeader = true
            Server.fetchBoardList(mid: "station", page: "\(self.currentPage)", mode: Board.ScreenType.FEED.rawValue, sort: sort.rawValue, searchType: "station", searchKeyword: chargerData.mChargerId!) { (isSuccess, value) in
                
                if isSuccess {
                    guard let data = value else { return }
                    let decoder = JSONDecoder()
                    
                    do {
                        let result = try decoder.decode(BoardResponseData.self, from: data)
                        
                        if let updateList = result.list {
                            self.boardList += updateList
                              
                            self.boardTableView.category = Board.CommunityType.CHARGER.rawValue
                            self.boardTableView.communityBoardList = self.boardList
                            self.boardTableView.isFromDetailView = true
                            
                            DispatchQueue.main.async {
                                self.boardTableView.reloadData()
                            }
                        }
                    } catch {
                        debugPrint("error")
                    }
                } else {
                    
                }
            }
        }
    }
    
    func didSelectItem(at index: Int) {
        guard let documentSRL = boardList[index].document_srl,
        !documentSRL.elementsEqual("-1") else { return }

        let storyboard = UIStoryboard(name: "BoardDetailViewController", bundle: nil)
        guard let boardDetailTableViewController = storyboard.instantiateViewController(withIdentifier: "BoardDetailViewController") as? BoardDetailViewController else { return }

        boardDetailTableViewController.category = Board.CommunityType.CHARGER.rawValue
        boardDetailTableViewController.document_srl = documentSRL
        boardDetailTableViewController.isFromStationDetailView = true

        self.navigationController?.push(viewController: boardDetailTableViewController)
    }
    
    fileprivate func prepareBoardTableView() {
        self.cidTableView.rowHeight = UITableViewAutomaticDimension
        self.cidTableView.separatorStyle = .none
        
        // UITableView cell(게시판) 높이를 자동으로 설정
        self.boardTableView.tableViewDelegate = self
        self.boardTableView.rowHeight = UITableViewAutomaticDimension
        self.boardTableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.boardTableView.separatorStyle = .none
        self.boardTableView.allowsSelection = true
        
        // Table header 추가
        self.boardTableView.tableHeaderView = detailView
        self.boardTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.boardTableView.estimatedSectionHeaderHeight = 25  // 25
    }
    
    func showImageViewer(url: URL, isProfileImageMode: Bool) {
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        guard let imageVC: EIImageViewerViewController = boardStoryboard.instantiateViewController(withIdentifier: "EIImageViewerViewController") as? EIImageViewerViewController else { return }
        imageVC.mImageURL = url
        imageVC.isProfileImageMode = isProfileImageMode
    
        self.navigationController?.push(viewController: imageVC)
    }
}

extension DetailViewController {
    fileprivate func showMenuBtn() {
        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = UIColor.clear
        actionButton.buttonImage = UIImage(named: "detail_plus")
        if let image = actionButton.buttonImage {
            actionButton.buttonImageSize = image.size
        }
        
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
        let storyboard = UIStoryboard.init(name: "BoardWriteViewController", bundle: nil)
        guard let boardWriteViewController = storyboard.instantiateViewController(withIdentifier: "BoardWriteViewController") as? BoardWriteViewController else { return }
        
        if let chargerData = charger {
            if let stationDto = chargerData.mStationInfoDto {
                boardWriteViewController.chargerInfo["chargerId"] = stationDto.mChargerId
                boardWriteViewController.chargerInfo["chargerName"] = stationDto.mSnm
            }
        }
        
        boardWriteViewController.category = Board.CommunityType.CHARGER.rawValue
        boardWriteViewController.popCompletion = { [weak self] in
            guard let self = self else { return }
            self.fetchFirstBoard(mid: Board.CommunityType.CHARGER.rawValue, sort: .LATEST, mode: Board.ScreenType.FEED.rawValue)
        }
        
        self.navigationController?.push(viewController: boardWriteViewController)
    }
    
    @objc
    fileprivate func onClickReportChargeBtn() {
        if MemberManager.shared.isLogin {
            if let chargerInfo = self.charger {
                let reportStoryboard = UIStoryboard(name : "Report", bundle: nil)
                let reportChargeVC = reportStoryboard.instantiateViewController(withIdentifier: "ReportChargeViewController") as! ReportChargeViewController
                reportChargeVC.info.charger_id = chargerInfo.mChargerId
                
                self.present(AppNavigationController(rootViewController: reportChargeVC), animated: true, completion: nil)
            }
        } else {
            MemberManager().showLoginAlert()
        }
    }
}

extension DetailViewController {
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
