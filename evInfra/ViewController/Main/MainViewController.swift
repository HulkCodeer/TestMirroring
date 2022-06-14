//
//  ViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import DropDown
import Material
import M13Checkbox
import SwiftyJSON
import NMapsMap
import SnapKit

internal final class MainViewController: UIViewController {
    
    // constant
    let ROUTE_START = 0
    let ROUTE_END   = 1
    
    // user Default
    let defaults = UserDefault()
    
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var reNewButton: UIButton!
    @IBOutlet weak var btnChargePrice: UIButton!
    
    // Indicator View
    @IBOutlet weak var markerIndicator: UIActivityIndicatorView!
    
    // Filter View
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var routeView: UIView!
    
    @IBOutlet weak var filterBarView: FilterBarView!
    @IBOutlet weak var filterContainerView: FilterContainerView!
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    
    @IBOutlet weak var startField: TextField!
    @IBOutlet weak var endField: TextField!
    
    @IBOutlet weak var btnRouteCancel: UIButton!
    @IBOutlet weak var btnRoute: UIButton!
    
    // Callout View
    @IBOutlet weak var callOutLayer: UIView!
    // Menu Button Layer
    @IBOutlet var btn_menu_layer: UIView!
    @IBOutlet var btn_main_charge: UIButton!
    @IBOutlet var btn_main_community: UIButton!
    @IBOutlet var btn_main_help: UIButton!
    @IBOutlet var btn_main_favorite: UIButton!
    
    //경로찾기시 거리표시 뷰 (call out)
    @IBOutlet weak var routeDistanceView: UIView!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    @IBOutlet var routeDistanceBtn: UIView!
    
    @IBOutlet weak var ivMainChargeNew: UIImageView!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var tMapView: TMapView? = nil
    private var tMapPathData: TMapPathData = TMapPathData.init()
    private var routeStartPoint: TMapPoint? = nil
    private var routeEndPoint: TMapPoint? = nil
    private var resultTableView: PoiTableView?
    
    var naverMapView: NaverMapView!
    var mapView: NMFMapView { naverMapView.mapView }
    private var locationManager = CLLocationManager()
    private var chargerManager = ChargerManager.sharedInstance
    private var selectCharger: ChargerStationInfo? = nil
    private var viaCharger: ChargerStationInfo? = nil
    
    var sharedChargerId: String? = nil
    
    private var loadedChargers = false
    private var clusterManager: ClusterManager? = nil
    private var canIgnoreJejuPush = true
    
    private var summaryView: SummaryView!
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayer()
        configureNaverMapView()
        configureLocationManager()
        showGuide()
        
        prepareRouteField()
        preparePOIResultView()
        prepareFilterView()
        prepareTmapAPI()
        
        prepareSummaryView()
        prepareNotificationCenter()
        prepareRouteView()
        prepareClustering()
        prepareMenuBtnLayer()
        
        prepareChargePrice()
        requestStationInfo()
        
        prepareCalloutLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        chargingStatus()
        menuBadgeAdd()
        updateClustering()
        if self.sharedChargerId != nil {
            self.selectChargerFromShared()
        }
        canIgnoreJejuPush = UserDefault().readBool(key: UserDefault.Key.JEJU_PUSH)// default : false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showDeepLink() {
        DeepLinkPath.sharedInstance.runDeepLink()
    }
    
    // Filter
    private func prepareFilterView() {
        filterBarView.delegate = self
        filterContainerView.delegate = self
    }
    
    private func prepareRouteView() {
        let findPath = UITapGestureRecognizer(target: self, action:  #selector (self.onClickShowNavi(_:)))
        self.routeDistanceBtn.addGestureRecognizer(findPath)
    }
    
    private func configureNaverMapView() {
        naverMapView = NaverMapView(frame: view.frame)
        naverMapView.mapView.addCameraDelegate(delegate: self)
        naverMapView.mapView.touchDelegate = self
        view.insertSubview(naverMapView, at: 0)
        
        ChargerManager.sharedInstance.delegate = self
    }
    
    private func configureLayer() {
        myLocationButton.layer.cornerRadius = 20
        myLocationButton.layer.borderWidth = 1
        myLocationButton.layer.borderColor = UIColor.init(named: "border-opaque")?.cgColor
        updateMyLocationButton()
        
        reNewButton.layer.cornerRadius = 20
        reNewButton.layer.borderWidth = 1
        reNewButton.layer.borderColor = UIColor.init(named: "border-opaque")?.cgColor
        
        btn_menu_layer.layer.cornerRadius = 5
        btn_menu_layer.clipsToBounds = true
        btn_menu_layer.layer.shadowRadius = 5
        btn_menu_layer.layer.shadowColor = UIColor.gray.cgColor
        btn_menu_layer.layer.shadowOpacity = 0.5
        btn_menu_layer.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        btn_menu_layer.layer.masksToBounds = false
    }
    
    private func prepareTmapAPI() {
        tMapView = TMapView()
        tMapView?.setSKTMapApiKey(Const.TMAP_APP_KEY)
    }
    
    // btnChargePrice radius, color, shadow
    private func prepareChargePrice() {
        btnChargePrice.layer.cornerRadius = 16
        btnChargePrice.layer.shadowRadius = 5
        btnChargePrice.layer.shadowColor = UIColor.black.cgColor
        btnChargePrice.layer.shadowOpacity = 0.3
        btnChargePrice.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        btnChargePrice.layer.masksToBounds = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onClickChargePrice))
        btnChargePrice.addGestureRecognizer(gesture)
    }
    
    private func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setStartPoint() {
        guard let selectCharger = selectCharger else { return }
        guard let tc = toolbarController,
              let appTc = tc as? AppToolbarController else { return }

        appTc.enableRouteMode(isRoute: true)
        
        startField.text = selectCharger.mStationInfoDto?.mSnm
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
        guard let tc = toolbarController,
              let appTc = tc as? AppToolbarController else { return }

        appTc.enableRouteMode(isRoute: true)
        
        endField.text = selectCharger.mStationInfoDto?.mSnm
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
    }
    
    private func showNavigation(start: POIObject, destination: POIObject, via: [POIObject]) {
        UtilNavigation().showNavigation(vc: self, startPoint: start, endPoint: destination, viaList: via)
    }
    
    @objc func onClickChargePrice(sender: UITapGestureRecognizer) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let priceInfoViewController: TermsViewController = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
        priceInfoViewController.tabIndex = .PriceInfo
        GlobalDefine.shared.mainNavi?.push(viewController: priceInfoViewController)
    }
    
    // MARK: - Action for button
    @IBAction func onClickMyLocation(_ sender: UIButton) {
        guard isLocationEnabled() else {
            askPermission()
            return
        }
        
        switch mapView.positionMode {
        case .normal:
            mapView.positionMode = .direction
            break
        case .direction:
            mapView.positionMode = .compass
            break
        case .compass:
            mapView.positionMode = .direction
            break
        default: break
        }
        
        updateMyLocationButton()
    }
    
    @IBAction func onClickRenewBtn(_ sender: UIButton) {
        if !self.markerIndicator.isAnimating {
            self.refreshChargerInfo()
        }
    }
    
    // 파란색 길안내 버튼 누를때
    @objc func onClickShowNavi(_ sender: Any) {
        guard let destination = naverMapView.destination else { return }
        
        if let start = naverMapView.start {
            self.showNavigation(start: start, destination: destination, via: naverMapView.viaList)
        } else {
            let currentPoint = locationManager.getCurrentCoordinate()
            let point = TMapPoint(coordinate: currentPoint)
            
            let positionName = tMapPathData.convertGpsToAddress(at: point) ?? ""
            let start = POIObject(name: positionName, lat: currentPoint.latitude, lng: currentPoint.longitude)
            
            self.showNavigation(start: start, destination: destination, via: naverMapView.viaList)
        }
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        var status: CLAuthorizationStatus = .authorizedWhenInUse
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            // Fallback on earlier versions
        }
        
        switch status {
        case .notDetermined, .restricted:
            break
        case .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            self.naverMapView.moveToCurrentPostiion()
            break
        }
    }
}

