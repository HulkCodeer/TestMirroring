//
//  ViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

import DropDown
import M13Checkbox
import SwiftyJSON
import Then
import NMapsMap
import SnapKit
import RxSwift
import RxCocoa
import AVFoundation
import ReactorKit
import RxViewController
import RxCoreLocation
import CoreLocation

internal final class MainViewController: UIViewController, StoryboardView {
    
    // constant
    let ROUTE_START = 0
    let ROUTE_END   = 1
    
    // user Default
    let defaults = UserDefault()
    
    private lazy var customNaviBar = MainNavigationBar()
    
    private lazy var myLocationButton = UIButton().then {
        $0.setImage(Icons.iconCurrentLocationMd.image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.addTarget(self, action: #selector(onClickMyLocation), for: .touchUpInside)
        $0.backgroundColor = Colors.backgroundPrimary.color
        
        $0.layer.cornerRadius = 20
        $0.layer.shadowRadius = 2.0
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 0.3
    }
    private lazy var reNewButton = UIButton().then {
        $0.setImage(Icons.iconRefreshMd.image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.addTarget(self, action: #selector(onClickRenewBtn), for: .touchUpInside)
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.tintColor = Colors.contentPrimary.color
        
        $0.layer.cornerRadius = 20
        $0.layer.shadowRadius = 2.0
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 0.3
    }
    
    private lazy var chargePriceContentView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true

        $0.layer.shadowRadius = 5
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        $0.layer.masksToBounds = false
    }

    private lazy var chargePriceIcon = UIImageView().then {
        $0.image = Icons.coinFillSm.image
        $0.contentMode = .scaleAspectFill
        $0.tintColor = Colors.nt6.color
    }
    private lazy var chargePriceLabel = UILabel().then {
        $0.text = "충전 요금 안내"
        $0.textColor = Colors.nt6.color
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    private lazy var chargePriceButton = UIButton()
    
    // Indicator View
    @IBOutlet weak var markerIndicator: UIActivityIndicatorView!
    
    // Filter View
    private lazy var filterStackView = UIStackView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fillProportionally
        $0.spacing = 0
    }
    private lazy var searchWayView = MainSearchWayView().then {
        $0.isHidden = true
    }
    @IBOutlet weak var filterBarView: NewFilterBarView!
    @IBOutlet weak var filterContainerView: FilterContainerView!
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    
    // Callout View
    @IBOutlet weak var callOutLayer: UIView!
    // Menu Button Layer
    private lazy var bottomMenuView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.layer.shadowRadius = 5
        $0.layer.shadowColor = UIColor.gray.cgColor
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        $0.layer.masksToBounds = false
    }
    private lazy var bottomMenuStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 8
    }
    
    //경로찾기시 거리표시 뷰 (call out)
    @IBOutlet weak var routeDistanceView: UIView!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    @IBOutlet var routeDistanceBtn: UIView!
    
    // MARK: VARIABLE
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var tMapView: TMapView? = nil
    private var tMapPathData: TMapPathData = TMapPathData.init()
    private var routeStartPoint: TMapPoint? = nil
    private var routeEndPoint: TMapPoint? = nil
    private lazy var destinationResultTableView = PoiTableView().then {
        $0.poiTableDelegate = self
        $0.isHidden = true
    }

    private lazy var naverMapView = NaverMapView(frame: .zero).then {
        $0.mapView.addCameraDelegate(delegate: self)
        $0.mapView.touchDelegate = self    
        ChargerManager.sharedInstance.delegate = self
    }
    var mapView: NMFMapView { naverMapView.mapView }
    private var summaryView: SummaryView!
    
    private var locationManager = CLLocationManager()
    private var chargerManager = ChargerManager.sharedInstance
    internal var selectCharger: ChargerStationInfo? = nil
    private var viaCharger: ChargerStationInfo? = nil
    
    // MARK: VARIABLE

    var sharedChargerId: String? = nil
    
    private var loadedChargers = false
    private var clusterManager: ClusterManager? = nil
    private var canIgnoreJejuPush = true

    internal var disposeBag = DisposeBag()
        
    private var bottomEvPaytooltipView: TooltipView?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMyLocationButton()

        routeDistanceView.isHidden = true
        
        prepareTmapAPI()
        
        prepareSummaryView()
        prepareNotificationCenter()
        prepareRouteView()
        prepareClustering()
            
        requestStationInfo()
        
        prepareCalloutLayer()
        
        GlobalDefine.shared.mainViewcon = self
        
        self.locationManager.delegate = self
        filterContainerView.delegate = self
                
        self.locationManager.rx
            .status
            .subscribe(with: self) { obj, status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    obj.naverMapView.moveToCurrentPostiion()
                    obj.locationManager.startUpdatingLocation()
                    
                default: obj.naverMapView.moveToCenterPosition()
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MapEvent.viewMainPage.logEvent()
        LoginHelper.shared.delegate = self
        
        let isProcessing = GlobalDefine.shared.tempDeepLink.isEmpty
        if !isProcessing {
            DeepLinkModel.shared.openSchemeURL(urlstring: GlobalDefine.shared.tempDeepLink)
        } else {
            self.locationManager.rx.status
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(with: self) { obj, status in
                    switch status {
                    case .authorizedWhenInUse:
                        guard let _reactor = obj.reactor, _reactor.currentState.isShowStartBanner == nil else { return }
                        Observable.just(MainReactor.Action.showMarketingPopup)
                            .bind(to: _reactor.action)
                            .disposed(by: obj.disposeBag)

                    default:
                        CLLocationManager().rx.isEnabled
                            .subscribe(with: obj) { obj, isEnable in
                                if isEnable {
                                    let popupModel = PopupModel(title: "위치권한을 허용해주세요",
                                                                message: "위치 권한을 허용해주시면, 사용자님 근처의 충전소 정보를 알려드릴게요.",
                                                                confirmBtnTitle: "권한 변경하기",
                                                                confirmBtnAction: {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                    }, textAlignment: .center, dimmedBtnAction: nil)

                                    let popup = ConfirmPopupViewController(model: popupModel)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                                    })
                                } else {
                                    obj.askPermission()
                                }
                            }
                            .disposed(by: obj.disposeBag)
                    }
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateClustering()
        if self.sharedChargerId != nil {
            self.selectChargerFromShared()
        }
        canIgnoreJejuPush = UserDefault().readBool(key: UserDefault.Key.JEJU_PUSH)// default : false                           
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // removeObserver 하면 안됨. addObserver를 viewdidload에서 함
        
        dismissBottomMenuTooltip()
    }
    
    // MARK: Make UI
    
    private func makeUI() {
        view.addSubview(customNaviBar)
        customNaviBar.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(customNaviBar.height)
        }

        makeFilter()        // 상단필터 & 상단 길찾기뷰.
        makeMap()
        
        view.addSubview(destinationResultTableView)
        destinationResultTableView.snp.makeConstraints {
            $0.top.equalTo(filterBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        makeBottomMenu()

        view.bringSubviewToFront(self.callOutLayer)
    }
    
    private func makeFilter() {
        view.addSubview(filterStackView)
        filterStackView.snp.makeConstraints {
            $0.top.equalTo(customNaviBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        filterStackView.addArrangedSubview(searchWayView)
        searchWayView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        filterStackView.addArrangedSubview(filterBarView)
        filterBarView.snp.makeConstraints {
            $0.height.equalTo(54)
        }
        filterStackView.addArrangedSubview(filterContainerView)
        filterContainerView.snp.makeConstraints {
            $0.height.equalTo(116)
        }
    }
    
    private func makeMap() {
        view.insertSubview(naverMapView, at: 0)
        naverMapView.snp.makeConstraints {
            $0.top.equalTo(customNaviBar)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        naverMapView.addSubview(reNewButton)
        reNewButton.snp.makeConstraints {
            $0.top.equalTo(filterStackView.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().inset(10)
            $0.size.equalTo(40)
        }

        naverMapView.addSubview(myLocationButton)
        myLocationButton.snp.makeConstraints {
            $0.top.equalTo(reNewButton.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().inset(10)
            $0.size.equalTo(40)
        }
    }
    
    private func makeBottomMenu() {
        view.addSubview(bottomMenuView)
        bottomMenuView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.height.equalTo(62)
        }
        
        view.addSubview(chargePriceContentView)
        chargePriceContentView.snp.makeConstraints {
            $0.bottom.equalTo(bottomMenuView.snp.top).inset(-12)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(34)
            $0.width.equalTo(134)
        }
        
        bottomMenuView.addSubview(bottomMenuStackView)
        bottomMenuStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }
        
        chargePriceContentView.addSubview(chargePriceIcon)
        chargePriceIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(14)
            $0.size.equalTo(20)
        }
        
        chargePriceContentView.addSubview(chargePriceLabel)
        chargePriceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(chargePriceIcon.snp.trailing).offset(4)
        }
        
        chargePriceContentView.addSubview(chargePriceButton)
        chargePriceButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: REACTORKIT
    
    internal func bind(reactor: MainReactor) {
        // 스토리보드 제거 후 loadView 이동 요망.
        makeUI()
        
        for bottomMenuType in MainReactor.BottomMenuType.allCases {
            let item = BottomMenuItem(
                menuType: bottomMenuType,
                reactor: reactor)
            bottomMenuStackView.addArrangedSubview(item)
            
            item.button.rx.tap
                .map { MainReactor.Action.selectedBottomMenu(bottomMenuType) }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
            switch bottomMenuType {
            case .evPay:
                guard let reqData = ABTestManager.shared.reqData(.mainBottomEVPay) else { break }
                let (_, tooltipMSG) = reqData
                let width: CGFloat = tooltipMSG.size(of: .systemFont(ofSize: 14)).width + 24
                let tipLeft: CGFloat = (width / 2) - 6
                bottomEvPaytooltipView = TooltipView(configure: TooltipView.Configure(tipLeftMargin: tipLeft, tipDirection: .bottom, maxWidth: width))
                
                guard let bottomEvPaytooltipView = bottomEvPaytooltipView else { return }
                bottomEvPaytooltipView.isHidden = true
                
                self.view.addSubview(bottomEvPaytooltipView)
                bottomEvPaytooltipView.snp.makeConstraints {
                    $0.width.equalTo(width)
                    $0.centerX.equalTo(item.button.snp.centerX)
                    $0.bottom.equalTo(item.button.snp.top).offset(-7)
                    $0.height.equalTo(50)
                }
                
                bottomEvPaytooltipView.show(message: tooltipMSG)
                
            default:
                break
            }
        }
        
        if !MemberManager.shared.isShowBottomMenuEVPayTooltip && !FCMManager.sharedInstance.originalMemberId.isEmpty {
            Observable.just(MainReactor.Action.openBottomEvPayTooltip)
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        bindAction(reactor: reactor)
        bindState(reactor: reactor)

        filterBarView.bind(reactor: reactor)
        filterContainerView.bind(reactor: reactor)
                                        
        reactor.state.compactMap { $0.isShowMarketingPopup }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, _ in
                let popupModel = PopupModel(title: "더 나은 충전 생활 안내를 위해 동의가 필요해요.",
                                            message:"EV Infra는 사용자님을 위해 도움되는 혜택 정보를 보내기 위해 노력합니다. 무분별한 광고 알림을 보내지 않으니 안심하세요!\n마케팅 수신 동의 변경은 설정 > 마케팅 정보 수신 동의에서 철회 가능합니다.",
                                            confirmBtnTitle: "동의하기",
                                            cancelBtnTitle: "다음에") { [weak self] in
                    guard let self = self else { return }
                    Observable.just(MainReactor.Action.setAgreeMarketing(true))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                } cancelBtnAction: { [weak self] in
                    guard let self = self else { return }
                    Observable.just(MainReactor.Action.setAgreeMarketing(false))
                        .bind(to: reactor.action)
                        .disposed(by: self.disposeBag)
                }
                
                let popup = ConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                }
                                                                                
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isShowStartBanner }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, _ in
                GlobalAdsReactor.sharedInstance.state.compactMap { $0.startBanner }
                    .asDriver(onErrorJustReturn: AdsInfo(JSON.null))
                    .drive(onNext: { adInfo in
                        let keepDateStr = UserDefault().readString(key: UserDefault.Key.AD_KEEP_DATE_FOR_A_WEEK)
                        var components = DateComponents()
                        components.day = -7
                        let keepDate = keepDateStr.isEmpty ? Calendar.current.date(byAdding: components, to: Date()) : Date().toDate(data: keepDateStr)
                                   
                        guard let _keepDate = keepDate else { return }
                        let difference = Calendar.current.dateComponents([.day], from: _keepDate, to: Date())
                        if let day = difference.day, day > 6 {
                            let viewcon = StartBannerViewController(reactor: GlobalAdsReactor.sharedInstance)
                            viewcon.mainReactor = reactor
                            GlobalDefine.shared.mainNavi?.present(viewcon, animated: false, completion: nil)
                        }
                    })
                    .disposed(by: obj.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.selectedFilterInfo }
            .asDriver(onErrorJustReturn: (filterTagType: .price, isSeleted: false))
            .drive(with: self) { obj, selectedFilterInfo in
                obj.filterContainerView.isHidden = !selectedFilterInfo.isSeleted
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isEvPayFilter }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, _ in
                self.drawMapMarker()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.isShowFilterSetting }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { obj, isShow in
                let chargerFilterViewController = UIStoryboard(name : "Filter", bundle: nil).instantiateViewController(ofType: ChargerFilterViewController.self)
                chargerFilterViewController.delegate = obj
                GlobalDefine.shared.mainNavi?.push(viewController: chargerFilterViewController)
            }
            .disposed(by: self.disposeBag)

    }
    
    // MARK: - bindAction
    private func bindAction(reactor: MainReactor) {
        self.rx.viewWillAppear
            .subscribe(with: self) { owner, _ in
                Observable.just(MainReactor.Action.setPaymentStatus)
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
                
                owner.setChargingStatus(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        self.rx.viewDidAppear
            .subscribe(with: self) { owner, _ in
                owner.setMenuBadge(reactor: reactor)
            }
            .disposed(by: disposeBag)
        
        // MARK: - 네비바 bindAction
        customNaviBar.searchChargeButton.rx.tap
            .map { MainReactor.Action.showSearchChargingStation }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        customNaviBar.menuButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .map { MainReactor.Action.toggleLeftMenu }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        customNaviBar.searchWayButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action.hideSearchWay(false))
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)

        customNaviBar.cancelSearchWayButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action.hideSearchWay(true))
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // MARK: - 길찾기 bindAction
        searchWayView.startTextField.rx.controlEvent([.editingChanged])
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action
                    .searchDestination(.startPoint, owner.searchWayView.startTextField.text ?? String()))
                .bind(to: reactor.action)
                .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        searchWayView.startTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.destinationResultTableView.tag = owner.ROUTE_START
            }
            .disposed(by: disposeBag)
        
