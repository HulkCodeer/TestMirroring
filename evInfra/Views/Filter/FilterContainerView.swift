//
//  FilterContainerView.swift
//  evInfra
//
//  Created by SH on 2021/08/11.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
protocol DelegateFilterContainerView {
    func changedFilter(type: FilterType)
    func swipeFilterTo(type: FilterType)
}

class FilterContainerView: UIView {
    
    @IBOutlet var filterContainerView: UIView!
    @IBOutlet var filterTypeView: FilterTypeView!
    @IBOutlet var filterSpeedView: FilterSpeedView!
    @IBOutlet var filterPriceView: FilterPriceView!
    @IBOutlet var filterRoadView: FilterRoadView!
    @IBOutlet var filterPlaceView: FilterPlaceView!
    
    var delegate: DelegateFilterContainerView?
    var currType: FilterType = FilterType.none
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    func initView(){
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
        
        filterTypeView.delegate = self
        filterSpeedView.delegate = self
        filterRoadView.delegate = self
        filterPlaceView.delegate = self
        filterPriceView.delegate = self
        
        filterSpeedView.slowSpeedChangeDelegate = self
        filterTypeView.slowTypeChangeDelegate = self
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        // 만일 제스쳐가 있다면
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left :
                    swipeLeft()
                case UISwipeGestureRecognizer.Direction.right :
                    swipeRight()
                default:
                    break
            }
        }
    }
    
    func swipeLeft() {
        var newType: FilterType = .none
        switch currType {
        case .price:
            newType = .speed
        case .speed:
            newType = .place
        case .place:
            newType = .road
        case .road:
            newType = .type
        case .type:
            newType = .price
        default:
            break;
        }
        
        showFilterView(type: newType)
        delegate?.swipeFilterTo(type: newType)
    }
    
    func swipeRight() {
        var newType: FilterType = .none
        switch currType {
        case .price:
            newType = .type
        case .speed:
            newType = .price
        case .place:
            newType = .speed
        case .road:
            newType = .place
        case .type:
            newType = .road
        default:
            break;
        }
        
        showFilterView(type: newType)
        delegate?.swipeFilterTo(type: newType)
    }
    
    
    func isSameView(type: FilterType) ->Bool{
        if (currType == type){
            currType = .none
            return true
        }

        return false
    }
    
    func showFilterView(type: FilterType){
        currType = type
        
        switch type {
        case .price:
            filterContainerView.bringSubview(toFront: filterPriceView!)
        case .speed:
            filterContainerView.bringSubview(toFront: filterSpeedView!)
        case .place:
            filterContainerView.bringSubview(toFront: filterPlaceView!)
        case .road:
            filterContainerView.bringSubview(toFront: filterRoadView!)
        case .type:
            filterContainerView.bringSubview(toFront: filterTypeView!)
        default:
            break;
        }
    }
    
    func updateFilters() {
        filterPriceView.update()
        filterSpeedView.update()
        filterPlaceView.update()
        filterRoadView.update()
        filterTypeView.update()
    }
}

extension FilterContainerView: DelegateFilterChange{
    func onChangedFilter(type: FilterType) {
        delegate?.changedFilter(type: type)
    }
}

extension FilterContainerView : DelegateSlowTypeChange {
    func onChangeSlowType(slowOn: Bool) {
        filterSpeedView.setSlowOn(slowOn: slowOn)
    }
}

extension FilterContainerView : DelegateSlowSpeedChange {
    func onChangeSlowSpeed(isSlow: Bool) {
        filterTypeView.setSlowTypeOn(slowTypeOn: isSlow)
    }
}
