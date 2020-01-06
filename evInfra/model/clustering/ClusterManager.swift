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
    var isNeedChangeText: Bool = false
    var clusterFilter: ChargerFilter? = nil
    var chargerManager = ChargerListManager.sharedInstance
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
        
        for charger in self.chargerManager.chargerDict {
            if charger.value.isAroundPath && charger.value.check(filter: filter) {
                if charger.value.area > 0 {
                    if let cluster = self.clusters[ClusterManager.CLUSTER_LEVEL_1]?[charger.value.area - 1] {
                        self.clusters[ClusterManager.CLUSTER_LEVEL_1]?[charger.value.area - 1].addVal()
                        self.clusters[ClusterManager.CLUSTER_LEVEL_2]?[cluster.cl2_id! - 1].addVal()
                        self.clusters[ClusterManager.CLUSTER_LEVEL_3]?[cluster.cl1_id! - 1].addVal()
                        
                        // 248:제주시 249:서귀포시
                        if (charger.value.area == 248 || charger.value.area == 249) {
                            self.clusters[ClusterManager.CLUSTER_LEVEL_4]?[1].addVal()
                        } else {
                            self.clusters[ClusterManager.CLUSTER_LEVEL_4]?[0].addVal()
                        }
                    }
                }
            }
        }
        self.clusterFilter = filter
        isNeedChangeText = true
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

        DispatchQueue.global(qos: .background).async {
            if !filter.isSame(filter: self.clusterFilter) {
                if(self.chargerManager.chargerDict.count < 1) {
                    return
                }
                self.calClustering(filter: filter)
            }
            
            DispatchQueue.main.async {
                var clusterLv = ClusterManager.CLUSTER_LEVEL_0
                if self.isNeedChangeText {
                    self.setClusterText()
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
                        for charger in self.chargerManager.chargerDict {
                            if self.tMapView!.getMarketItem(fromID: charger.value.chargerId) != nil {
                                self.tMapView!.getMarketItem(fromID: charger.value.chargerId).setVisible(false)
                            }
                        }
                    }
                }
                
                // 클러스터 변경시 선택된 마커로 그려주는 루틴: 충전소 수가 0으로 변화할 경우 마커를 지우기 위해 필요
                if clusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                    var index = 0
                    let markerThreshold = self.getMarkerThreshold(filter: filter)
                    for charger in self.chargerManager.chargerDict {
                        if(index % markerThreshold == 0){
                            if charger.value.isAroundPath && charger.value.check(filter: filter) {
                                if self.isContainMap(point: charger.value.marker.getTMapPoint()) {
                                    if self.tMapView!.getMarketItem(fromID: charger.value.chargerId) == nil {
                                        self.tMapView!.addTMapMarkerItemID(charger.value.chargerId, marker: charger.value.marker, animated: true)
                                    } else {
                                        self.tMapView!.getMarketItem(fromID: charger.value.chargerId).setVisible(true)
                                    }
                                }
                            } else {
                                if self.tMapView!.getMarketItem(fromID: charger.value.chargerId) != nil {
                                    self.tMapView!.getMarketItem(fromID: charger.value.chargerId).setVisible(false)
                                }
                            }
                        }else {
                            if self.tMapView!.getMarketItem(fromID: charger.value.chargerId) != nil {
                                self.tMapView!.getMarketItem(fromID: charger.value.chargerId).setVisible(false)
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
                self.clusterFilter = filter
                self.currentClusterLv = clusterLv
            }
        }
    }
    
    func getMarkerThreshold(filter: ChargerFilter) -> Int {
        var markerThreshold = 1
        if !isRouteMode{
            var markerCount = 0
            for charger in self.chargerManager.chargerDict {
                if charger.value.check(filter: filter) {
                    if self.isContainMap(point: charger.value.marker.getTMapPoint()) {
                        markerCount += 1
                    }
                }
            }
            if (markerCount > 6000){
                if let zoomLev = self.tMapView?.getZoomLevel() {
                    if (ClusterManager.MAX_ZOOM_LEVEL - zoomLev > 0){
                        markerThreshold = (ClusterManager.MAX_ZOOM_LEVEL - zoomLev) * ClusterManager.MARKER_THRESHOLD_SIZE
                    }
                }
            }
            
        }
        return markerThreshold
    }
    
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
    
    func removeChargerForClustering(zoomLevel: Int) {
        if zoomLevel < 13 {
            for charger in self.chargerManager.chargerDict {
                if self.tMapView!.getMarketItem(fromID: charger.value.chargerId) != nil {
                    self.tMapView!.getMarketItem(fromID: charger.value.chargerId).setVisible(false)
                }
            }
        }
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
}