        searchWayView.startTextClearButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action.clearSearchPoint(.startPoint))
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        searchWayView.endTextField.rx.controlEvent([.editingChanged])
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action
                    .searchDestination(.endPoint, owner.searchWayView.endTextField.text ?? String()))
                .bind(to: reactor.action)
                .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        searchWayView.endTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.destinationResultTableView.tag = owner.ROUTE_END
            }
            .disposed(by: disposeBag)
        
        searchWayView.endTextClearButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action.clearSearchPoint(.endPoint))
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        searchWayView.removeButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action.clearSearchWayData)
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
                RouteEvent.clickNavigationFindway.logEvent()
            }
            .disposed(by: disposeBag)
        
        searchWayView.searchButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.findPath(passList: [])
                owner.hideDestinationResult(reactor: reactor, hide: true)
            }
            .disposed(by: disposeBag)
        
        // bottom guide
        chargePriceButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                Observable.just(MainReactor.Action.showChargePrice)
                    .bind(to: reactor.action)
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - bindState
    private func bindState(reactor: MainReactor) {
        reactor.state.compactMap { $0.hasNewBoardContents }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, hasBadge in
//                let toolbarController = owner.toolbarController as? AppToolbarController
//                toolbarController?.setMenuIcon(hasBadge: hasBadge)
                owner.customNaviBar.setMenuBadge(hasBadge: hasBadge)
            }
            .disposed(by: disposeBag)

        reactor.state.compactMap { $0.isShowBottomEvPayToolTip }
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { obj, isShow in
                obj.bottomEvPaytooltipView?.isHidden = !isShow
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isShowSearchChargingStation }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owenr, isShowSearchView in
                let mapStoryboard = UIStoryboard(name : "Map", bundle: nil)
                guard let searchVC = mapStoryboard
                    .instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
                else { return }
                
                searchVC.delegate = self
                
                let appSearchBarController = AppSearchBarController(rootViewController: searchVC)
                appSearchBarController.backbuttonTappedDelegate = {
                    let property: [String: Any] = ["result": "실패",
                                                   "stationOrAddress": "\(searchVC.searchType.title)",
                                                   "searchKeyword": "\(searchVC.searchBarController?.searchBar.textField.text ?? "")",
                                                   "selectedStation": ""]
                    SearchEvent.clickSearchChooseStation.logEvent(property: property)
                    
                }
                self.present(appSearchBarController, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isHideSearchWay }
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, isHideSearchWay in
                if isHideSearchWay {    // 길찾기화면 숨김 -> 길찾기모드 종료.
                    owner.clusterManager?.isRouteMode = false
                }
                
                owner.customNaviBar.hideSearchWayMode(isHideSearchWay)
                
                RouteEvent.clickNavigation.logEvent(property: ["onOrOff": "\(!isHideSearchWay ? "On" : "Off")"])
                
                UIView.animate(
                    withDuration: 0.2, delay: 0.0,
                    options: UIView.AnimationOptions.curveEaseOut,
                    animations: {() -> Void in
                        owner.searchWayView.isHidden = isHideSearchWay
                    })
                
            }
            .disposed(by: disposeBag)
        

        reactor.state.compactMap { $0.isClearSearchWayPoint }
            .filter { $0.1 == .startPoint }
            .map { _ in return String() }
            .bind(to: searchWayView.startTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isClearSearchWayPoint }
            .filter { $0.1 == .endPoint }
            .map { _ in return String() }
            .bind(to: searchWayView.endTextField.rx.text)
            .disposed(by: disposeBag)
                
        reactor.state.compactMap { $0.isHideDestinationResult }
            .filter { $0 == true }
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, isHideDestination in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn) {
                    self.destinationResultTableView.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isHideDestinationResult }
            .filter { $0 == false }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, isHideDestination in
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
                    owner.destinationResultTableView.isHidden = false
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.searchDetinationData }
            .compactMap { self.tMapPathData.requestFindAllPOI($0.1) as? [TMapPOIItem] }
            .asDriver(onErrorJustReturn: [])
            .drive(with: self) { owner, poiList in
                owner.destinationResultTableView.setPOI(list: poiList)
                owner.destinationResultTableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isClearSearchWayData }
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, _ in
                // 기존 clearResult
                owner.hideKeyboard()
                    
                owner.setView(view: owner.routeDistanceView, hidden: true)
                
                owner.chargePriceContentView.isHidden = false
                owner.bottomMenuView.isHidden = false
                
                owner.searchWayView.startTextField.text = String()
                owner.searchWayView.endTextField.text = String()
                
                owner.routeStartPoint = nil
                owner.routeEndPoint = nil
                        
                owner.naverMapView.startMarker?.mapView = nil
                owner.naverMapView.midMarker?.mapView = nil
                owner.naverMapView.endMarker?.mapView = nil
                owner.naverMapView.startMarker = nil
                owner.naverMapView.midMarker = nil
                owner.naverMapView.endMarker = nil
                owner.naverMapView.start = nil
                owner.naverMapView.destination = nil
                owner.naverMapView.viaList = []
                owner.naverMapView.path?.mapView = nil
                
                // 경로 주변 충전소 초기화
                for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
                    charger.isAroundPath = true
                }
                
                owner.updateClustering()

                self.clusterManager?.isRouteMode = false
                owner.summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isShowQRMenu }
            .asDriver(onErrorJustReturn: true)
            .drive(with: self) { owner, isShow in
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                switch status {
                case .notDetermined, .denied:
                    AVCaptureDevice.requestAccess(for: .video) { [weak self] grated in
                        if grated {
                            self?.movePaymentQRScan()
                        } else {
                            self?.showAuthAlert()
                        }
                    }
                case .authorized:
                    self.movePaymentQRScan()
                    
                default: break
                }
                
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.evPayPresentType }
            .asDriver(onErrorJustReturn: .evPayManagement)
            .drive(with: self) { owner, showType in
                switch showType {
                case .evPayGuide:
                    let viewcon = MembershipGuideViewController()
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    
                case .evPayManagement:
                    let reactor = MembershipCardReactor(provider: RestApi())
                    let viewcon = MembershipCardViewController(reactor: reactor)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                }
            }
            .disposed(by: disposeBag)

        reactor.state.compactMap { $0.bottomItemType }
            .asDriver(onErrorJustReturn: .community)
            .drive(with: self) { owner, bottomType in
                switch bottomType {
                case .community:
                    UserDefault().saveInt(key: UserDefault.Key.LAST_FREE_ID, value: Board.sharedInstance.freeBoardId)
                    
                    let viewcon = CardBoardViewController(category: .FREE, mode: .FEED)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    
                case .favorite:
                    let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: FavoriteViewController.self)
                    viewcon.delegate = self
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon, subtype: CATransitionSubtype.fromTop)
                    
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.isShowChargePrice }
            .asDriver(onErrorJustReturn: true)
            .drive { _ in
                let viewcon = UIStoryboard(name : "Info", bundle: nil).instantiateViewController(ofType: TermsViewController.self)
                viewcon.tabIndex = .priceInfo
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: FUNC
    
    private func setChargingStatus(reactor: MainReactor) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                Observable.just(MainReactor.Action.setChargingID)
                    .bind(to: reactor.action)
                    .disposed(by: self.disposeBag)
            }
        }
    }
    
    private func setMenuBadge(reactor: MainReactor) {
        let hasBadge = Board.sharedInstance.hasNew() || defaults.readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT)
        Observable.just(MainReactor.Action.setMenuBadge(hasBadge))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func hideDestinationResult(reactor: MainReactor, hide: Bool) {
        Observable.just(MainReactor.Action.hideDestinationResult(hide))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func askPermission() {
        let alertController = UIAlertController(title: "위치정보가 활성화되지 않았습니다", message: "EV Infra의 원활한 서비스를 이용하시려면 [설정] > [개인정보보호]에서 위치 서비스를 켜주세요.", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "설정", style: UIAlertAction.Style.default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    internal func sceneDidBecomeActiveCall() {
        guard let _reactor = self.reactor else { return }
        guard _reactor.currentState.isShowStartBanner == nil else { return }

        switch self.locationManager.authorizationStatus {
        case .denied, .restricted, .notDetermined:
            Observable.just(MainReactor.Action.showMarketingPopup)
                .bind(to: _reactor.action)
                .disposed(by: self.disposeBag)

        case .authorizedWhenInUse, .authorizedAlways: break

        @unknown default:
            fatalError()
        }
    }
    
    private func prepareRouteView() {
        let findPath = UITapGestureRecognizer(target: self, action:  #selector (self.onClickShowNavi(_:)))
        self.routeDistanceBtn.addGestureRecognizer(findPath)
    }
    
    private func prepareTmapAPI() {
        tMapView = TMapView()
        tMapView?.setSKTMapApiKey(Const.TMAP_APP_KEY)
    }
    
    func setStartPoint() {
        guard let selectCharger = selectCharger else { return }
        
        if let reactor = reactor {
            Observable.just(MainReactor.Action.hideSearchWay(false))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        searchWayView.startTextField.text = selectCharger.mStationInfoDto?.mSnm
        routeStartPoint = selectCharger.getTMapPoint()
        naverMapView.start = POIObject(name: selectCharger.mStationInfoDto?.mSnm ?? "",
                                             lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                                             lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero)
        naverMapView.startMarker = Marker(NMGLatLng(lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                                                    lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero), .start)
        naverMapView.startMarker?.mapView = self.mapView
        
        self.setStartPath()
    }
    
    func setEndPoint() {
        guard let selectCharger = selectCharger else { return }

        if let reactor = reactor {
            Observable.just(MainReactor.Action.hideSearchWay(false))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
            
        searchWayView.endTextField.text = selectCharger.mStationInfoDto?.mSnm
        routeEndPoint = selectCharger.getTMapPoint()
        naverMapView.destination = POIObject(name: selectCharger.mStationInfoDto?.mSnm ?? "",
                                             lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                                             lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero)
        naverMapView.endMarker = Marker(NMGLatLng(lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                                                    lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero), .end)
        naverMapView.endMarker?.mapView = self.mapView
        
        self.setStartPath()
    }
    
    func setStartPath() {
        let passList = naverMapView
            .viaList
            .map {
                TMapPoint(lon: $0.lng, lat: $0.lat)!
            }
        
        if !passList.isEmpty {
            let via = naverMapView.viaList.first ?? POIObject(name: "", lat: .zero, lng: .zero)
            self.naverMapView.midMarker?.mapView = nil
            self.naverMapView.midMarker = Marker(NMGLatLng(lat: via.lat,
                                                           lng: via.lng), .mid)
            self.naverMapView.midMarker?.mapView = self.mapView
        }
        
        findPath(passList: passList)
        
        if let reactor = reactor {
            hideDestinationResult(reactor: reactor, hide: true)
        }
    }
    
    private func showNavigation(start: POIObject?, destination: POIObject, via: [POIObject]) {
        if let _start = start {
            UtilNavigation().showNavigation(vc: self, startPoint: _start, endPoint: destination, viaList: via)
        } else {
            let currentPoint = locationManager.getCurrentCoordinate()
            let point = TMapPoint(coordinate: currentPoint)

            let positionName = tMapPathData.convertGpsToAddress(at: point) ?? ""
            let start = POIObject(name: positionName, lat: currentPoint.latitude, lng: currentPoint.longitude)
            
            UtilNavigation().showNavigation(vc: self, startPoint: start, endPoint: destination, viaList: via)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissBottomMenuTooltip()
    }
    
    private func dismissBottomMenuTooltip() {
        guard !MemberManager.shared.isShowBottomMenuEVPayTooltip else { return }
        
        MemberManager.shared.isShowBottomMenuEVPayTooltip = true
        self.bottomEvPaytooltipView?.dismiss()
    }
    
    // MARK: - Action for button
    
    @IBAction func onClickMyLocation(_ sender: UIButton) {
        self.locationManager.rx.isEnabled
            .subscribe(with: self) { obj, isEnable in
                if !isEnable {
                    obj.askPermission()
                } else {
                    obj.locationManager.rx
                        .status
                        .subscribe(with: obj) { obj, status in
                            switch status {
                            case .authorizedWhenInUse:
                                switch obj.mapView.positionMode {
                                case .normal:
                                    obj.mapView.positionMode = .direction
                                case .direction:
                                    obj.mapView.positionMode = .compass
                                case .compass:
                                    obj.mapView.positionMode = .direction
                                default:
                                    obj.mapView.positionMode = .direction
                                }
                                
                                self.updateMyLocationButton()
                                
                            case .denied, .notDetermined, .restricted:
                                let popupModel = PopupModel(title: "위치권한을 허용해주세요",
                                                            message: "위치 권한을 허용해주시면, 사용자님 근처의 충전소 정보를 알려드릴게요.",
                                                            confirmBtnTitle: "권한 변경하기",
                                                            confirmBtnAction: {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        if UIApplication.shared.canOpenURL(url) {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        }
                                    }
                                }, textAlignment: .center, dimmedBtnAction: nil)

                                let popup = ConfirmPopupViewController(model: popupModel)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                                })
                                
                            default: break
                            }
                        }
                        .disposed(by: obj.disposeBag)
                    MapEvent.clickMyLocation.logEvent()
                }
            }
            .disposed(by: self.disposeBag)

    }
    
    @IBAction func onClickRenewBtn(_ sender: UIButton) {
        if !self.markerIndicator.isAnimating {
            self.refreshChargerInfo()
        }
        MapEvent.clickRenew.logEvent()
    }
    
    // 파란색 길안내 버튼 누를때
    @objc func onClickShowNavi(_ sender: Any) {
        guard let destination = naverMapView.destination else { return }
        
        showNavigation(start: naverMapView.start, destination: destination, via: naverMapView.viaList)
        RouteEvent.clickNavigationFindway.logEvent()
    }
    
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways:
            guard let _reactor = self.reactor else { return }
            Observable.just(MainReactor.Action.showMarketingPopup)
                .bind(to: _reactor.action)
                .disposed(by: self.disposeBag)
            
        case .notDetermined, .authorizedWhenInUse, .denied, .restricted: break
        @unknown default:
            fatalError()
        }
    }
}

extension MainViewController: DelegateChargerFilterView {
    func onApplyFilter() {
        guard let _reactor = self.reactor else { return }
        Observable.just(MainReactor.Action.updateFilterBarTitle)
            .bind(to: _reactor.action)
            .disposed(by: self.disposeBag)
        
        filterContainerView.updateFilters()
        // refresh marker
        clusterManager?.removeClusterFromSettings()
        drawMapMarker()
    }
}

extension MainViewController: DelegateFilterContainerView {
    func changedFilter(type: FilterType) {        
        // refresh marker
        
        guard let _reactor = self.reactor else { return }
        Observable.just(MainReactor.Action.updateFilterBarTitle)
            .bind(to: _reactor.action)
            .disposed(by: self.disposeBag)
        
        drawMapMarker()
    }
}

extension MainViewController: NMFMapViewCameraDelegate {
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        // 카메라가 움직임이 끝났을때 콜백
        drawMapMarker()
        
        if !canIgnoreJejuPush {
            checkJeJuBoundary()
        }
    }
}

