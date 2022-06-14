//
//  Clustering.swift
//  evInfra
//
//  Created by bulacode on 13/12/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import Foundation
import NMapsMap

internal final class ClusterManager {
    private enum Level {
        case zoom0
        case zoom1
        case zoom2
        case zoom3
        
        var value: Int {
            switch self {
            case .zoom0: return 13
            case .zoom1: return 11
            case .zoom2: return 8
            case .zoom3: return 6
            }
        }
    }
    
    private enum Cluster {
        case Level0 // 일반
        case Level1 // 구
        case Level2 // 시군 (7대 도시는 구)
        case Level3 // 도
        case Level4 // 내륙 제주
        
        var value: Int {
            switch self {
            case .Level0: return 0
            case .Level1: return 1
            case .Level2: return 2
            case .Level3: return 3
            case .Level4: return 4
            }
        }
    }
    
    private let headers = ["charger0", "cluster1", "cluster2", "cluster3", "cluster4"] // 클러스터링 에셋 파일명
    private static let MARKER_THRESHOLD_SIZE = 2
    private static let MAX_ZOOM_LEVEL = 9
    
    internal var isClustering: Bool = false
    internal var mapView: NMFMapView?
    internal var isRouteMode: Bool = false
    private var clusters = [[CodableCluster.Cluster]?]()
    private var isNeedChangeText: Bool = false
    private var clusterFilter: ChargerFilter? = nil
    private var currentClusterLv: Int = -1
    private var clusterGenerator = ClusterGenerator()
    
    init(mapView: NMFMapView) {
        self.mapView = mapView
        prepareClusterInfo()
        prepareClusterMarker()
    }
        
    private func prepareClusterInfo() {
        for assetFile in headers {
            if let asset = NSDataAsset(name: assetFile, bundle: Bundle.main) {
                let json = try! JSONDecoder().decode(CodableCluster.self, from: asset.data)
                clusters.append(json.lists)
            } else {
                clusters.append(nil)
            }
        }
    }
    
    private func prepareClusterMarker() {
        prepareMarkers(clusters: self.clusters[Cluster.Level1.value], markerHeader: headers[Cluster.Level1.value])
        prepareMarkers(clusters: self.clusters[Cluster.Level2.value], markerHeader: headers[Cluster.Level2.value])
        prepareMarkers(clusters: self.clusters[Cluster.Level3.value], markerHeader: headers[Cluster.Level3.value])
        prepareMarkers(clusters: self.clusters[Cluster.Level4.value], markerHeader: headers[Cluster.Level4.value])
    }
    
    private func prepareMarkers(clusters: [CodableCluster.Cluster]?, markerHeader: String) {
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
    
    private func calClustering(filter: ChargerFilter) {
        if let baseClusters = self.clusters[Cluster.Level1.value] {
            for baseCluster in baseClusters {
                baseCluster.initSum()
                self.clusters[Cluster.Level2.value]?[baseCluster.cl2_id! - 1].initSum()
                self.clusters[Cluster.Level3.value]?[baseCluster.cl1_id! - 1].initSum()
            }
            self.clusters[Cluster.Level4.value]?[0].initSum()
            self.clusters[Cluster.Level4.value]?[1].initSum()
        }
        
        for charger in ChargerManager.sharedInstance.getChargerStationInfoList() {
            if charger.isAroundPath && charger.check(filter: filter) {
                guard let mArea = charger.mStationInfoDto?.mArea else { return }
                
                if mArea > 0 {
                    guard let cluster = self.clusters[Cluster.Level1.value]?[mArea - 1] else { return }
                    
                    self.clusters[Cluster.Level1.value]?[mArea - 1].addVal()
                    self.clusters[Cluster.Level2.value]?[cluster.cl2_id! - 1].addVal()
                    self.clusters[Cluster.Level3.value]?[cluster.cl1_id! - 1].addVal()
                    
                    // 248:제주시 249:서귀포시
                    if (mArea == 248 || mArea == 249) {
                        self.clusters[Cluster.Level4.value]?[1].addVal()
                    } else {
                        self.clusters[Cluster.Level4.value]?[0].addVal()
                    }
                }
            }
        }
        
        self.clusterFilter = filter.copy()
        isNeedChangeText = true
    }
    
    // MARK: 클러스터에 충전소 갯수 세팅
    private func setCountOfStationInCluster() {
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
    internal func clustering(filter: ChargerFilter, loadedCharger: Bool) {
        guard let zoomLevelDouble = self.mapView?.zoomLevel as? Double else { return }
        let zoomLevel = Int(zoomLevelDouble)
        let stations = ChargerManager.sharedInstance.getChargerStationInfoList()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            var clusterLevel = Cluster.Level0.value
            if self.isClustering {
                // zoom level에 따른 클러스터링 레벨 설정
                if zoomLevel < Level.zoom3.value {
                    clusterLevel = Cluster.Level4.value
                } else if zoomLevel < Level.zoom2.value {
                    clusterLevel = Cluster.Level3.value
                } else if zoomLevel < Level.zoom1.value {
                    clusterLevel = Cluster.Level2.value
                }
            }

            DispatchQueue.main.async { 
                if (self.currentClusterLv != clusterLevel) {
                    if self.currentClusterLv > Cluster.Level0.value {
                        self.removeAllCluster()
                    } else if self.currentClusterLv == Cluster.Level0.value {
                        self.removeAllMarker()
                    }
                }
                self.currentClusterLv = clusterLevel
                    
                // 클러스터링 안할때
                if clusterLevel == Cluster.Level0.value {
                    var visibleCharger = [ChargerStationInfo]()
                    var invisibleCharger = [ChargerStationInfo]()
                    
                    for station in stations {
                        if station.isAroundPath && station.check(filter: filter) && self.isContainMap(coord: station.mapMarker.position) {
                            visibleCharger.append(station)
                        } else {
                            invisibleCharger.append(station)
                        }
                    }
                    
                    let markerThreshold = self.getMarkerThreshold(filter: filter, stations: visibleCharger)
                    
                    for (index, charger) in visibleCharger.enumerated() where markerThreshold != 0 {
                        if (index % markerThreshold == 0) {
                            charger.mapMarker.mapView = self.mapView
                        }
                    }
                    
                    invisibleCharger.forEach {
                        $0.mapMarker.mapView = nil
                    }
                } else {
                    // 클러스터링 할때
                    guard let clusters = self.clusters[clusterLevel] else { return }
                    
                    if (stations.count > 0) {
                        self.calClustering(filter: filter)
                        self.setCountOfStationInCluster()
                    }
                    
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
    
    // MARK: 마커 Threshold 로직
    // 지도 축소 시 마커를 모두 그리면 메모리 이슈로 앱이 종료됨
    // 한 화면에 일정 갯수 이상의 마커가 있고 줌 레벨이 설정값 이하인 경우,
    // 마커를 모두 그리지 않고 threshold 갯수만큼 건너띄면서 그림
    private func getMarkerThreshold(filter: ChargerFilter, stations: [ChargerStationInfo]) -> Int {
        guard !isRouteMode else { return 1 }
        guard stations.count > 500 else { return 1 }
        guard let mapView = mapView else { return 1 }
        
        let markerCount = stations.count
        let zoomLevel = Int(mapView.zoomLevel)

        return zoomLevel < Level.zoom0.value ? (markerCount >> 9) : (markerCount << 9)
    }
   
    internal func removeClusterFromSettings() {
        guard currentClusterLv != -1, let _ = self.clusters[currentClusterLv] else {
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
}