extension MainViewController: DelegateChargerFilterView {
    func onApplyFilter() {
        filterContainerView.updateFilters()
        filterBarView.updateTitle()
        // refresh marker
        clusterManager?.removeClusterFromSettings()
        drawMapMarker()
    }
}

extension MainViewController: DelegateFilterContainerView {
    func swipeFilterTo(type: FilterType) {
        filterBarView.updateView(newSelect: type)
    }
    
    func changedFilter(type: FilterType) {
        filterBarView.updateTitleByType(type: type)
        // refresh marker
        drawMapMarker()
    }
}

extension MainViewController: DelegateFilterBarView {
    func showFilterContainer(type: FilterType){
        // change or remove containerview
        if (filterContainerView.isSameView(type: type)){
            hideFilter()
        } else {
            showFilter()
            filterContainerView.showFilterView(type: type)
        }
    }
    
    func hideFilter(){
        filterBarView.updateView(newSelect: .none)
        filterContainerView.isHidden = true
        filterHeight.constant = routeView.layer.height + filterBarView.layer.height
        filterView.sizeToFit()
        filterView.layoutIfNeeded()
    }
    
    func showFilter(){
        filterContainerView.isHidden = false
        filterHeight.constant = routeView.layer.height + filterBarView.layer.height + filterContainerView.layer.height
        filterView.sizeToFit()
        filterView.layoutIfNeeded()
    }
    
    func startFilterSetting(){
        // chargerFilterViewcontroller
        let filterStoryboard = UIStoryboard(name : "Filter", bundle: nil)
        let chargerFilterViewController = filterStoryboard.instantiateViewController(ofType: ChargerFilterViewController.self)
        chargerFilterViewController.delegate = self
        GlobalDefine.shared.mainNavi?.push(viewController: chargerFilterViewController)
    }
    
    @IBAction func onClickMainFavorite(_ sender: UIButton) {
        if MemberManager.shared.isLogin {
            let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
            let favoriteViewController = memberStoryboard.instantiateViewController(ofType: FavoriteViewController.self)
            favoriteViewController.delegate = self
            self.present(AppNavigationController(rootViewController: favoriteViewController), animated: true, completion: nil)
        } else {
            MemberManager.shared.showLoginAlert()
        }
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
        clearSearchResult()
        hideFilter()
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

// MARK: - Delegate
extension MainViewController: AppToolbarDelegate {
    func toolBar(didClick iconButton: IconButton, arg: Any?) {
        switch iconButton.tag {
        case 1: // 충전소 검색 버튼
            let mapStoryboard = UIStoryboard(name : "Map", bundle: nil)
            let searchVC:SearchViewController = mapStoryboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            searchVC.delegate = self
            self.present(AppSearchBarController(rootViewController: searchVC), animated: true, completion: nil)
        case 2: // 경로 찾기 버튼
            if let isRouteMode = arg {
                showRouteView(isShow: isRouteMode as! Bool)
            }
            
        default:
            break
        }
    }
    
    func showRouteView(isShow: Bool) {
        if isShow {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.filterView.transform = CGAffineTransform( translationX: 0.0, y: self.routeView.bounds.height )
                self.myLocationButton.transform = CGAffineTransform( translationX: 0.0, y: self.routeView.bounds.height )
                self.reNewButton.transform = CGAffineTransform( translationX: 0.0, y: self.routeView.bounds.height )
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
                self.filterView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                self.myLocationButton.transform = CGAffineTransform( translationX: 0.0, y: 0.0)
                self.reNewButton.transform = CGAffineTransform( translationX: 0.0, y: 0.0)
            }, completion: nil)
            clearSearchResult()
        }
    }
}

