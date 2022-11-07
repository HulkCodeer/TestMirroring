//
//  MembershipCardShipmentStatusViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/11/03.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa
import ReactorKit
import SwiftyJSON

internal final class MembershipCardShipmentStatusViewController: UIViewController, StoryboardView {        
    // MARK: UI
    
    private lazy var dimmedViewBtn = UIButton()
            
    private lazy var totalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 0
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
            
    private lazy var shipmentStepView = ShipmentStepView(frame: .zero)    
    private lazy var shipmentInfoView = ShipmentInfoView(frame: .zero)
    
    // MARK: VARIABLE
    
    internal var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
        
    init(reactor: MembershipCardReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = .clear
        
        self.view.addSubview(dimmedViewBtn)
        dimmedViewBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(UIScreen.main.bounds.height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dimmedViewBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    guard let self = self else { return }
                    self.totalStackView.snp.updateConstraints {
                        $0.bottom.equalToSuperview().offset(UIScreen.main.bounds.height)
                    }
                    
                    self.dimmedViewBtn.backgroundColor = Colors.backgroundOverlayDark.color.withAlphaComponent(0.0)
                                                            
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    obj.view.removeFromSuperview()
                    obj.removeFromParent()
                })
            }
            .disposed(by: self.disposeBag)
    }
            
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.totalStackView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(0)
            }
            self.dimmedViewBtn.backgroundColor = Colors.backgroundOverlayDark.color.withAlphaComponent(0.3)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: REACTORKIT
    
    func bind(reactor: MembershipCardReactor) {
        Observable.just(MembershipCardReactor.Action.membershipCardInfo)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.compactMap { $0.membershipCardInfo }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: MembershipCardInfo(JSON.null))
            .drive(with: self) { obj, membershipCardInfo in
                obj.shipmentStepView.bind(model: membershipCardInfo)
                obj.shipmentInfoView.bind(model: membershipCardInfo.destination)
                obj.totalStackView.addArrangedSubview(obj.shipmentStepView)
                obj.totalStackView.addArrangedSubview(obj.shipmentInfoView)                
            }
            .disposed(by: self.disposeBag)
    }
}

