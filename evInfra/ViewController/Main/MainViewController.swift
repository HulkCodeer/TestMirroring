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

class MainViewController: UIViewController {
    // user Default
    let defaults = UserDefault()
    
    @IBOutlet weak var myLocationButton: UIButton!
    @IBOutlet weak var reNewButton: UIButton!
    @IBOutlet weak var btnChargePrice: UIButton!
    
    // Indicator View
    @IBOutlet weak var markerIndicator: UIActivityIndicatorView!
    
    // Filter View
    @IBOutlet weak var filterView: UIView!
    @IBOutlet var findRouteView: RouteView!
    
    @IBOutlet weak var filterBarView: FilterBarView!
    @IBOutlet weak var filterContainerView: FilterContainerView!
    @IBOutlet weak var filterHeight: NSLayoutConstraint!
    
    // Callout View
    @IBOutlet weak var callOutLayer: UIView!
    // Menu Button Layer
    @IBOutlet var btn_menu_layer: UIView!
    @IBOutlet var btn_main_charge: UIButton!
    @IBOutlet var btn_main_community: UIButton!
    @IBOutlet var btn_main_help: UIButton!
    @IBOutlet var btn_main_favorite: UIButton!
    
    //경로찾기시 거리표시 뷰 (call out)
    private let routeDistanceView: RouteDistanceView = RouteDistanceView()
    
    @IBOutlet weak var ivMainChargeNew: UIImageView!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var tMapView: TMapView? = nil
    private var tMapPathData: TMapPathData = TMapPathData.init()
    
    private var naverMapView: NaverMapView!
    private var mapView: NMFMapView { naverMapView.mapView }
    private var locationManager = CLLocationManager()
    private var chargerManager = ChargerManager.sharedInstance
    private var selectCharger: ChargerStationInfo? = nil
    private var sharedChargerId: String? = nil
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
        
        configureNaverMapView()
        configureLocationManager()
        configureLayer()
        showGuide()

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
    
    func showDeepLink() {
        DeepLinkPath.sharedInstance.runDeepLink()
    }
    
    // Filter
    func prepareFilterView() {
        filterBarView.delegate = self
        filterContainerView.delegate = self
    }
    
    private func prepareRouteView() {
        findRouteView.delegate = self
        routeDistanceView.delegate = self
        view.addSubview(routeDistanceView)
        routeDistanceView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(60)
        }
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
    
    func prepareTmapAPI() {
        tMapView = TMapView()
        tMapView?.setSKTMapApiKey(Const.TMAP_APP_KEY)
    }
    