extension MainViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        guard let _reactor = self.reactor else { return }
        
        Observable.just(MainReactor.Action.setSelectedFilterInfo(MainReactor.SelectedFilterInfo(filterTagType: .price, isSeleted: false)))
            .bind(to: _reactor.action)
            .disposed(by: self.disposeBag)
        
        hideKeyboard()
        myLocationModeOff()
        setView(view: callOutLayer, hidden: true)
        
        if let searchedLocationMarker = naverMapView.searchMarker {
            searchedLocationMarker.mapView = nil
        }
        
        guard selectCharger == nil else {
            selectCharger?.mapMarker.mapView = nil

            let iconImage = NMFOverlayImage(image: selectCharger!.getMarkerIcon())

            selectCharger?.mapMarker.iconImage = iconImage
            selectCharger?.mapMarker.mapView = self.mapView
            
            selectCharger = nil
            return
        }
    }
}

extension MainViewController {
    private func drawMapMarker() {
        guard chargerManager.isReady() else { return }
        
        self.clusterManager?.clustering(filter: FilterManager.sharedInstance.filter, loadedCharger: self.loadedChargers)
        
        if !self.loadedChargers {
            self.loadedChargers = true
            if self.sharedChargerId != nil {
                self.selectChargerFromShared()
            }
        }
    }
}

