//
//  LocationWorker.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxCoreLocation
import RxSwift

typealias Location = (latitude: String, longitude: String)

internal enum LocationError: Error {
    case errorFetch(String)
}

extension LocationWorker {
    internal func fetchLocation() {
        self.locationManager.startUpdatingLocation()
    }
}

internal final class LocationWorker: NSObject {
    internal static let shared = LocationWorker()

    internal let locationStatusObservable = BehaviorSubject<CLAuthorizationStatus>(value: .notDetermined)
    internal let locationObservable = PublishSubject<Result<Location, LocationError>>()

    internal var locationStatus: CLAuthorizationStatus?

    private let locationManager: CLLocationManager
    private let disposeBag = DisposeBag()

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    override private init() {
        self.locationManager = {
            $0.desiredAccuracy = kCLLocationAccuracyBest
//            $0.requestWhenInUseAuthorization()
            $0.requestAlwaysAuthorization()
            return $0
        }(CLLocationManager())
        super.init()

        self.locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { [weak self] _, status in
                guard let self = self else { return }
                switch status {
                case .denied:
                    printLog(out: "Authorization denied")
                case .notDetermined:
                    printLog(out: "Authorization: not determined")
                case .restricted:
                    printLog(out: "Authorization: restricted")
                case .authorizedAlways, .authorizedWhenInUse:
                    printLog(out: "All good fire request")
                @unknown default:
                    fatalError()
                }
                self.locationStatus = status
                self.locationStatusObservable.onNext(status)
            })
            .disposed(by: self.disposeBag)

        self.locationManager.rx.location
            .filterNil()
            .subscribe(onNext: { [weak self] location in
                guard let self = self else { return }
                self.locationManager.stopUpdatingLocation()
                printLog(out: "\nlatitude: \(location.coordinate.latitude)\nlongitude: \(location.coordinate.longitude)\naltitude: \(location.altitude)")
                let _location = (latitude: "\(location.coordinate.latitude)", longitude: "\(location.coordinate.longitude)")
                self.locationObservable.onNext(Result.success(_location))
            })
            .disposed(by: self.disposeBag)

        self.locationManager.rx.didError
            .subscribe { [weak self] event in
                guard let self = self else { return }
                event.element?.manager.stopUpdatingLocation()
                let error = LocationError.errorFetch("\(event.error.debugDescription)")
                self.locationObservable.onNext(Result.failure(error))
            }
            .disposed(by: self.disposeBag)
    }
}
