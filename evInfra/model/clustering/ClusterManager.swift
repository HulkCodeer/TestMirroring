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
    
    init(mapView: NMFMapView) {
        self.mapView = mapView
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
        guard let clusters = clusters else { return }
        
        for cluster in clusters {
            if cluster.baseImage == nil {
                cluster.baseImage = self.clusterGenerator.generateBaseImage(area: cluster.name ?? "")
            }
            
            let latLng = NMGLatLng(lat: cluster.lat ?? 0.0, lng: cluster.lng ?? 0.0)
            let marker = Marker(position: latLng)
            
            let clusterImage = self.clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!)
            marker.iconImage = NMFOverlayImage(image: clusterImage!)
            cluster.marker = marker
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
        isNeedChangeText = true
    }
    
    // MARK: 클러스터에 충전소 갯수 세팅
    func setCountOfStationInCluster() {
        for clusters in self.clusters {
            if let clusterXs = clusters {
                for cluster in clusterXs {
                    let clusterImage = clusterGenerator.generateClusterImage(value: String(cluster.sum), baseImage: cluster.baseImage!)
                    cluster.marker.iconImage = NMFOverlayImage(image: clusterImage!)
                }
            }
        }
    }

    // MARK: 클러스터링 생성 로직
    func clustering(filter: ChargerFilter, loadedCharger: Bool) {
        guard let zoomLevelDouble = self.mapView?.zoomLevel as? Double else { return }
        let zoomLevel = Int(zoomLevelDouble)
        let stations = ChargerManager.sharedInstance.getChargerStationInfoList()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            var clusterLevel = ClusterManager.CLUSTER_LEVEL_0
            
            // zoom level에 따른 클러스터링 레벨 설정
            if zoomLevel < ClusterManager.LEVEL_3_ZOOM {
                clusterLevel = ClusterManager.CLUSTER_LEVEL_4
            } else if zoomLevel < ClusterManager.LEVEL_2_ZOOM {
                clusterLevel = ClusterManager.CLUSTER_LEVEL_3
            } else if zoomLevel < ClusterManager.LEVEL_1_ZOOM {
                clusterLevel = ClusterManager.CLUSTER_LEVEL_2
            }
            
            DispatchQueue.main.async {
                if (self.currentClusterLv != clusterLevel) {
                    if self.currentClusterLv > ClusterManager.CLUSTER_LEVEL_0 {
                        self.removeAllCluster()
                    } else if self.currentClusterLv == ClusterManager.CLUSTER_LEVEL_0 {
                        self.removeAllMarker()
                    }
                }
                self.currentClusterLv = clusterLevel
                    
                // 클러스터링 안할때
                if clusterLevel == ClusterManager.CLUSTER_LEVEL_0 {
                    
                    var visibleCharger = [ChargerStationInfo]()
                    for station in stations {
                        if station.isAroundPath && station.check(filter: filter) && self.isContainMap(coord: station.mapMarker.position) {
                            visibleCharger.append(station)
                        }
                    }
                    
                    for charger in visibleCharger {
                        charger.mapMarker.mapView = self.mapView
                    }
                } else {
                    // 클러스터링 할때
                    if (stations.count > 0) {
                        self.calClustering(filter: filter)
                        self.setCountOfStationInCluster()
                    }
                    
                    if let clusters = self.clusters[clusterLevel] {
                        for cluster in clusters {
                            if self.isContainMap(coord: cluster.marker.position) {
                                if cluster.sum > 0 {
                                    cluster.marker.mapView = self.mapView
                                }
                            } else {
                                cluster.marker.mapView = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: 마커 Threshold 로직
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
   
    func removeClusterFromSettings() {
        guard let _ = self.clusters[self.currentClusterLv] else {
            removeAllMarker()
            return
        }
        removeAllCluster()
    }
    
    private func isContainMap(coord: NMGLatLng) -> Bool {
        guard let mapView = mapView else {
            return false
        }
        
        return mapView.contentBounds.hasPoint(coord)
    }
    
    private func removeAllMarker() {
        for station in ChargerManager.sharedInstance.getChargerStationInfoList() {
            station.mapMarker.mapView = nil
        }
    }
    
    private func removeAllCluster() {
        if let clusters = self.clusters[self.currentClusterLv] {
            for cluster in clusters {
                cluster.marker.mapView = nil
            }
        }
    }
    
    func removeChargerForClustering(zoomLevel: Int) {
        if zoomLevel < 13 {
            removeAllMarker()
        }
    }
}