extension MainViewController: TextFieldDelegate {
    func prepareRouteField() {
        startField.tag = ROUTE_START
        startField.delegate = self
        if startField.placeholder == nil {
            startField.placeholder = "출발지를 입력하세요"
        }
        startField.placeholderAnimation = .hidden
        startField.isClearIconButtonEnabled = true
        startField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        endField.tag = ROUTE_END
        endField.delegate = self
        endField.placeholder = "도착지를 입력하세요"
        endField.placeholderAnimation = .hidden
        endField.isClearIconButtonEnabled = true
        endField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnRouteCancel.addTarget(self, action: #selector(onClickRouteCancel(_:)), for: .touchUpInside)
        btnRoute.addTarget(self, action: #selector(onClickRoute(_:)), for: .touchUpInside)
        
        routeDistanceView.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchKeyword = textField.text,
                !searchKeyword.isEmpty else {
            hideResultView()
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let poiList = self?.tMapPathData.requestFindAllPOI(searchKeyword) else { return }
            DispatchQueue.main.async {
                self?.showResultView()
                self?.resultTableView?.setPOI(list: poiList as! [TMapPOIItem])
                self?.resultTableView?.reloadData()
            }
        }
    }
    
    @objc func onClickRouteCancel(_ sender: UIButton) {
        clearSearchResult()
    }
    
    @objc func onClickRoute(_ sender: UIButton) {
        findPath(passList: [])
    }
    
    func clearSearchResult() {
        
        hideKeyboard()
        hideResultView()
        
        setView(view: routeDistanceView, hidden: true)
        self.btnChargePrice.isHidden = false
        self.btn_menu_layer.isHidden = false
        
        startField.text = ""
        endField.text = ""
        
        routeStartPoint = nil
        routeEndPoint = nil
        
        btnRouteCancel.setTitle("지우기", for: .normal)
        
        naverMapView.startMarker?.mapView = nil
        naverMapView.midMarker?.mapView = nil
        naverMapView.endMarker?.mapView = nil
        naverMapView.startMarker = nil
        naverMapView.midMarker = nil
        naverMapView.endMarker = nil
        naverMapView.start = nil
        naverMapView.destination = nil
        naverMapView.viaList = []
        naverMapView.path?.mapView = nil
        
        // 경로 주변 충전소 초기화
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
            charger.isAroundPath = true
        }
        
        updateClustering()

        self.clusterManager?.isRouteMode = false
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
    }
    
    func findPath(passList: [TMapPoint]) {
        // 경로찾기: 시작 위치가 없을때
        if routeStartPoint == nil {
            let currentPoint = locationManager.getCurrentCoordinate()
            let point = TMapPoint(coordinate: currentPoint)

            startField.text = tMapPathData.convertGpsToAddress(at: point)
            routeStartPoint = point
        }
        
        if let startPoint = routeStartPoint,
            let endPoint = routeEndPoint {
            markerIndicator.startAnimating()
            
            // 키보드 숨기기
            hideKeyboard()
            
            // 검색 결과창 숨기기
            hideResultView()
            
            // 하단 충전소 정보 숨기기
            setView(view: callOutLayer, hidden: true)
            
            self.btnChargePrice.isHidden = true
            self.btn_menu_layer.isHidden = true
            
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
        startField.endEditing(true)
        endField.endEditing(true)
    }
    
    func hideResultView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {() -> Void in
            self.resultTableView?.isHidden = true
        }, completion: nil)
    }
    
    func showResultView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {() -> Void in
            self.resultTableView?.isHidden = false
        }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // text filed가 선택되었을 때 result view의 종류(start, end) 설정
        resultTableView?.tag = textField.tag
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        hideResultView()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        return true
    }
}

extension MainViewController: PoiTableViewDelegate {
    func preparePOIResultView() {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let frame = CGRect(x: 0, y: filterView.frame.height, width: screenWidth, height: screenHeight - filterView.frame.height)
        
        resultTableView = PoiTableView.init(frame: frame, style: .plain)
        resultTableView?.poiTableDelegate = self
        view.addSubview(resultTableView!)
        resultTableView?.isHidden = true
        hideResultView()
    }
    
    func didSelectRow(poiItem: TMapPOIItem) {
        // 선택한 주소로 지도 이동
        let latitude = poiItem.coordinate.latitude
        let longitude = poiItem.coordinate.longitude
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15)
        self.mapView.moveCamera(cameraUpdate)
        
        hideResultView()
        