extension MainViewController {

    func findPath(passList: [TMapPoint]) {
        // 경로찾기: 시작 위치가 없을때
        if routeStartPoint == nil {
            let currentPoint = locationManager.getCurrentCoordinate()
            let point = TMapPoint(coordinate: currentPoint)

            searchWayView.startTextField.text = tMapPathData.convertGpsToAddress(at: point)
            routeStartPoint = point
        }
        
        if let startPoint = routeStartPoint,
            let endPoint = routeEndPoint {
            markerIndicator.startAnimating()
            
            // 키보드 숨기기
            hideKeyboard()
            
            // 하단 충전소 정보 숨기기
            setView(view: callOutLayer, hidden: true)
            
            self.chargePriceContentView.isHidden = true
            self.bottomMenuView.isHidden = true
            
            let bounds = NMGLatLngBounds(southWestLat: startPoint.getLatitude(),
                                         southWestLng: startPoint.getLongitude(),
                                         northEastLat: endPoint.getLatitude(),
                                         northEastLng: endPoint.getLongitude())
            
            let zoomLevel = NMFCameraUtils.getFittableZoomLevel(with: bounds, insets: UIEdgeInsets(top: 250, left: 10, bottom: 250, right: 10), mapView: self.mapView)
            
            // 출발, 도착의 가운데 지점으로 map 이동
            let centerLat = abs((startPoint.getLatitude() + endPoint.getLatitude()) / 2)
            let centerLon = abs((startPoint.getLongitude() + endPoint.getLongitude()) / 2)
            naverMapView.moveToCamera(with: NMGLatLng(lat: centerLat, lng: centerLon), zoomLevel: zoomLevel)
            
            // 경로 요청
            DispatchQueue.global(qos: .background).async { [weak self] in
                var polyLine: TMapPolyLine? = nil
                if passList.isEmpty {
                    polyLine = self?.tMapPathData.find(from: startPoint, to: endPoint)
                } else {
                    polyLine = self?.tMapPathData.findMultiPathData(withStart: startPoint, end: endPoint, passPoints: passList, searchOption: 0)
                }
                let distance = polyLine?.getDistance() ?? 0.0
                
                let pathOverlay = NMFPath()
                pathOverlay.color = .red
                
                let points = polyLine?.points
                var positions = [NMGLatLng]()
                
                for (_, point) in points!.enumerated() {
                    if let point = point as? TMapPoint {
                        let position = NMGLatLng(lat: point.getLatitude(), lng: point.getLongitude())
                        positions.append(position)
                    }
                }

                positions.insert(NMGLatLng(from: startPoint.coordinate), at: 0)
                positions.insert(NMGLatLng(from: endPoint.coordinate), at: positions.count)
                pathOverlay.path = NMGLineString(points: positions)
                
                DispatchQueue.main.async {
                    // 경로선 초기화
                    self?.naverMapView.path?.mapView = nil
                    self?.naverMapView.path = nil
                    
                    if self?.naverMapView.startMarker == nil {
                        self?.naverMapView.startMarker = Marker(NMGLatLng(lat: startPoint.getLatitude(),
                                                                          lng: startPoint.getLongitude()), .start)
                        self?.naverMapView.startMarker?.mapView = self?.mapView
                    }

                    if self?.naverMapView.endMarker == nil {
                        self?.naverMapView.endMarker = Marker(NMGLatLng(lat: endPoint.getLatitude(),
                                                                        lng: endPoint.getLongitude()), .end)
                        self?.naverMapView.endMarker?.mapView = self?.mapView
                    }
                    
                    // 경로선 그리기
                    self?.naverMapView.path = pathOverlay
                    self?.naverMapView.path?.mapView = self?.mapView
                    
                    self?.drawPathData(polyLine: pathOverlay.path, distance: distance)
                    self?.markerIndicator.stopAnimating()
                }
            }
        }
    }
    