    // btnChargePrice radius, color, shadow
    func prepareChargePrice() {
        btnChargePrice.layer.cornerRadius = 16
        btnChargePrice.layer.shadowRadius = 5
        btnChargePrice.layer.shadowColor = UIColor.black.cgColor
        btnChargePrice.layer.shadowOpacity = 0.3
        btnChargePrice.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        btnChargePrice.layer.masksToBounds = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onClickChargePrice))
        btnChargePrice.addGestureRecognizer(gesture)
    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
 
    func setStartPath() {
        let passList = naverMapView
            .viaList
            .map {
                TMapPoint(lon: $0.lng, lat: $0.lat)!
            }
        
        if !passList.isEmpty {
            let via = naverMapView.viaList.first ?? POIObject(name: "", lat: .zero, lng: .zero)
            naverMapView.midMarker?.mapView = nil
            naverMapView.midMarker = Marker(NMGLatLng(lat: via.lat,
                                                           lng: via.lng), .mid)
            naverMapView.midMarker?.mapView = self.mapView
        }
        
        findPath(passList: passList)
    }
    
    func showNavigation(start: POIObject, destination: POIObject, via: [POIObject]) {
        UtilNavigation().showNavigation(vc: self, startPoint: start, endPoint: destination, viaList: via)
    }
    
    @objc func onClickChargePrice(sender: UITapGestureRecognizer) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let priceInfoVC: TermsViewController = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        priceInfoVC.tabIndex = .PriceInfo
        self.navigationController?.push(viewController: priceInfoVC)
    }
    
    // MARK: - Action for button
    @IBAction func onClickMyLocation(_ sender: UIButton) {
        if isLocationEnabled() {
            let mode = mapView.positionMode
            
            if mode == .normal {
                naverMapView.moveToCurrentPostiion()
                mapView.positionMode = .direction
            } else if mode == .direction {
                mapView.positionMode = .compass
            } else if mode == .compass {
                mapView.positionMode = .normal
            }
            updateMyLocationButton()
        } else {
            askPermission()
        }
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
        filterContainerView.isHidden = true
        filterBarView.updateView(newSelect: .none)
        
        let routeViewHeight = findRouteView.isShow ? findRouteView.frame.height : 0
        let filterBarViewHeight = filterBarView.isShow ? filterContainerView.frame.height : 0
        let expanded = filterHeight.constant == RouteView.Height.expand.value ? filterBarView.frame.height : 0
        let totalHeight = routeViewHeight + filterBarViewHeight - expanded
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.myLocationButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
            self.reNewButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
        }
    }
    
    func showFilter(){
        filterContainerView.isHidden = false
        
        let routeViewHeight = findRouteView.isShow ? findRouteView.frame.height : 0
        let filterBarViewHeight = filterBarView.isShow ? filterContainerView.frame.height : 0
        let expanded = filterHeight.constant == RouteView.Height.expand.value ? filterBarView.frame.height : 0
        let totalHeight = routeViewHeight + filterBarViewHeight - expanded
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.myLocationButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
            self.reNewButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
        }
    }
    
    func startFilterSetting(){
        // chargerFilterViewcontroller
        let filterStoryboard = UIStoryboard(name : "Filter", bundle: nil)
        let chargerFilterVC:ChargerFilterViewController = filterStoryboard.instantiateViewController(withIdentifier: "ChargerFilterViewController") as! ChargerFilterViewController
        chargerFilterVC.delegate = self
        self.navigationController?.push(viewController: chargerFilterVC)
    }
    
    @IBAction func onClickMainFavorite(_ sender: UIButton) {
        if MemberManager.shared.isLogin {
            let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
            let favoriteVC:FavoriteViewController = memberStoryboard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
            favoriteVC.delegate = self
            self.present(AppNavigationController(rootViewController: favoriteVC), animated: true, completion: nil)
        } else {
            MemberManager.shared.showLoginAlert()
        }
    }
}

// MARK: 경로 안내 뷰 Delegate
extension MainViewController: DelegateRouteDistance {
    func closeView() {
        clearSearchResult()
        hideFilter()
        myLocationModeOff()
        setView(view: routeDistanceView, hidden: true)
    }
    
    func showNaviagtionSelectedMenu() {
        guard let destination = naverMapView.destination else { return }
        guard let start = naverMapView.start else {
            let currentPoint = locationManager.getCurrentCoordinate()
            let point = TMapPoint(coordinate: currentPoint)
            
            let positionName = tMapPathData.convertGpsToAddress(at: point) ?? ""
            let start = POIObject(name: positionName, lat: currentPoint.latitude, lng: currentPoint.longitude)
            
            self.showNavigation(start: start, destination: destination, via: naverMapView.viaList)
            return
        }
        
        showNavigation(start: start, destination: destination, via: naverMapView.viaList)
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
    internal func drawMapMarker() {
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
            let searchViewController = UIStoryboard(name : "Map", bundle: nil).instantiateViewController(ofType: SearchViewController.self)
            searchViewController.delegate = self
            GlobalDefine.shared.mainNavi?.present(AppSearchBarController(rootViewController: searchViewController), animated: true)
        case 2: // 경로 찾기 버튼
            findRouteView.isShow = !findRouteView.isShow
            showRouteView(isShow: findRouteView.isShow)
        default: break
        }
    }
    
    func showRouteView(isShow: Bool) {
        guard isShow else {
            let filterBarViewHeight = filterBarView.isShow ? filterView.frame.height - filterBarView.frame.height : 0
            let routeViewHeight = findRouteView.isShow ? findRouteView.frame.height : 0
            let totalHeight = filterBarViewHeight - routeViewHeight
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
                self.filterView.transform = .identity
                self.myLocationButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
                self.reNewButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
            }
            updateView(isShow: false)
            clearSearchResult()
            return
        }
        
        findRouteView.isShow = isShow
        setStartPosition()
        
