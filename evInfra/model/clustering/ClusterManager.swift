//
//  Clustering.swift
//  evInfra
//
//  Created by bulacode on 13/12/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation
import NMapsMap

class ClusterManager {
    
    public static let LEVEL_0_ZOOM = 13
    public static let LEVEL_1_ZOOM = 11
    public static let LEVEL_2_ZOOM = 8
    public static let LEVEL_3_ZOOM = 6
    
    let headers = ["charger0", "cluster1", "cluster2", "cluster3", "cluster4"] // 클러스터링 에셋 파일명
    private static let CLUSTER_LEVEL_4 = 4    // 내륙 제주
    private static let CLUSTER_LEVEL_3 = 3    // 도
    private static let CLUSTER_LEVEL_2 = 2    // 시군 (7대도시는 구)
    private static let CLUSTER_LEVEL_1 = 1    // 구 임시적으로 쓰지 않음..
    private static let CLUSTER_LEVEL_0 = 0    // 일반
    
    private static let MARKER_THRESHOLD_SIZE = 2
    private static let MAX_ZOOM_LEVEL = 9
    
    var clusters = [[CodableCluster.Cluster]?]()
    var isClustering: Bool = false
    var isNeedChangeText: Bool = false
    var clusterFilter: ChargerFilter? = nil
    var currentClusterLv = -1
    var tMapView: TMapView?
    var mapView: NMFMapView?
    var isRouteMode: Bool = false
    
    var clusterGenerator = ClusterGenerator.init()
//    init() {
//        prepareClusterInfo()
//        prepareClusterMarker()
//    }
    
    init(mapView: NMFMapView) {
        self.mapView = mapView
        prepareClusterInfo()
        prepareClusterMarker()
    }
    
//    init(mapView: TMapView) {
//        self.tMapView = mapView
//        prepareClusterInfo()
//        prepareClusterMarker()
//    }
    
    func prepareClusterInfo() {
        for assetFile in headers {
            if let asset = NSDataAsset(name: assetFile, bundle: Bundle.main) {
                let json = try! JSONDecoder().decode(CodableCluster.self, from: asset.data)
                clusters.append(json.lists)
            } else {
                clusters.append(nil)
            }
        }
    }
    
    func prepareClusterMarker() {
        prepareMarkers(clusters: self.clusters[ClusterManager.CLUSTER_LEVEL_1], markerHeader: headers[ClusterManager.CLUSTER_LEVEL_1])
        prepareMarkers(clusters: self.clusters[ClusterManager.CLUSTER_LEVEL_2], markerHeader: headers[ClusterManager.CLUSTER_LEVEL_2])
        prepareMarkers(clusters: self.clusters[ClusterManager.CLUSTER_LEVEL_3], markerHeader: headers[ClusterManager.CLUSTER_LEVEL_3])
        prepareMarkers(clusters: self.clusters[ClusterManager.CLUSTER_LEVEL_4], markerHeader: headers[ClusterManager.CLUSTER_LEVEL_4])
    }
    
    func prepareMarkers(clusters: [CodableCluster.Cluster]?, markerHeader: String) {
        guard let clusters = clusters else { return }
        
        for cluster in clusters {
            if cluster.baseImage == nil {
                cluster.baseImage = self.clusterGenerator.generateBaseImage(area: cluster.name ?? "")
            }
            
            let latLng = NMGLatLng(lat: cluster.lat ?? 0.0, lng: cluster.lng ?? 0.0)
            let marker = Marker(position: latLng)
            
            let clusterImage = self.clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!)
//                    marker.chargerId = "\(markerHeader)_\(cluster.id!)"
            marker.iconImage = NMFOverlayImage(image: clusterImage!)
            cluster.marker = marker
//            cluster.marker.mapView = self.mapView
        }
        
        
        