        // 출발지, 도착지 설정
        if resultTableView?.tag == ROUTE_START {
            startField.text = poiItem.name
            routeStartPoint = poiItem.getPOIPoint()
            
            naverMapView.startMarker?.mapView = nil
            naverMapView.startMarker = Marker(NMGLatLng(lat: latitude, lng: longitude), .start)
            naverMapView.startMarker?.mapView = self.mapView
            naverMapView.start = POIObject(name: poiItem.name, lat: latitude, lng: longitude)
        } else {
            endField.text = poiItem.name
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
    }
}

extension MainViewController: ChargerSelectDelegate {
    func moveToSelectLocation(lat: Double, lon: Double) {
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
        guard let charger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: chargerId) else { return }
        let position = NMGLatLng(lat: charger.mStationInfoDto?.mLatitude ?? 0.0,
                                 lng: charger.mStationInfoDto?.mLongitude ?? 0.0)
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
        addCalloutClickListener()
    }
    
    func addCalloutClickListener() {
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickCalloutLayer (_:)))
        self.callOutLayer.addGestureRecognizer(gesture)
    }
    
    @objc func onClickCalloutLayer(_ sender:UITapGestureRecognizer) {
        let detailStoryboard = UIStoryboard(name : "Detail", bundle: nil)
        let detailViewController = detailStoryboard.instantiateViewController(ofType: DetailViewController.self)
        detailViewController.charger = self.selectCharger
        detailViewController.isRouteMode = self.clusterManager?.isRouteMode ?? false
        
        GlobalDefine.shared.mainNavi?.push(viewController: detailViewController, subtype: kCATransitionFromTop)
    }
    
    func prepareSummaryView() {
        if let window = UIApplication.shared.keyWindow {
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
        LoginHelper.shared.delegate = self
        
        DispatchQueue.main.async {
            self.markerIndicator.startAnimating()
            self.appDelegate.appToolbarController.toolbar.isUserInteractionEnabled = false
        }
        ChargerManager.sharedInstance.getStations { [weak self] in
            LoginHelper.shared.checkLogin()
            
            FCMManager.sharedInstance.isReady = true
            DeepLinkPath.sharedInstance.isReady = true
            self?.drawMapMarker()
            
            DispatchQueue.main.async {
                self?.markerIndicator.stopAnimating()
                self?.appDelegate.appToolbarController.toolbar.isUserInteractionEnabled = true
            }
            self?.showStartAd()
            self?.checkFCM()
            
            if Const.CLOSED_BETA_TEST {
                CBT.checkCBT(vc: self!)
            }
            
            self?.showDeepLink()
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
            let window = UIApplication.shared.keyWindow!
            window.addSubview(PopUpDialog(frame: window.bounds))
        }
    }
}