        let filterBarViewHeight = filterBarView.isShow ? filterView.frame.height : 0
        let routeViewHeight = findRouteView.frame.height
        let totalHeight = filterBarViewHeight + routeViewHeight
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.filterView.transform = CGAffineTransform(translationX: 0.0, y: routeViewHeight)
            self.myLocationButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
            self.reNewButton.transform = CGAffineTransform(translationX: 0.0, y: totalHeight)
        }
    }
    
    private func setStartPosition() {
        let currentPoint = locationManager.getCurrentCoordinate()
        let address = tMapPathData.convertGpsToAddress(at: TMapPoint(coordinate: currentPoint)) ?? "현재위치"
        naverMapView.start = POIObject(name: "\(address)", lat: currentPoint.latitude, lng: currentPoint.longitude)
        findRouteView.findStartLocationButton.setTitle("\(address)", for: .normal)
    }
}

// MARK: FindRouteView Delegate
extension MainViewController: DelegateFindRouteView {
    func updateView(isShow: Bool) {
        filterHeight.constant = isShow ? RouteView.Height.expand.value : RouteView.Height.normal.value
        findRouteView.snp.updateConstraints {
            $0.top.equalTo(self.filterView.snp.top)
        }
        filterBarView.snp.updateConstraints {
            $0.bottom.equalTo(self.filterView.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            self.findRouteView.layoutIfNeeded()
            self.filterBarView.layoutIfNeeded()
        }
    }
    
    func removeViaRoute() {
        defer {
            naverMapView.clearMidMarker()
            naverMapView.viaList.removeAll()
        }
        guard let _ = naverMapView.destination else { return }
        setStartPath()
    }
    
    func removeDestinationRoute() {
        guard let via = naverMapView.viaList.first else {
            clearSearchResult()
            return
        }
        
        naverMapView.setMarker(lat: via.lat, lng: via.lng, stationName: via.name, type: .end)
        naverMapView.endMarker?.mapView = self.mapView
        
        naverMapView.clearMidMarker()
        naverMapView.viaList.removeAll()
        
        setStartPath()
    }
    
    func swapLocation(route1: RoutePosition, route2: RoutePosition) {
        switch (route1, route2) {
        case (.start, .end):
            guard let destination = naverMapView.destination,
                    let temp = naverMapView.start else { return }
            
            naverMapView.setMarker(lat: destination.lat, lng: destination.lng, stationName: destination.name, type: .start)
            naverMapView.startMarker?.mapView = self.mapView
            
            naverMapView.setMarker(lat: temp.lat, lng: temp.lng, stationName: temp.name, type: .end)
            naverMapView.endMarker?.mapView = self.mapView
            
            setStartPath()
        case (.start, .mid):
            guard let via = naverMapView.viaList.first,
                    let temp = naverMapView.start else { return }

            naverMapView.setMarker(lat: via.lat, lng: via.lng, stationName: via.name, type: .start)
            naverMapView.startMarker?.mapView = self.mapView
            
            let newVia = POIObject(name: temp.name, lat: temp.lat, lng: temp.lng)
            naverMapView.clearMidMarker()
            naverMapView.viaList.append(newVia)
            
            setStartPath()
        case (.mid, .end):
            guard let via = naverMapView.viaList.first else { return }
            naverMapView.clearMidMarker()
            
            let newVia = naverMapView.destination ?? POIObject(name: "경유지", lat: .zero, lng: .zero)
            naverMapView.viaList.append(newVia)
            
            naverMapView.setMarker(lat: via.lat, lng: via.lng, stationName: via.name, type: .end)
            naverMapView.endMarker?.mapView = self.mapView
        
            setStartPath()
        default: break
        }
    }
}

extension MainViewController: TextFieldDelegate {
    @objc func onClickRouteCancel(_ sender: UIButton) {
        clearSearchResult()
    }
    
    @objc func onClickRoute(_ sender: UIButton) {
        findPath(passList: [])
    }
    