        /*
        DispatchQueue.global(qos: .default).async {
            
            for cluster in clusters {
                if cluster.baseImage == nil {
                    cluster.baseImage = self.clusterGenerator.generateBaseImage(area: cluster.name ?? "")
                }
                
                let latLng = NMGLatLng(lat: cluster.lat ?? 0.0, lng: cluster.lng ?? 0.0)
                let marker = NMFMarker(position: latLng)
                
                let clusterImage = self.clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!)
                marker.iconImage = NMFOverlayImage.init(image: clusterImage!)
                cluster.marker = marker
            }
            
            DispatchQueue.main.async {
                for cluster in clusters {
                    cluster.marker.mapView = self.mapView
                }
            }
        }
         */
    }
    /*
    func prepareMarkers(clusters: [CodableCluster.Cluster]?, markerHeader: String) {
        if let clusterList = clusters {
            for cluster in clusterList {
                let marker = TMapMarkerItem.init()
                if (cluster.baseImage == nil) {
                    cluster.baseImage = clusterGenerator.generateBaseImage(area: cluster.name!)
                }
                marker.setTMapPoint(TMapPoint.init(lon: cluster.lng!, lat: cluster.lat!))
                marker.setID("\(markerHeader)_\(cluster.id!)")
                marker.setIcon(clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!))
                cluster.marker = marker
            }
        }
    }
    */
    
    func calClustering(filter: ChargerFilter) {
        if let baseClusters = self.clusters[ClusterManager.CLUSTER_LEVEL_1] {
            for baseCluster in baseClusters {
                baseCluster.initSum()
                self.clusters[ClusterManager.CLUSTER_LEVEL_2]?[baseCluster.cl2_id! - 1].initSum()
                self.clusters[ClusterManager.CLUSTER_LEVEL_3]?[baseCluster.cl1_id! - 1].initSum()
            }
            self.clusters[ClusterManager.CLUSTER_LEVEL_4]?[0].initSum()
            self.clusters[ClusterManager.CLUSTER_LEVEL_4]?[1].initSum()
        }
        
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
            if charger.isAroundPath && charger.check(filter: filter) {
                if (charger.mStationInfoDto?.mArea)! > 0 {
                    if let cluster = self.clusters[ClusterManager.CLUSTER_LEVEL_1]?[(charger.mStationInfoDto?.mArea)! - 1] {
                        self.clusters[ClusterManager.CLUSTER_LEVEL_1]?[(charger.mStationInfoDto?.mArea)! - 1].addVal()
                        self.clusters[ClusterManager.CLUSTER_LEVEL_2]?[cluster.cl2_id! - 1].addVal()
                        self.clusters[ClusterManager.CLUSTER_LEVEL_3]?[cluster.cl1_id! - 1].addVal()
                        
                        // 248:제주시 249:서귀포시
                        if ((charger.mStationInfoDto?.mArea)! == 248 || (charger.mStationInfoDto?.mArea)! == 249) {
                            self.clusters[ClusterManager.CLUSTER_LEVEL_4]?[1].addVal()
                        } else {
                            self.clusters[ClusterManager.CLUSTER_LEVEL_4]?[0].addVal()
                        }
                    }
                }
            }
        }
        self.clusterFilter = filter.copy()
        isNeedChangeText = true
    }
    
    // 클러스터에 충전소 갯수 Label 세팅 == setClusterText()
    func setCountOfStationInCluster() {
        for cluster in clusters {
            guard let clusterXs = cluster else {
                return
            }
            
            for cluster in clusterXs {
                let clusterImage = clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!)
                cluster.marker.iconImage = NMFOverlayImage(image: clusterImage!)
                cluster.marker.mapView = self.mapView
            }
        }
    }
//    func setClusterText() {
//        for clusters in self.clusters {
//            if let clusterXs = clusters {
//                for cluster in clusterXs {
//                    cluster.marker.setIcon(clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!))
//                }
//            }
//        }
//    }
    
