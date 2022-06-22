//
//  RouteView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/05/26.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol DelegateFindRouteView {
    func updateView(isShow: Bool)
    func removeViaRoute()
    func removeDestinationRoute()
    func swapLocation(route1: RoutePosition, route2: RoutePosition)
}

internal class RouteView: UIView {
    // swap button
    @IBOutlet var swapStartWithViaOrEndButton: UIButton!
    @IBOutlet var swapViaWithEndButton: UIButton!
    
    // position button
    @IBOutlet var findStartLocationButton: UIButton!
    @IBOutlet var findViaLocationButton: UIButton!
    @IBOutlet var findDestinationLocationButton: UIButton!
    
    // round view
    @IBOutlet var addViaRoundView: UIView!
    @IBOutlet var removeViaRoundView: UIView!
    @IBOutlet var removeDestinationRoundView: UIView!
    
    // add/remove button
    @IBOutlet var addViaButton: UIButton!
    @IBOutlet var removeViaButton: UIButton!
    @IBOutlet var removeDestinationButton: UIButton!
    
    // clear button
    @IBOutlet var clearRouteViewButton: UIButton!
    
    internal var delegate: DelegateFindRouteView?
    internal var isShow: Bool = false
    private var isContainsViaMode: Bool = false
    private let disposeBag = DisposeBag()
    
    private enum PlaceHolder: String {
        case startLabel = "출발지"
        case viaLabel = "경유지를 입력하세요."
        case destinationLabel = "도착지를 입력하세요."
    }
    
    internal enum Height: CGFloat {
        case normal
        case expand
        
        var value: CGFloat {
            switch self {
            case .normal: return 124
            case .expand: return 160
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        registNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        registNotification()
    }
    
    private func commonInit() {
        guard let view = Bundle.main.loadNibNamed("RouteView", owner: self, options: nil)?.first as? UIView else { return }
        view.frame = bounds
        addSubview(view)
        
        setCornerRoundView()
        clearView()
        bind()
    }
    
    private func bind() {
        swapStartWithViaOrEndButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard self.isContainsViaMode else {
                    let tempLabelText = self.findDestinationLocationButton.titleLabel?.text ?? ""
                    self.findDestinationLocationButton.setTitle(self.findStartLocationButton.titleLabel?.text ?? "", for: .normal)
                    self.findStartLocationButton.setTitle(tempLabelText, for: .normal)
                    self.delegate?.swapLocation(route1: .start, route2: .end)
                    return
                }

                let tempLabelText = self.findViaLocationButton.titleLabel?.text ?? ""
                self.findViaLocationButton.setTitle(self.findStartLocationButton.titleLabel?.text ?? "", for: .normal)
                self.findStartLocationButton.setTitle(tempLabelText, for: .normal)
                self.delegate?.swapLocation(route1: .start, route2: .mid)
            }).disposed(by: disposeBag)
        
        swapViaWithEndButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                let tempLabelText = self.findDestinationLocationButton.titleLabel?.text ?? ""
                self.findDestinationLocationButton.setTitle(self.findViaLocationButton.titleLabel?.text ?? "", for: .normal)
                self.findViaLocationButton.setTitle(tempLabelText, for: .normal)
                self.delegate?.swapLocation(route1: .mid, route2: .end)
            }).disposed(by: disposeBag)
        
        findStartLocationButton.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                let searchViewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(ofType: SearchViewController.self)
                searchViewController.routeType = .start
                GlobalDefine.shared.mainNavi?.present(AppSearchBarController(rootViewController: searchViewController), animated: true)
            }).disposed(by: disposeBag)
        
        findViaLocationButton.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                let searchViewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(ofType: SearchViewController.self)
                searchViewController.routeType = .mid
                GlobalDefine.shared.mainNavi?.present(AppSearchBarController(rootViewController: searchViewController), animated: true)
            }).disposed(by: disposeBag)
        
        findDestinationLocationButton.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                let searchViewController = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(ofType: SearchViewController.self)
                searchViewController.routeType = .end
                GlobalDefine.shared.mainNavi?.present(AppSearchBarController(rootViewController: searchViewController), animated: true)
            }).disposed(by: disposeBag)
        
        addViaButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.addViaView()
            }).disposed(by: disposeBag)
        
        removeViaButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.isContainsViaMode = false
                self.clearView()
                self.delegate?.updateView(isShow: false)
                self.delegate?.removeViaRoute()
                
                self.findViaLocationButton.setTitle(PlaceHolder.viaLabel.rawValue, for: .normal)
            }).disposed(by: disposeBag)
        
        removeDestinationButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                defer {
                    self.isContainsViaMode = false
                    self.clearView()
                    self.delegate?.updateView(isShow: false)
                    self.delegate?.removeDestinationRoute()
                }
                guard let newDestination = self.findViaLocationButton.titleLabel?.text,
                        !newDestination.elementsEqual(PlaceHolder.viaLabel.rawValue) else {
                    self.findDestinationLocationButton.setTitle(PlaceHolder.destinationLabel.rawValue, for: .normal)
                    return
                }
                
                self.findDestinationLocationButton.setTitle(newDestination, for: .normal)
            }).disposed(by: disposeBag)
        
        clearRouteViewButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.isContainsViaMode = false
                self.clearView()
                self.clearButtonTitle()
                self.delegate?.updateView(isShow: false)
            }).disposed(by: disposeBag)
    }
    
    private func setCornerRoundView() {
        addViaRoundView.layer.cornerRadius = addViaRoundView.frame.width / 2
        removeViaRoundView.layer.cornerRadius = removeViaRoundView.frame.width / 2
        removeDestinationRoundView.layer.cornerRadius = removeDestinationRoundView.frame.width / 2
    }
    
    internal func addViaView() {
        addViaButton.isHidden = true
        addViaRoundView.isHidden = true
        removeViaButton.isHidden = false
        removeViaRoundView.isHidden = false
        removeDestinationButton.isHidden = false
        removeDestinationRoundView.isHidden = false
        findViaLocationButton.isHidden = false
        swapViaWithEndButton.isHidden = false
        isContainsViaMode = true
        
        delegate?.updateView(isShow: true)
    }
    
    internal func clearView() {
        addViaButton.isHidden = false
        addViaRoundView.isHidden = false
        removeViaButton.isHidden = true
        removeViaRoundView.isHidden = true
        removeDestinationButton.isHidden = true
        removeDestinationRoundView.isHidden = true
        findViaLocationButton.isHidden = true
        swapViaWithEndButton.isHidden = true
        isContainsViaMode = false
    }
    
    internal func clearButtonTitle() {
        findViaLocationButton.setTitle(PlaceHolder.viaLabel.rawValue, for: .normal)
        findDestinationLocationButton.setTitle(PlaceHolder.destinationLabel.rawValue, for: .normal)
    }
}

// MARK: RouteView Notification
extension RouteView {
    private func registNotification() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(setChargerToStartLabel(_:)), name: Notification.Name(rawValue: "startMarker"), object: nil)
        center.addObserver(self, selector: #selector(setChargerToViaLabel(_:)), name: Notification.Name(rawValue: "viaMarker"), object: nil)
        center.addObserver(self, selector: #selector(setChargerToDestinationLabel(_:)), name: Notification.Name(rawValue: "destinationMarker"), object: nil)
    }
    
    @objc func setChargerToStartLabel(_ notification: NSNotification) {
        guard let charger = notification.object as? ChargerStationInfo else { return }
        findStartLocationButton.setTitle(charger.mStationInfoDto?.mSnm ?? "", for: .normal)
    }
    
    @objc func setChargerToViaLabel(_ notification: NSNotification) {
        guard let charger = notification.object as? ChargerStationInfo else { return }
        findViaLocationButton.setTitle(charger.mStationInfoDto?.mSnm ?? "", for: .normal)
    }
    
    @objc func setChargerToDestinationLabel(_ notification: NSNotification) {
        guard let charger = notification.object as? ChargerStationInfo else { return }
        findDestinationLocationButton.setTitle(charger.mStationInfoDto?.mSnm ?? "", for: .normal)
    }
}