extension MainViewController {
    func prepareNotificationCenter() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(saveLastZoomLevel), name: .UIApplicationDidEnterBackground, object: nil)
        center.addObserver(self, selector: #selector(updateMemberInfo), name: Notification.Name("updateMemberInfo"), object: nil)
        center.addObserver(self, selector: #selector(getSharedChargerId(_:)), name: Notification.Name("kakaoScheme"), object: nil)
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
        center.removeObserver(self, name: Notification.Name("updateMemberInfo"), object: nil)
    }
    
    func removeSummaryObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(summaryView.startKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.endKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.addKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.navigationKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.loginKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.favoriteKey), object: nil)
    }
    
    @objc func saveLastZoomLevel() {
        UserDefault().saveInt(key: UserDefault.Key.MAP_ZOOM_LEVEL, value: Int(mapView.zoomLevel))
    }
    
    @objc func updateMemberInfo() {
        FilterManager.sharedInstance.saveTypeFilterForCarType()
        filterContainerView.updateFilters()
        filterBarView.updateTitle()
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
        
        if navigationDrawerController?.isOpened == true {
            navigationDrawerController?.toggleLeftView()
        }
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
        
        if navigationDrawerController?.isOpened == true {
            navigationDrawerController?.toggleLeftView()
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.setStartPath()
    }
    
    @objc func directionEnd(_ notification: NSNotification) {
        guard let selectCharger = notification.object as? ChargerStationInfo else { return }
        
        self.naverMapView.endMarker?.mapView = nil
        self.naverMapView.endMarker = nil
        self.naverMapView.midMarker?.mapView = nil
        
        if navigationDrawerController?.isOpened == true {
            navigationDrawerController?.toggleLeftView()
        }
        self.navigationController?.popToRootViewController(animated: true)
        self.setEndPoint()
    }
    // 초록색 길안내 시작 버튼 누를때
    @objc func directionNavigation(_ notification: NSNotification) {
        guard let selectCharger = notification.object as? ChargerStationInfo else { return }
        let destination = POIObject(name: selectCharger.mStationInfoDto?.mSnm ?? "",
                                    lat: selectCharger.mStationInfoDto?.mLatitude ?? .zero,
                                    lng: selectCharger.mStationInfoDto?.mLongitude ?? .zero)
        
        guard let start = naverMapView.start  else {
            let currentPoint = locationManager.getCurrentCoordinate()
            let point = TMapPoint(coordinate: currentPoint)
            
            let positionName = tMapPathData.convertGpsToAddress(at: point) ?? ""
            let start = POIObject(name: positionName, lat: currentPoint.latitude, lng: currentPoint.longitude)
            
            self.showNavigation(start: start, destination: destination, via: [])
            return
        }
        
        self.showNavigation(start: start, destination: destination, via: [])
    }
    
    @objc func requestLogIn(_ notification: NSNotification) {
        MemberManager.shared.showLoginAlert()
    }
    
    @objc func isChangeFavorite(_ notification: NSNotification) {
        let changed = (notification.object as! Bool)
        summaryView.setCallOutFavoriteIcon(favorite: changed)
    }
    
    private func selectChargerFromShared() {
        if let id = self.sharedChargerId {
            self.selectCharger(chargerId: id)
            self.sharedChargerId = nil
            if let sharedCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id) {
                let position = NMGLatLng(lat: sharedCharger.mStationInfoDto?.mLatitude ?? 0.0, lng: sharedCharger.mStationInfoDto?.mLongitude ?? 0.0)
                naverMapView.moveToCamera(with: position, zoomLevel: 14)
            }
        }
    }
    
    private func isLocationEnabled() -> Bool {
        var enabled: Bool = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                enabled = true
                break
            case .notDetermined, .restricted, .denied:
                break
            }
        }
        return enabled
    }
    
    private func askPermission(){
        let alertController = UIAlertController(title: "위치정보가 활성화되지 않았습니다", message: "EV Infra의 원활한 기능을 이용하시려면 모든 권한을 허용해 주십시오.\n[설정] > [EV Infra] 에서 권한을 허용할 수 있습니다.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func myLocationModeOff() {
        mapView.positionMode = .normal
        myLocationButton.setImage(UIImage(named: "icon_current_location_lg"), for: .normal)
        myLocationButton.tintColor = UIColor.init(named: "content-primary")
    }
    
    private func updateMyLocationButton() {
        self.markerIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async { [weak self] in
            DispatchQueue.main.async {
                switch self?.mapView.positionMode  {
                case .normal, .direction:
                    self?.myLocationButton.setImage(UIImage(named: "icon_current_location_lg"), for: .normal)
                    self?.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                    UIApplication.shared.isIdleTimerDisabled = false // 화면 켜짐 유지 끔
                    break
                case .compass:
                    self?.myLocationButton.setImage(UIImage(named: "icon_compass_lg"), for: .normal)
                    self?.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                    UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
                    break
                default:
                    break
                }
                self?.markerIndicator.stopAnimating()
            }
        }
    }
    
    // 더 이상 보지 않기 한 광고가 정해진 기간을 넘겼는지 체크 및 광고 노출
    private func showStartAd() {
        if let window = UIApplication.shared.keyWindow {
            let keepDateStr = UserDefault().readString(key: UserDefault.Key.AD_KEEP_DATE_FOR_A_WEEK)
            if keepDateStr.isEmpty {
                window.addSubview(EIAdDialog(frame: window.bounds))
            } else {
                if let keepDate = Date().toDate(data: keepDateStr) {
                    let difference = NSCalendar.current.dateComponents([.day], from: keepDate, to: Date());
                    if let day = difference.day {
                        if day > 3 {
                            window.addSubview(EIAdDialog(frame: window.bounds))
                        }
                    }
                } else {
                    window.addSubview(EIAdDialog(frame: window.bounds))
                }
            }
        }
    }
    
    private func showMarketingPopup() {
        if (UserDefault().readBool(key: UserDefault.Key.DID_SHOW_MARKETING_POPUP) == false) { // 마케팅 동의받지 않은 회원의 첫 부팅 시
            let popupModel = PopupModel(title: "더 나은 충전 생활 안내를 위해 동의가 필요해요.",
                                        message:"EV Infra는 사용자님을 위해 도움되는 혜택 정보를 보내기 위해 노력합니다. 무분별한 광고 알림을 보내지 않으니 안심하세요!\n마케팅 수신 동의 변경은 설정 > 마케팅 정보 수신 동의에서 철회 가능합니다.",
                                        confirmBtnTitle: "동의하기",
                                        cancelBtnTitle: "다음에") { [weak self] in
                guard let self = self else { return }
                self.updateMarketingNotification(noti: true)
            } cancelBtnAction: { [weak self] in
                guard let self = self else { return }
                self.updateMarketingNotification(noti: false)
            }
            
            let popup = ConfirmPopupViewController(model: popupModel)
            
            self.present(popup, animated: false, completion: nil)
        }
    }
    
    private func updateMarketingNotification(noti: Bool) {
        Server.updateMarketingNotificationState(state: noti, completion: {(isSuccess, value) in
            if (isSuccess) {
                let json = JSON(value)
                let code = json["code"].stringValue
                if code.elementsEqual("1000") {
                    let receive = json["receive"].boolValue
                    UserDefault().saveBool(key: UserDefault.Key.SETTINGS_ALLOW_MARKETING_NOTIFICATION, value: receive)
                    UserDefault().saveBool(key: UserDefault.Key.DID_SHOW_MARKETING_POPUP, value: true)
                    let currDate = DateUtils.getFormattedCurrentDate(format: "yyyy년 MM월 dd일")
                    
                    var message = ""
                    if (receive) {
                        message = "[EV Infra] " + currDate + "마케팅 수신 동의 처리가 완료되었어요! ☺️ 더 좋은 소식 준비할게요!"
                    } else {
                        message = "[EV Infra] " + currDate + "마케팅 수신 거부 처리가 완료되었어요."
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        Snackbar().show(message: message)
                    }
                }
            } else {
                Snackbar().show(message: "서버통신이 원활하지 않습니다")
            }
        })
    }
    
    private func showGuide() {
        let window = UIApplication.shared.keyWindow!
        let guideView = GuideAlertDialog(frame: window.bounds)
        guideView.closeDelegate = {[weak self] isLiked in
            guard let self = self else { return }
            self.showMarketingPopup()
        }
        window.addSubview(guideView)
    }
    
    private func checkFCM() {
        if let notification = FCMManager.sharedInstance.fcmNotification {
            FCMManager.sharedInstance.alertMessage(data: notification)
        }
    }
    
    private func menuBadgeAdd() {
        if Board.sharedInstance.hasNew() || UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) {
            appDelegate.appToolbarController.setMenuIcon(hasBadge: true)
        } else {
            appDelegate.appToolbarController.setMenuIcon(hasBadge: false)
        }
    }
    
    private func prepareClustering() {
        clusterManager = ClusterManager(mapView: mapView)
        clusterManager?.isClustering = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
    }
    
    private func updateClustering() {
//        clusterManager?.removeChargerForClustering(zoomLevel: Int(naverMapView.mapView.zoomLevel))
        clusterManager?.removeClusterFromSettings()
        clusterManager?.isClustering = defaults.readBool(key: UserDefault.Key.SETTINGS_CLUSTER)
        drawMapMarker()
    }
}

