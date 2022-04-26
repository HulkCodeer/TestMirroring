//
//  Clustering.swift
//  evInfra
//
//  Created by bulacode on 13/12/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation

class ClusterManager {
    
    public static let LEVEL_1_ZOOM = 11;
    public static let LEVEL_2_ZOOM = 8;
    public static let LEVEL_3_ZOOM = 6;
    
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

    var clusterFilter: ChargerFilter? = nil
    var currentClusterLv = -1
    var tMapView: TMapView?
    var isRouteMode: Bool = false
    
    var clusterGenerator = ClusterGenerator.init()
    
    init(mapView: TMapView) {
        self.tMapView = mapView
        prepareClusterInfo()
        prepareClusterMarker()
    }
    
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
    }
    
    func setClusterText() {
        for clusters in self.clusters {
            if let clusterXs = clusters {
                for cluster in clusterXs {
                    cluster.marker.setIcon(clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!))
                }
            }
        }
    }
    
    func clustering(filter: ChargerFilter, loadedCharger: Bool) {
        
        NSLog("parkshin start")

        DispatchQueue.global(qos: .background).async {
            NSLog("parkshin start thread")
            
            let stationList = ChargerManager.sharedInstance.getChargerStationInfoList()
            
            // 필터가 변한 경우 클러스터 숫자 재계산
            if !filter.isSame(filter: self.clusterFilter) {
                if (stationList.count > 0) {
                    self.calClustering(filter: filter)
                    
                    DispatchQueue.main.async {
                        self.setClusterText()
                    }
                }
            }

            var clusterLv = ClusterManager.CLUSTER_LEVEL_0
            if self.isClustering {
                if let zoomLev = self.tMapView?.getZoomLevel() {
                    if zoomLev < ClusterManager.LEVEL_3_ZOOM {
                        clusterLv = ClusterManager.CLUSTER_LEVEL_4
                    } else if zoomLev < ClusterManager.LEVEL_2_ZOOM {
                        clusterLv = ClusterManager.CLUSTER_LEVEL_3
                    } else if zoomLev < ClusterManager.LEVEL_1_ZOOM {
                        clusterLv = ClusterManager.CLUSTER_LEVEL_2
                    } else if zoomLev < 14 {
                        clusterLv = ClusterManager.CLUSTER_LEVEL_1
                    }
                }
            }
            
            NSLog("parkshin 1")

            // 클러스터 레벨 변경시 기존 레벨의 마커를 모두 삭제
            DispatchQueue.main.async {
                NSLog("parkshin 2")
                if (self.currentClusterLv != clusterLv) {
                    if self.currentClusterLv > ClusterManager.CLUSTER_LEVEL_0 {
                        self.removeAllCluster()
                    } else if self.currentClusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                        self.removeAllMarker()
                    }
                }
                self.currentClusterLv = clusterLv
                NSLog("parkshin 3")
                // add marker
                if clusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                    var visibleCharger = [ChargerStationInfo]()
                    for charger in stationList {
                        if charger.isAroundPath
                            && charger.check(filter: filter)
                            && self.isContainMap(point: charger.marker.getTMapPoint()) {
                            visibleCharger.append(charger)
                        } else {
                            if self.tMapView!.getMarketItem(fromID: charger.marker.getID()) != nil {
                                self.tMapView!.getMarketItem(fromID: charger.marker.getID()).setVisible(false)
                            }
                        }
                    }
                    NSLog("parkshin 4")
                    // 지도 축소 시 마커를 모두 그리면 메모리 이슈로 앱이 종료됨
                    // 한 화면에 일정 갯수 이상의 마커가 있고 줌 레벨이 설정값 이하인 경우,
                    // 마커를 모두 그리지 않고 threshold 갯수만큼 건너띄면서 그림
                    var markerThreshold = 1
                    if !self.isRouteMode {
                        if (visibleCharger.count > 1000) {
                            if let zoomLevel = self.tMapView?.getZoomLevel() {
                                if (zoomLevel < 13) {
                                    markerThreshold = (visibleCharger.count >> 9)
                                }
                            }
                        }
                    }

                    NSLog("parkshin 5 count: \(visibleCharger.count), thres hold: \(markerThreshold)")
                    var index = 0
                    for charger in visibleCharger {
                        if (index % markerThreshold == 0) {
                            if self.tMapView!.getMarketItem(fromID: charger.mChargerId) == nil {
                                self.tMapView!.addTMapMarkerItemID(charger.mChargerId, marker: charger.marker, animated: true)
                            } else {
                                self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(true)
                            }
                        }
                        index += 1
                    }
                    NSLog("parkshin 6")
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
            }
        }
    }
    
    func isContainMap(point: TMapPoint) -> Bool {
        if (tMapView!.getRightBottomPoint().getLatitude() <= point.getLatitude()
            && point.getLatitude() <= tMapView!.getLeftTopPoint().getLatitude()
            && point.getLongitude() <= tMapView!.getRightBottomPoint().getLongitude()
            && tMapView!.getLeftTopPoint().getLongitude() <= point.getLongitude()) {
            return true;
        }
        return false
    }
    
    func removeClusterFromSettings() {
        if let clusters = self.clusters[self.currentClusterLv] {
            for cluster in clusters {
                if (self.tMapView!.getMarketItem(fromID: cluster.marker.getID()) != nil) {
                    self.tMapView!.getMarketItem(fromID: cluster.marker.getID()).setVisible(false)
                }
            }
        }
    }

    func removeChargerForClustering(zoomLevel: Int) {
        if zoomLevel < 13 {
            self.removeAllMarker()
        }
    }
    
    private func removeAllMarker() {
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
            if self.tMapView!.getMarketItem(fromID: charger.mChargerId) != nil {
                self.tMapView!.getMarketItem(fromID: charger.mChargerId).setVisible(false)
            }
        }
    }
    
    private func removeAllCluster() {
        if let clusters = self.clusters[self.currentClusterLv] {
            for cluster in clusters {
                if self.tMapView!.getMarketItem(fromID: cluster.marker.getID()) != nil {
                    self.tMapView!.getMarketItem(fromID: cluster.marker.getID()).setVisible(false)
                }
            }
        }
    }
}