    func drawPathData(polyLine: NMGLineString<AnyObject>, distance: Double) {
        findChargerAroundRoute(polyLine: polyLine)
        self.clusterManager?.isRouteMode = true
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
        
        drawMapMarker()
        
        var strDistance: NSString = ""
        if distance > 1000 {
            strDistance = NSString(format: "%dKm", Int(distance/1000))
        } else {
            strDistance = NSString(format: "%dm", Int(distance))
        }
        routeDistanceLabel.text = strDistance as String
        
        setView(view: routeDistanceView, hidden: false)
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
        // TODO: 경유지 포함 된 거리
    }
    
    func findChargerAroundRoute(polyLine: NMGLineString<AnyObject>) {
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
            charger.isAroundPath = false
        }
        
        let points = polyLine.points
        
        for i in stride(from: 0, to: points.count, by: 100) {
            guard let point = points[i] as? NMGLatLng else { return }
            
            for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
                if !charger.isAroundPath && charger.check(filter: FilterManager.sharedInstance.filter) {
                    let chargerPoint = charger.getChargerPoint()
                    let latLng = NMGLatLng(lat: chargerPoint.0, lng: chargerPoint.1)
                    
                    let distance = point.distance(to: latLng)
                    if distance < 5000.0 {
                        charger.isAroundPath = true
                        charger.mapMarker.mapView = self.mapView
                    }
                }
            }
        }
    }
    
    func hideKeyboard() {
        searchWayView.startTextField.endEditing(true)
        searchWayView.endTextField.endEditing(true)
    }

}