    func clearSearchResult() {
        setView(view: routeDistanceView, hidden: true)
        btnChargePrice.isHidden = false
        btn_menu_layer.isHidden = false
        
        findRouteView.clearView()
        findRouteView.clearButtonTitle()
        
        naverMapView.clearStartMarker()
        naverMapView.clearMidMarker()
        naverMapView.clearEndMarker()
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
        defer {
            setView(view: callOutLayer, hidden: true)
            btnChargePrice.isHidden = true
            btn_menu_layer.isHidden = true
        }
        
        // 시작 위치, 도착 위치 없을때
        guard let endPosition = naverMapView.destination else { return }
        
        let currentPoint = locationManager.getCurrentCoordinate()
        let address = tMapPathData.convertGpsToAddress(at: TMapPoint(coordinate: currentPoint)) ?? "현재위치"

        let startPosition = naverMapView.start ?? POIObject(name: "\(address)", lat: currentPoint.latitude, lng: currentPoint.longitude)

        if naverMapView.startMarker == nil {
            naverMapView.startMarker = Marker(NMGLatLng(from: currentPoint), .start)
            naverMapView.startMarker?.globalZIndex = 350000
            naverMapView.startMarker?.mapView = self.mapView
        }
        
        // 출발 <-> 도착 경로에 따른 맵 줌레벨 설정
        let bounds = NMGLatLngBounds(southWestLat: startPosition.lat,
                                     southWestLng: startPosition.lng,
                                     northEastLat: endPosition.lat,
                                     northEastLng: endPosition.lng)

        let zoomLevel = NMFCameraUtils.getFittableZoomLevel(with: bounds, insets: UIEdgeInsets(top: 250, left: 100, bottom: 250, right: 100), mapView: self.mapView)

        // 출발, 도착의 가운데 지점으로 map 이동
        naverMapView.moveToCamera(with: bounds.center, zoomLevel: zoomLevel)
        
        // 경로 요청
        DispatchQueue.global(qos: .background).async { [weak self] in
            var polyLine: TMapPolyLine? = nil
            if passList.isEmpty {
                polyLine = self?.tMapPathData.find(from: startPosition.tmapPoint, to: endPosition.tmapPoint)
            } else {
                polyLine = self?.tMapPathData.findMultiPathData(withStart: startPosition.tmapPoint, end: endPosition.tmapPoint, passPoints: passList, searchOption: 0)
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

            positions.insert(NMGLatLng(from: startPosition.tmapPoint.coordinate), at: 0)
            positions.insert(NMGLatLng(from: endPosition.tmapPoint.coordinate), at: positions.count)
            pathOverlay.path = NMGLineString(points: positions)
            
            DispatchQueue.main.async {
                // 경로선 초기화
                self?.naverMapView.path?.mapView = nil
                self?.naverMapView.path = nil
                                
                // 경로선 그리기
                self?.naverMapView.path = pathOverlay
                self?.naverMapView.path?.mapView = self?.mapView
                
                self?.drawPathData(polyLine: pathOverlay.path, distance: distance)
                self?.markerIndicator.stopAnimating()
            }
        }
    }
    
    func drawPathData(polyLine: NMGLineString<AnyObject>, distance: Double) {
        findChargerAroundRoute(polyLine: polyLine)
        self.clusterManager?.isRouteMode = true
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
        
        drawMapMarker()
        
        let strDistance = distance > 1000 ? NSString(format: "약 %dkm", Int(distance/1000)) : NSString(format: "약 %dm", Int(distance))
        routeDistanceView.setRouteLabel(with: strDistance)
        setView(view: routeDistanceView, hidden: false)
        summaryView.layoutAddPathSummary(hiddenAddBtn: !self.clusterManager!.isRouteMode)
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
}

extension MainViewController: MarkerTouchDelegate {
    func touchHandler(with charger: ChargerStationInfo) {
        let position = charger.mapMarker.position
        
        naverMapView.moveToCamera(with: NMGLatLng(lat: position.lat, lng: position.lng), zoomLevel: 14)
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
        let detailVC:DetailViewController = detailStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.charger = self.selectCharger
        detailVC.isRouteMode = self.clusterManager!.isRouteMode
        
        self.navigationController?.push(viewController: detailVC, subtype: kCATransitionFromTop)
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
        
        DispatchQueue.global(qos: .userInitiated).async {
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
    }
    
    internal func refreshChargerInfo() {
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
        center.addObserver(self, selector: #selector(directionNavigation(_:)), name: Notification.Name(summaryView.navigationKey), object: nil)
        center.addObserver(self, selector: #selector(requestLogIn(_:)), name: Notification.Name(summaryView.loginKey), object: nil)
        center.addObserver(self, selector: #selector(isChangeFavorite(_:)), name: Notification.Name(summaryView.favoriteKey), object: nil)
        center.addObserver(self, selector: #selector(setStartPosition(_:)), name: Notification.Name(rawValue: "startMarker"), object: nil)
        center.addObserver(self, selector: #selector(setViaPosition(_:)), name: Notification.Name(rawValue: "viaMarker"), object: nil)
        center.addObserver(self, selector: #selector(setDestinationPosition(_:)), name: Notification.Name(rawValue: "destinationMarker"), object: nil)
    }
    
    func removeObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name("updateMemberInfo"), object: nil)
    }
    
    func removeSummaryObserver() {
        let center = NotificationCenter.default
        center.removeObserver(self, name: Notification.Name(summaryView.navigationKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.loginKey), object: nil)
        center.removeObserver(self, name: Notification.Name(summaryView.favoriteKey), object: nil)
        center.removeObserver(self, name: Notification.Name(rawValue: "startMarker"), object: nil)
        center.removeObserver(self, name: Notification.Name(rawValue: "viaMarker"), object: nil)
        center.removeObserver(self, name: Notification.Name(rawValue: "destinationMarker"), object: nil)
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
        guard let sharedId = notification.userInfo?["sharedid"] as? String else { return }

        self.sharedChargerId = sharedId
        if self.loadedChargers {
            selectChargerFromShared()
        }
    }
    
    @objc func setStartPosition(_ notification: NSNotification) {
        guard let charger = notification.object as? ChargerStationInfo,
              let stationInfo = charger.mStationInfoDto else { return }
        
        GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
        naverMapView.setMarker(lat: stationInfo.mLatitude ?? .zero,
                               lng: stationInfo.mLongitude ?? .zero,
                               stationName: stationInfo.mSnm ?? "",
                               type: .start)
        naverMapView.startMarker?.mapView = self.mapView

        // 카메라 이동
        naverMapView.moveToCamera(with: NMGLatLng(lat: stationInfo.mLatitude ?? .zero,
                                                  lng: stationInfo.mLongitude ?? .zero), zoomLevel: 14)
        setStartPath()
    }
    
    @objc func setViaPosition(_ notification: NSNotification) {
        guard let charger = notification.object as? ChargerStationInfo,
              let stationInfo = charger.mStationInfoDto else { return }
        
        findRouteView.addViaView()
        let via = POIObject(name: stationInfo.mSnm ?? "",
                            lat: stationInfo.mLatitude ?? .zero,
                            lng: stationInfo.mLongitude ?? .zero)
        
        naverMapView.viaList.removeAll()
        naverMapView.viaList.append(via)
        naverMapView.moveToCamera(with: NMGLatLng(from: via.tmapPoint.coordinate), zoomLevel: 14)
                
        setStartPath()
    }
    
    @objc func setDestinationPosition(_ notification: NSNotification) {
        guard let charger = notification.object as? ChargerStationInfo,
              let stationInfo = charger.mStationInfoDto else { return }
        
        findRouteView.isShow ? nil : showRouteView(isShow: true)
        GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)

        naverMapView.setMarker(lat: stationInfo.mLatitude ?? .zero,
                               lng: stationInfo.mLongitude ?? .zero,
                               stationName: stationInfo.mSnm ?? "",
                               type: .end)
        naverMapView.endMarker?.mapView = self.mapView
        
        setStartPath()
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
    
    func selectChargerFromShared() {
        if let id = self.sharedChargerId {
            self.selectCharger(chargerId: id)
            self.sharedChargerId = nil
            if let sharedCharger = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: id) {
                let position = NMGLatLng(lat: sharedCharger.mStationInfoDto?.mLatitude ?? 0.0, lng: sharedCharger.mStationInfoDto?.mLongitude ?? 0.0)
                naverMapView.moveToCamera(with: position, zoomLevel: 14)
            }
        }
    }
    
    func isLocationEnabled() -> Bool {
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
    
    func askPermission(){
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
    
    internal func myLocationModeOff() {
        mapView.positionMode = .normal
        updateMyLocationButton()
    }
    
    internal func updateMyLocationButton() {
        self.markerIndicator.startAnimating()
        DispatchQueue.global(qos: .background).async { [weak self] in
            DispatchQueue.main.async {
                let mode = self?.mapView.positionMode
                switch mode  {
                case .disabled:
                    break
                case .normal:
                    self?.myLocationButton.setImage(UIImage(named: "icon_current_location_lg"), for: .normal)
                    self?.myLocationButton.tintColor = UIColor.init(named: "content-primary")
                    UIApplication.shared.isIdleTimerDisabled = false // 화면 켜짐 유지 끔
                    break
                case .direction:
                    self?.myLocationButton.setImage(UIImage(named: "icon_current_location_lg"), for: .normal)
                    self?.myLocationButton.tintColor = UIColor.init(named: "content-positive")
                    UIApplication.shared.isIdleTimerDisabled = true // 화면 켜짐 유지
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
    
    func showMarketingPopup() {
        // TODO :: 첫 부팅 시에만 처리할 동작 있으면
        // chargermanagerlistener oncomplete에서 묶어서 처리 후 APP_FIRST_BOOT 변경
        if (UserDefault().readBool(key: UserDefault.Key.APP_FIRST_BOOT) == false) { // 첫부팅 시
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
                    UserDefault().saveBool(key: UserDefault.Key.APP_FIRST_BOOT, value: true)
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
    
    func prepareClustering() {
        clusterManager = ClusterManager(mapView: mapView)
    }
    
    func updateClustering() {
        clusterManager?.removeChargerForClustering(zoomLevel: Int(naverMapView.mapView.zoomLevel))
        drawMapMarker()
    }
}

extension MainViewController {
    
    func prepareMenuBtnLayer() {
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
        let freeBoardVC = boardStoryboard.instantiateViewController(withIdentifier: "CardBoardViewController") as! CardBoardViewController
        freeBoardVC.category = Board.BOARD_CATEGORY_FREE
        navigationController?.push(viewController: freeBoardVC)
    }
    
    @IBAction func onClickMainHelp(_ sender: UIButton) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsViewControll = infoStoryboard.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
        termsViewControll.tabIndex = .FAQTop
        self.navigationController?.push(viewController: termsViewControll)
    }
}

extension MainViewController {
    func responseGetChargingId(response: JSON) {
        if response.isEmpty {
            return
        }
        
        let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
        switch (response["code"].intValue) {
        case 1000:
            defaults.saveString(key: UserDefault.Key.CHARGING_ID, value: response["charging_id"].stringValue)
            let paymentStatusVC = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentStatusViewController") as! PaymentStatusViewController
            paymentStatusVC.cpId = response["cp_id"].stringValue
            paymentStatusVC.connectorId = response["connector_id"].stringValue
            
            self.navigationController?.push(viewController: paymentStatusVC)
            
        case 2002:
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
            if response["pay_code"].stringValue.equals("8804") {
                let repayListVC = paymentStoryboard.instantiateViewController(withIdentifier: "RepayListViewController") as! RepayListViewController
                repayListVC.delegate = self
                self.navigationController?.push(viewController: repayListVC)
            } else {
                let paymentQRScanVC = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentQRScanViewController") as! PaymentQRScanViewController
                self.navigationController?.push(viewController:paymentQRScanVC)
            }
            
        default:
            defaults.removeObjectForKey(key: UserDefault.Key.CHARGING_ID)
        }
    }
    
    func chargingStatus() {
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
    
    func getChargingStatus(response: JSON) {
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
        case 2002:
            // 진행중인 충전이 없음
            self.btn_main_charge.alignTextUnderImage()
            self.btn_main_charge.tintColor = UIColor(named: "gr-8")
            self.btn_main_charge.setImage(UIImage(named: "ic_line_payment")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.btn_main_charge.setTitle("간편 충전", for: .normal)
        default: break
        }
    }
}

extension MainViewController: RepaymentListDelegate {
    func onRepaySuccess() {
        let paymentStoryboard = UIStoryboard(name : "Payment", bundle: nil)
        let paymentQRScanVC = paymentStoryboard.instantiateViewController(withIdentifier: "PaymentQRScanViewController") as! PaymentQRScanViewController
        self.navigationController?.push(viewController:paymentQRScanVC)
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

