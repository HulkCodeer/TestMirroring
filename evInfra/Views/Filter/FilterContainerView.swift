//
//  FilterContainerView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

protocol DelegateFilterContainerView: AnyObject {
    func changedFilter(type: FilterType)    
}

internal final class FilterContainerView: UIView {
    
    // MARK: UI
    
    @IBOutlet var filterContainerView: UIView!
    @IBOutlet var filterTypeView: NewFilterTypeView!
    @IBOutlet var filterSpeedView: NewFilterSpeedView!
    @IBOutlet var filterPriceView: FilterPriceView!
    @IBOutlet var filterRoadView: NewFilterRoadView!
    @IBOutlet var filterPlaceView: NewFilterPlaceView!
    
    // MARK: VARIABLE
    
    internal weak var delegate: DelegateFilterContainerView?
        
    private var disposeBag = DisposeBag()
    private weak var mainReactor: MainReactor?
        
    // MARK: SYSTEM FUNC
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView(){
        let view = Bundle.main.loadNibNamed("FilterContainerView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.filterContainerView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.filterContainerView.addGestureRecognizer(swipeRight)
        
        filterTypeView.saveOnChange = true
        filterSpeedView.saveOnChange = true
        filterRoadView.saveOnChange = true
        filterPlaceView.saveOnChange = true
        filterPriceView.saveOnChange = true
        
//        filterTypeView.delegate = self
//        filterSpeedView.delegate = self
        filterRoadView.delegate = self
        filterPlaceView.delegate = self
        filterPriceView.delegate = self
        
//        filterSpeedView.slowSpeedChangeDelegate = self
//        filterTypeView.slowTypeChangeDelegate = self
    }
    
    // MARK: FUNC
    
    func bind(reactor: MainReactor) {
        self.mainReactor = reactor
        
        filterSpeedView.bind(reactor: GlobalFilterReactor.sharedInstance)
        filterPlaceView.bind(reactor: reactor)
        filterRoadView.bind(reactor: reactor)
        filterTypeView.bind(reactor: reactor)
        
        reactor.state.compactMap { $0.selectedFilterInfo }
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self) { obj, selectedFilterInfo in
                switch selectedFilterInfo?.filterTagType {
                case .speed:
                    obj.filterContainerView.bringSubviewToFront(obj.filterSpeedView)
                case .place:
                    obj.filterContainerView.bringSubviewToFront(obj.filterPlaceView)
                case .road:
                    obj.filterContainerView.bringSubviewToFront(obj.filterRoadView)
                case .type:
                    obj.filterContainerView.bringSubviewToFront(obj.filterTypeView)
                default: break
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            guard let _reactor = self.mainReactor else { return }
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left:
                Observable.just(MainReactor.Action.swipeLeft)
                    .bind(to: _reactor.action)
                    .disposed(by: self.disposeBag)

                case UISwipeGestureRecognizer.Direction.right :
                Observable.just(MainReactor.Action.swipeRight)
                    .bind(to: _reactor.action)
                    .disposed(by: self.disposeBag)
                
                default: break
            }
        }
    }
    
    private func showFilterView(type: FilterType){
        switch type {
        case .price:
            filterContainerView.bringSubviewToFront(filterPriceView!)
        case .speed:
            filterContainerView.bringSubviewToFront(filterSpeedView!)
        case .place:
            filterContainerView.bringSubviewToFront(filterPlaceView!)
        case .road:
            filterContainerView.bringSubviewToFront(filterRoadView!)
        case .type:
            filterContainerView.bringSubviewToFront(filterTypeView!)
        default:
            break;
        }
    }
    
    internal func updateFilters() {
        filterPriceView.update()
//        filterSpeedView.update()
//        filterPlaceView.update()
//        filterRoadView.update()
//        filterTypeView.update()
    }
}

extension FilterContainerView: DelegateFilterChange{
    func onChangedFilter(type: FilterType) {
        delegate?.changedFilter(type: type)
    }
}

extension FilterContainerView : DelegateSlowTypeChange {
    func onChangeSlowType(slowOn: Bool) {
//        filterSpeedView.setSlowOn(slowOn: slowOn)
    }
}

extension FilterContainerView : DelegateSlowSpeedChange {
    func onChangeSlowSpeed(isSlow: Bool) {
//        filterTypeView.setSlowTypeOn(slowTypeOn: isSlow)
    }
}