extension MainViewController: PoiTableViewDelegate {

    func didSelectRow(poiItem: TMapPOIItem) {
        // 선택한 주소로 지도 이동
        let latitude = poiItem.coordinate.latitude
        let longitude = poiItem.coordinate.longitude
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15)
        self.mapView.moveCamera(cameraUpdate)
        
        if let reactor = reactor {
            hideDestinationResult(reactor: reactor, hide: true)
        }
        
        // 출발지, 도착지 설정
        if destinationResultTableView.tag == ROUTE_START {
            searchWayView.startTextField.text = poiItem.name
            routeStartPoint = poiItem.getPOIPoint()
            
            naverMapView.startMarker?.mapView = nil
            naverMapView.startMarker = Marker(NMGLatLng(lat: latitude, lng: longitude), .start)
            naverMapView.startMarker?.mapView = self.mapView
            naverMapView.start = POIObject(name: poiItem.name, lat: latitude, lng: longitude)
        } else {
            searchWayView.endTextField.text = poiItem.name
            routeEndPoint = poiItem.getPOIPoint()
            
            naverMapView.endMarker?.mapView = nil
            naverMapView.endMarker = Marker(NMGLatLng(lat: latitude, lng: longitude), .end)
            naverMapView.endMarker?.mapView = self.mapView
            naverMapView.destination = POIObject(name: poiItem.name, lat: latitude, lng: longitude)
        }
    }
}

extension MainViewController: MarkerTouchDelegate {
    func touchHandler(with charger: ChargerStationInfo) {
        hideKeyboard()
        selectCharger(chargerId: charger.mStationInfoDto?.mChargerId ?? "")
        
        let ampChargerStationModel = AmpChargerStationModel(charger)
        var property: [String: Any] = ampChargerStationModel.toProperty
        property["source"] = "마커"
        MapEvent.viewStationSummarized.logEvent(property: property)
    }
}

extension MainViewController: ChargerSelectDelegate {
    func moveToSelectLocation(lat: Double, lon: Double) {
        MapEvent.viewMainPage.logEvent()
        guard lat == 0, lon == 0 else {
            myLocationModeOff()
            
            // 기존에 선택된 마커 지우기
            naverMapView.searchMarker?.mapView = nil
            
            // 카메라 이동
            naverMapView.moveToCamera(with: NMGLatLng(lat: lat, lng: lon), zoomLevel: 15)
            
            // 검색한 위치의 마커 찍기
            naverMapView.searchMarker = Marker(NMGLatLng(lat: lat, lng: lon), .search)
            naverMapView.searchMarker?.mapView = self.mapView
            
            return
        }
    }
    