extension MainViewController {
    private func prepareMenuBtnLayer() {
        btn_main_community.alignTextUnderImage()
        btn_main_community.tintColor = UIColor(named: "gr-8")
        btn_main_community.setImage(UIImage(named: "ic_comment")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_help.alignTextUnderImage()
        btn_main_help.tintColor = UIColor(named: "gr-8")
        btn_main_help.setImage(UIImage(named: "icon_main_faq")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        btn_main_favorite.alignTextUnderImage()
        btn_main_favorite.tintColor = UIColor(named: "gr-8")
        btn_main_favorite.setImage(UIImage(named: "ic_line_favorite")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    @IBAction func onClickMainCharge(_ sender: UIButton) {
        if MemberManager.shared.isLogin {
            Server.getChargingId { (isSuccess, responseData) in
                if isSuccess {
                    let json = JSON(responseData)
                    self.responseGetChargingId(response: json)
                }
            }
        } else {
            MemberManager.shared.showLoginAlert()
        }
    }
    
    @IBAction func onClickCommunityBtn(_ sender: Any) {
        UserDefault().saveInt(key: UserDefault.Key.LAST_FREE_ID, value: Board.sharedInstance.freeBoardId)
        
        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
        let freeBoardViewController = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
        freeBoardViewController.category = Board.BOARD_CATEGORY_FREE
        GlobalDefine.shared.mainNavi?.push(viewController: freeBoardViewController)
    }
    
    @IBAction func onClickMainHelp(_ sender: UIButton) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsViewController = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
        termsViewController.tabIndex = .FAQTop
        GlobalDefine.shared.mainNavi?.push(viewController: termsViewController)
    }
}

extension MainViewController {
    private func responseGetChargingId(response: JSON) {
        if response.isEmpty {
            return
        }
        
        let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
        switch (response["code"].intValue) {
        case 1000:
            defaults.saveString(key: UserDefault.Key.CHARGING_ID, value: response["charging_id"].stringValue)
            let paymentStatusViewController = paymentStoryboard.instantiateViewController(ofType: PaymentStatusViewController.self)

            paymentStatusViewController.cpId = response["cp_id"].stringValue
            paymentStatusViewController.connectorId = response["connector_id"].stringValue
            
            GlobalDefine.shared.mainNavi?.push(viewController: paymentStatusViewController)
        case 2002:
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
            if response["pay_code"].stringValue.equals("8804") {
                let repayListViewController = paymentStoryboard.instantiateViewController(ofType: RepayListViewController.self)
                repayListViewController.delegate = self
                GlobalDefine.shared.mainNavi?.push(viewController: repayListViewController)
            } else {
                let paymentQRScanViewController = paymentStoryboard.instantiateViewController(ofType: PaymentQRScanViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: paymentQRScanViewController)
            }
            
        default:
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
        }
    }
    
    private func chargingStatus() {
        if MemberManager.shared.isLogin {
            Server.getChargingId { (isSuccess, responseData) in
                if isSuccess {
                    let json = JSON(responseData)
                    self.getChargingStatus(response: json)
                }
            }
        } else {
            // 진행중인 충전이 없음
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
            self.btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.setTitle("간편 충전", for: .normal)
        }
    }
    
    private func getChargingStatus(response: JSON) {
        if response["pay_code"].stringValue.equals("8804") {
            defaults.saveBool(key: UserDefault.Key.HAS_FAILED_PAYMENT, value: true)
            ivMainChargeNew.isHidden = false
        } else {
            defaults.saveBool(key: UserDefault.Key.HAS_FAILED_PAYMENT, value: false)
            ivMainChargeNew.isHidden = true
        }
        menuBadgeAdd()
        switch (response["code"].intValue) {
        case 1000:
            // 충전중
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.setImage(UIImage(named: "ic_line_charging")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
            self.btn_main_charge.setTitle("충전중", for: .normal)
            break
            
        case 2002:
            // 진행중인 충전이 없음
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
            self.btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.setTitle("간편 충전", for: .normal)
            break
            
        default:
            break
        }
    }
}

extension MainViewController: RepaymentListDelegate {
    func onRepaySuccess() {
        let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
        let paymentQRScanViewController = paymentStoryboard.instantiateViewController(ofType: PaymentQRScanViewController.self)
        GlobalDefine.shared.mainNavi?.push(viewController: paymentQRScanViewController)
    }
    
    func onRepayFail() {
    }
}

extension MainViewController: LoginHelperDelegate {
    var loginViewController: UIViewController {
        return self
    }
    
    func successLogin() {
        self.chargingStatus()
    }
    
    func needSignUp(user: Login) {
    }
}

