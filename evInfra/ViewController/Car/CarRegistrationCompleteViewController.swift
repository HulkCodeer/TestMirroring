//
//  CarRegistrationCompleteViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/07/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class CarRegistrationCompleteViewController: CommonBaseViewController, StoryboardView {

    // MARK: UI
    
    
    
    // MARK: VARIABLE
    
    private var circularProgressBarView: CircularProgressBarView = CircularProgressBarView(frame: .zero)
    private var circularViewDuration: TimeInterval = 2
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        setUpCircularProgressBarView()
    }
    
    internal func bind(reactor: CarRegistrationReactor) {
        
    }
        
    func setUpCircularProgressBarView() {
        circularProgressBarView.center = view.center
        circularProgressBarView.progressAnimation(duration: circularViewDuration)        
        view.addSubview(circularProgressBarView)
    }
}