    func moveToSelected(chargerId: String) {
        MapEvent.viewMainPage.logEvent()
        guard let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) else { return }
        let position = NMGLatLng(lat: charger.mStationInfoDto?.mLatitude ?? 0.0,
                                 lng: charger.mStationInfoDto?.mLongitude ?? 0.0)
        let ampChargerStaionModel = AmpChargerStationModel(charger)
        var property: [String: Any] = ampChargerStaionModel.toProperty
        property["source"] = "검색"
        MapEvent.viewStationSummarized.logEvent(property: property)
        
        // 기존에 선택된 마커 지우기
        naverMapView.searchMarker?.mapView = nil
        
        // 카메라 이동
        naverMapView.moveToCamera(with: position, zoomLevel: 15)
        
        // 검색한 위치의 마커 찍기
        naverMapView.searchMarker = Marker(position, .search)
        naverMapView.searchMarker?.mapView = self.mapView
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.selectCharger(chargerId: chargerId)
            }
        }
    }
    
    func prepareCalloutLayer() {
        callOutLayer.isHidden = true
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickCalloutLayer (_:)))
        self.callOutLayer.addGestureRecognizer(gesture)
    }
    
    @objc func onClickCalloutLayer(_ sender:UITapGestureRecognizer) {
        let detailStoryboard = UIStoryboard(name : "Detail", bundle: nil)
        let detailViewController = detailStoryboard.instantiateViewController(ofType: DetailViewController.self)
        detailViewController.charger = self.selectCharger
        detailViewController.isRouteMode = self.clusterManager?.isRouteMode ?? false
        
        GlobalDefine.shared.mainNavi?.push(viewController: detailViewController, subtype: CATransitionSubtype.fromTop)
    }
    
    func prepareSummaryView() {
        if let window = UIWindow.key {
            callOutLayer.frame.size.width = window.frame.width
            if summaryView == nil {
                summaryView = SummaryView(frame: callOutLayer.frame.bounds)
            }
            summaryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            callOutLayer.addSubview(summaryView)
            //        summaryView.delegate = self
        }
    }
    
    func selectCharger(chargerId: String) {
        myLocationModeOff()
        
        // 이전에 선택된 충전소 마커를 원래 마커로 원복
        if selectCharger != nil {
            selectCharger?.mapMarker.mapView = nil
            summaryView.layoutIfNeeded()
            callOutLayer.layoutIfNeeded()
            
            let iconImage = NMFOverlayImage(image: selectCharger!.getMarkerIcon())

            selectCharger?.mapMarker.iconImage = iconImage
            selectCharger?.mapMarker.mapView = self.naverMapView.mapView

            selectCharger = nil
        }
        
        // 선택한 충전소 정보 표시
        if let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) {
            // 선택한 마커의 위치 값으로 selectIcon 생성
            let iconImage = NMFOverlayImage(image: charger.getSelectIcon())

            charger.mapMarker.iconImage = iconImage
            charger.mapMarker.mapView = self.naverMapView.mapView
            selectCharger = charger
            showCallOut(charger: charger)
        } else {
            // chargerId : search
            print("Not Found Charger \(ChargerManager.sharedInstance.getChargerStationInfoList().count)")
        }
    }
    
    func showCallOut(charger: ChargerStationInfo) {
        summaryView.charger = charger
        summaryView.setLayoutType(charger: charger, type: SummaryView.SummaryType.MainSummary)
        setView(view: callOutLayer, hidden: false)

        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
}

// MARK: - Request To Server
extension MainViewController {
    func requestStationInfo() {
        
        DispatchQueue.main.async { [weak self] in
            self?.markerIndicator.startAnimating()
            self?.customNaviBar.isUserInteractionEnabled = false
        }
        
        ChargerManager.sharedInstance.getStations { [weak self] in
            LoginHelper.shared.checkLogin()
            
            FCMManager.sharedInstance.isReady = true
            DeepLinkPath.sharedInstance.isReady = true
            
            self?.drawMapMarker()
            
            DispatchQueue.main.async { [weak self] in
                self?.markerIndicator.stopAnimating()
                self?.customNaviBar.isUserInteractionEnabled = true
                
                if let chargerId = GlobalDefine.shared.sharedChargerIdFromDynamicLink {
                    self?.sharedChargerId = chargerId
                    self?.selectChargerFromShared()
                    GlobalDefine.shared.sharedChargerIdFromDynamicLink = nil
                }
            }
            
            self?.checkFCM()
            
            if Const.CLOSED_BETA_TEST {
                CBT.checkCBT(vc: self!)
            }
            
            DeepLinkPath.sharedInstance.runDeepLink()
            self?.markerIndicator.stopAnimating()
        }
    }
    
    private func refreshChargerInfo() {
        self.markerIndicator.startAnimating()
        clusterManager?.removeClusterFromSettings()
        Server.getStationStatus { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let list = json["list"]

                for (_, item):(String, JSON) in list {
                    let id = item["id"].stringValue
                    if let charger = self.chargerManager.getChargerStationInfoById(charger_id: id) {
                        charger.changeStatus(status: item["st"].intValue, markerChange: true)
                        charger.mapMarker.touchHandler = { [weak self] overlay -> Bool in
                            self?.touchHandler(with: charger)
                            return true
                        }
                    }
                }
                self.drawMapMarker()
            }
            self.markerIndicator.stopAnimating()
        }
    }
    
    private func checkJeJuBoundary() {
        if naverMapView.isInJeju() {
            canIgnoreJejuPush = true
            let window = UIWindow.key!
            window.addSubview(PopUpDialog(frame: window.bounds))
        }
    }
}