/*
 기존 clustering 삭제 및 신규 clustering 생성
 */
    func clustering(filter: ChargerFilter, loadedCharger: Bool) {
        let stations = ChargerManager.sharedInstance.getChargerStationInfoList()
        
        DispatchQueue.global(qos: .default).async {
            if !filter.isSame(filter: self.clusterFilter) {
                guard stations.count > 1 else { return }
                self.calClustering(filter: filter)
            }
            
            var clusterLevel = ClusterManager.CLUSTER_LEVEL_0
            
            if self.isNeedChangeText {
                self.setCountOfStationInCluster()
                self.isNeedChangeText = false
            }
            guard let zoomLevelDouble = self.mapView?.zoomLevel as? Double else { return }
            let zoomLevel = Int(zoomLevelDouble)
            
            if self.isClustering {
                // zoom level에 따른 클러스터 레벨 세팅
                print("zoom Level : \(zoomLevel)")
                if zoomLevel < ClusterManager.LEVEL_3_ZOOM {
                    clusterLevel = ClusterManager.CLUSTER_LEVEL_4
                } else if zoomLevel < ClusterManager.LEVEL_2_ZOOM {
                    clusterLevel = ClusterManager.CLUSTER_LEVEL_3
                } else if zoomLevel < ClusterManager.LEVEL_1_ZOOM {
                    clusterLevel = ClusterManager.CLUSTER_LEVEL_2
                }
                print("현재 클러스터 레벨 : \(clusterLevel)")
//                    else if zoomLev < 13 {
//                        clusterLevel = ClusterManager.CLUSTER_LEVEL_1
//                    }
            }
            DispatchQueue.main.async {
                // 클러스터 레벨 변경시 마커를 지우는 루틴
                if (self.currentClusterLv != clusterLevel && self.currentClusterLv != -1) {
                    if self.currentClusterLv > ClusterManager.CLUSTER_LEVEL_0 {
                        // 클러스터 마커 지우기
                        guard let clusters = self.clusters[self.currentClusterLv] else { return }

                        for cluster in clusters {
                            cluster.marker.mapView = nil
//                            cluster.marker.hidden = true
                        }
                    } else if self.currentClusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                        for station in stations {
                            // 충전소 마커 지우기
                            station.mapMarker.mapView = nil
//                            station.mapMarker.hidden = true
                        }
                    }
                }
                
                // 클러스터 변경시 선택된 마커로 그려주는 루틴: 충전소 수가 0으로 변화할 경우 마커를 지우기 위해 필요
                if clusterLevel == ClusterManager.CLUSTER_LEVEL_0 {
                    var index = 0
                    let markerThreshold = self.getMarkerThreshold(filter: filter)
                    
                    for station in stations {
                        if index % markerThreshold == 0 {
                            if station.isAroundPath && station.check(filter: filter) {
                                if self.isContainMap(coord: station.mapMarker.position) {
                                    station.mapMarker.mapView = self.mapView
//                                    station.mapMarker.hidden = false
                                } else {
                                    station.mapMarker.mapView = nil
//                                    station.mapMarker.hidden = true
                                }
                            }
                        }
                        index += 1
                    }
                } else {
                    guard let clusters = self.clusters[clusterLevel] else { return }
                    for cluster in clusters {
                        if self.isContainMap(coord: cluster.marker.position) {
                            if cluster.sum > 0 {
                                cluster.marker.mapView = self.mapView
//                                cluster.marker.hidden = false
                            }
                        } else {
                            cluster.marker.mapView = nil
//                            cluster.marker.hidden = true
                        }
                    }
                }
                
                self.currentClusterLv = clusterLevel
            }
        }
    }
    /*
    func clustering(filter: ChargerFilter, loadedCharger: Bool) {

        DispatchQueue.global(qos: .background).async {
            
            let stationList = ChargerManager.sharedInstance.getChargerStationInfoList()
            
            if !filter.isSame(filter: self.clusterFilter) {
                if(stationList.count < 1) {
                    return
                }
                self.calClustering(filter: filter)
            }
            DispatchQueue.main.async {
                var clusterLv = ClusterManager.CLUSTER_LEVEL_0
                if self.isNeedChangeText {
//                    self.setClusterText()
                    self.isNeedChangeText = false
                }
                
                if self.isClustering {
                    if let zoomLev = self.tMapView?.getZoomLevel() {
                        if zoomLev < ClusterManager.LEVEL_3_ZOOM {
                            clusterLv = ClusterManager.CLUSTER_LEVEL_4
                        } else if zoomLev < ClusterManager.LEVEL_2_ZOOM {
                            clusterLv = ClusterManager.CLUSTER_LEVEL_3
                        } else if zoomLev < ClusterManager.LEVEL_1_ZOOM {
                            clusterLv = ClusterManager.CLUSTER_LEVEL_2
                        }
//                        else if zoomLev < 13 {
//                            clusterLv = ClusterManager.CLUSTER_LEVEL_1
//                        }
                    }
                }
                
//                for station in stationList {
//                    station.mapMarker.mapView = self.mapView
//                }
                
                // 클러스터 레벨 변경시 마커를 지우는 루틴
                if (self.currentClusterLv != clusterLv && self.currentClusterLv != -1) {
                    if self.currentClusterLv > ClusterManager.CLUSTER_LEVEL_0 {
                        if let clusters = self.clusters[self.currentClusterLv] {
                            for cluster in clusters {
                                if self.tMapView!.getMarketItem(fromID: cluster.marker.getID()) != nil {
                                    self.tMapView!.getMarketItem(fromID: cluster.marker.getID()).setVisible(false)
                                }
                            }
                        }
                    } else if self.currentClusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                        for charger in stationList {
                            if self.tMapView!.getMarketItem(fromID: charger.mChargerId) != nil {
                                self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(false)
                            }
                        }
                    }
                }

                // 클러스터 변경시 선택된 마커로 그려주는 루틴: 충전소 수가 0으로 변화할 경우 마커를 지우기 위해 필요
                if clusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                    var index = 0
                    let markerThreshold = self.getMarkerThreshold(filter: filter)
                    for charger in stationList {
                        if (index % markerThreshold == 0) {
                            if charger.isAroundPath && charger.check(filter: filter) {
                                if self.isContainMap(point: charger.marker.getTMapPoint()) {
                                    if self.tMapView!.getMarketItem(fromID: charger.mChargerId) == nil {
                                        self.tMapView!.addTMapMarkerItemID(charger.mChargerId, marker: charger.marker, animated: true)
                                    } else {
                                        self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(true)
                                    }
                                }
                            } else {
                                if self.tMapView!.getMarketItem(fromID: charger.mChargerId) != nil {
                                    self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(false)
                                }
                            }
                        } else {
                            if self.tMapView!.getMarketItem(fromID: charger.mChargerId) != nil {
                                self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(false)
                            }
                        }
                        index += 1
                    }
                } else {
                    if let clusters = self.clusters[clusterLv] {
                        for cluster in clusters{
                            if self.isContainMap(point: cluster.marker.getTMapPoint()) {
                                if cluster.sum > 0 {
                                    if self.tMapView!.getMarketItem(fromID: cluster.marker.getID()) == nil {
                                        self.tMapView!.addTMapMarkerItemID(cluster.marker.getID(), marker: cluster.marker, animated: true)
                                    } else {
                                        self.tMapView!.getMarketItem(fromID: cluster.marker.getID()).setVisible(true)
                                    }
                                } else {
                                    if self.tMapView!.getMarketItem(fromID: cluster.marker.getID()) != nil {
                                        self.tMapView!.getMarketItem(fromID: cluster.marker.getID()).setVisible(false)
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.currentClusterLv = clusterLv
            }
        }
    }
    */
    
    // 지도 축소 시 마커를 모두 그리면 메모리 이슈로 앱이 종료됨
    // 한 화면에 일정 갯수 이상의 마커가 있고 줌 레벨이 설정값 이하인 경우,
    // 마커를 모두 그리지 않고 threshold 갯수만큼 건너띄면서 그림
    
    func getMarkerThreshold(filter: ChargerFilter) -> Int {
        var markerThreshold = 1
        guard !isRouteMode else { return markerThreshold }
        
        var markerCount = 0
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
            if charger.check(filter: filter) {
                if self.isContainMap(coord: charger.mapMarker.position) {
                    markerCount += 1
                }
            }
        }
        
        if markerCount > 1000 {
            guard let zoomLevelDouble = self.mapView?.zoomLevel else { return markerThreshold }
            let zoomLevel = Int(zoomLevelDouble)
            
            if zoomLevel < 13 {
                markerThreshold = (markerCount >> 9)
            }
        }
        
        return markerThreshold
    }
    /*
    func getMarkerThreshold(filter: ChargerFilter) -> Int {
        var markerThreshold = 1
        if !isRouteMode {
            var markerCount = 0
            for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
                if charger.check(filter: filter) {
                    if self.isContainMap(point: charger.marker.getTMapPoint()) {
                        markerCount += 1
                    }
                }
            }
            if (markerCount > 1000) {
                if let zoomLev = self.tMapView?.getZoomLevel() {
                    if (zoomLev < 13) {
                        markerThreshold = (markerCount >> 9)
                    }
                }
            }
        }
        return markerThreshold
    }
    */
    func isContainMap(coord: NMGLatLng) -> Bool {
        guard let mapView = mapView else {
            return false
        }
        
        return mapView.contentBounds.hasPoint(coord)
    }
    
    /*
    func isContainMap(point: TMapPoint) -> Bool {
        var isContain = false;
        if (tMapView!.getRightBottomPoint().getLatitude() <= point.getLatitude()
            && point.getLatitude() <= tMapView!.getLeftTopPoint().getLatitude()
            && point.getLongitude() <= tMapView!.getRightBottomPoint().getLongitude()
            && tMapView!.getLeftTopPoint().getLongitude() <= point.getLongitude()) {
            isContain = true;
        }
        return isContain
    }
    */
    
    func removeChargeForClustering(zoomLevel: Int) {
        if zoomLevel < 13 {
            for station in ChargerManager.sharedInstance.getChargerStationInfoList() {
                station.mapMarker.mapView = nil
            }
        }
    }
    
    /*
    func removeChargerForClustering(zoomLevel: Int) {
        if zoomLevel < 13 {
            for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
                if self.tMapView!.getMarketItem(fromID: charger.mChargerId) != nil {
                    self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(false)
                }
            }
        }
    }
     */
    
    func removeClusterFromSettings() {
        guard let clusters = self.clusters[self.currentClusterLv] else {
            return
        }
        
        for cluster in clusters {
            cluster.marker.mapView = nil
        }
    }
    
    /*
    func removeClusterFromSettings() {
        if let clusters = self.clusters[self.currentClusterLv] {
            for cluster in clusters {
                if (self.tMapView!.getMarketItem(fromID: cluster.marker.getID()) != nil) {
                    self.tMapView!.getMarketItem(fromID: cluster.marker.getID()).setVisible(false)
                }
            }
        }
    }
    */
}