extension MainViewController {
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(saveLastZoomLevel), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(updateMemberInfo), name: Notification.Name("updateMemberInfo"), object: nil)
        center.addObserver(self, selector: #selector(getSharedChargerId(_:)), name: Notification.Name("kakaoScheme"), object: nil)
        center.addObserver(self, selector: #selector(showSelectCharger), name: Notification.Name("showSelectCharger"), object: nil)
        // [Summary observer]
        center.addObserver(self, selector: #selector(directionStartPoint(_:)), name: Notification.Name(summaryView.startKey), object: nil)
        center.addObserver(self, selector: #selector(directionStartPath(_:)), name: Notification.Name(summaryView.addKey), object: nil)
        center.addObserver(self, selector: #selector(directionEnd(_:)), name: Notification.Name(summaryView.endKey), object: nil)
        center.addObserver(self, selector: #selector(directionNavigation(_:)), name: Notification.Name(summaryView.navigationKey), object: nil)
        center.addObserver(self, selector: #selector(requestLogIn(_:)), name: Notification.Name(summaryView.loginKey), object: nil)
        center.addObserver(self, selector: #selector(isChangeFavorite(_:)), name: Notification.Name(summaryView.favoriteKey), object: nil)
    }
    
    func removeObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.removeObserver(self, name: Notification.Name("updateMemberInfo"), object: nil)
        center.removeObserver(self, name: Notification.Name("kakaoScheme"), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.startKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.endKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.addKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.navigationKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.loginKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.favoriteKey), object: nil)
    }
    
    @objc func showSelectCharger(_ notification: NSNotification) {
        guard let chargerId = notification.object as? String else { return }
        guard let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) else { return }

        selectCharger(chargerId: chargerId)
        naverMapView.moveToCamera(with: NMGLatLng(from: charger.getTMapPoint().coordinate), zoomLevel: 14)
    }
    
    @objc func saveLastZoomLevel() {
        UserDefault().saveInt(key: UserDefault.Key.MAP_ZOOM_LEVEL, value: Int(mapView.zoomLevel))
    }
    
    @objc func updateMemberInfo() {
        FilterManager.sharedInstance.saveTypeFilterForCarType()
        filterContainerView.updateFilters()
        drawMapMarker()
    }
    
    @objc func getSharedChargerId(_ notification: NSNotification) {
        let sharedid = notification.userInfo?["sharedid"] as! String
        self.sharedChargerId = sharedid
        if self.loadedChargers {
            selectChargerFromShared()
        }
    }
    
    @objc func directionStartPoint(_ notification: NSNotification) {
        guard let selectCharger = notification.object as? ChargerStationInfo else { return }
        
        self.naverMapView.startMarker?.mapView = nil
        self.naverMapView.startMarker = nil
        self.naverMapView.midMarker?.mapView = nil

        self.navigationController?.popToRootViewController(animated: true)
        self.setStartPoint()
    }
    // 경유지 추가
    @objc func directionStartPath(_ notification: NSNotification) {
        guard let selectCharger = notification.object as? ChargerStationInfo else { return }

        let via = POIObject(name: selectCharger.mStationInfoDto?.mSnm ?? "",
                            lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                            lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero)
        
        naverMapView.viaList.removeAll()
        naverMapView.viaList.append(via)

        self.navigationController?.popToRootViewController(animated: true)
        self.setStartPath()
    }
    
    @objc func directionEnd(_ notification: NSNotification) {
        guard let selectCharger = notification.object as? ChargerStationInfo else { return }
        
        self.naverMapView.endMarker?.mapView = nil
        self.naverMapView.endMarker = nil
        self.naverMapView.midMarker?.mapView = nil
        
        self.navigationController?.popToRootViewController(animated: true)
        self.setEndPoint()
    }
    // 초록색 길안내 시작 버튼 누를때
    @objc func directionNavigation(_ notification: NSNotification) {
        guard let selectCharger = notification.object as? ChargerStationInfo else { return }
        let destination = POIObject(name: selectCharger.mStationInfoDto?.mSnm ?? "",
                                    lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                                    lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero)
        
        showNavigation(start: naverMapView.start, destination: destination, via: [])
    }
    
    @objc func requestLogIn(_ notification: NSNotification) {
        MemberManager.shared.showLoginAlert()
    }
    
    @objc func isChangeFavorite(_ notification: NSNotification) {
        let changed = (notification.object as! Bool)
        summaryView.setCallOutFavoriteIcon(favorite: changed)
    }
    
    internal func selectChargerFromShared() {
        if let id = self.sharedChargerId {
            self.selectCharger(chargerId: id)
            self.sharedChargerId = nil
            if let sharedCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id) {
                let position = NMGLatLng(lat: sharedCharger.mStationInfoDto?.mLatitude ?? 0.0, lng: sharedCharger.mStationInfoDto?.mLongitude ?? 0.0)
                naverMapView.moveToCamera(with: position, zoomLevel: 14)
            }
        }
    }
                
    private func myLocationModeOff() {
        mapView.positionMode = .normal
        myLocationButton.setImage(Icons.iconCurrentLocationMd.image, for: .normal)
        myLocationButton.tintColor = UIColor.init(named: "content-primary")
    }
    
    private func updateMyLocationButton() {
        self.markerIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async { [weak self] in
            DispatchQueue.main.async {
                switch self?.mapView.positionMode  {
                case .normal, .direction:
                    self?.myLocationButton.setImage(Icons.iconCurrentLocationMd.image, for: .normal)
                    self?.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                    UIApplication.shared.isIdleTimerDisabled = false // 화면 켜짐 유지 끔
                case .compass:
                    self?.myLocationButton.setImage(Icons.iconCurrentLocationMd.image, for: .normal)
                    self?.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                    UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
                default:
                    break
                }
                self?.markerIndicator.stopAnimating()
            }
        }
    }

    private func checkFCM() {
        if let notification = FCMManager.sharedInstance.fcmNotification {
            FCMManager.sharedInstance.alertMessage(data: notification)
        }
    }
    
    private func prepareClustering() {
        clusterManager = ClusterManager(mapView: mapView)
        clusterManager?.isClustering = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
    }
    
    private func updateClustering() {
        guard let clusterManager = clusterManager else { return }
        clusterManager.removeClusterFromSettings()
        clusterManager.isClustering = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
        drawMapMarker()
    }
}

extension MainViewController {

    private func movePaymentQRScan() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let reactor = PaymentQRScanReactor(provider: RestApi())
            let viewcon = NewPaymentQRScanViewController(reactor: reactor)
            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
        }
    }
    
    private func showAuthAlert() {
        let popupModel = PopupModel(title: "카메라 권한이 필요해요",
                                    message: "QR 스캔을 위해 권한 허용이 필요해요.\n[설정] > [권한]에서 권한을 허용할 수 있어요.",
                                    confirmBtnTitle: "설정하기", cancelBtnTitle: "닫기",
                                    confirmBtnAction: {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }, textAlignment: .center, dimmedBtnAction: {})
        
        let popup = ConfirmPopupViewController(model: popupModel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
        })
    }
 
}

extension MainViewController: RepaymentListDelegate {
    func onRepaySuccess() {
        let reactor = PaymentQRScanReactor(provider: RestApi())
        let viewcon = NewPaymentQRScanViewController(reactor: reactor)
        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    }
    
    func onRepayFail() {
    }
}

extension MainViewController: LoginHelperDelegate {
    var loginViewController: UIViewController {
        return self
    }
    
    func successLogin() {
        if let reactor = reactor {
            self.setChargingStatus(reactor: reactor)
        }
    }
    
    func successLogout() {
        if let reactor = reactor {
            setMenuBadge(reactor: reactor)
            
            Observable.just(MainReactor.Action.setIsCharging(false))
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
    
    func needSignUp(user: Login) {
    }
}


