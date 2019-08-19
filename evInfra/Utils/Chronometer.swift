//
//  Chronometer.swift
//  evInfra
//
//  Created by bulacode on 09/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit

class Chronometer: UILabel {

    private var timer = Timer()
    
    private var baseTime: Double = 0.0
    private var now: Double = 0.0 // the currently displayed time

    private var isTimerRunnint = false
    private var repeats = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setBase(base: Double) {
        baseTime = base
    }
    
    public func start() {
        if !repeats {
            repeats = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: repeats) { (timer) in
                self.updateText()
            }
            timer.fire()
        }
    }
    
    public func stop() {
        repeats = false
        timer.invalidate()
    }
    
    func updateText() {
        now = Date.init().timeIntervalSince1970
        let seconds = now - baseTime
        let time = msToTime(milliseconds: seconds)
        self.text = time
    }
    
    func msToTime(milliseconds: Double) -> String {
        let seconds = Int((milliseconds).truncatingRemainder(dividingBy: 60))
        let minutes = Int((milliseconds/(60)).truncatingRemainder(dividingBy: 60))
        let hours = Int((milliseconds/(60*60)))
        
        let thours = (hours < 10) ? "0\(hours)" : "\(hours)";
        let tminutes = (minutes < 10) ? "0\(minutes)" : "\(minutes)";
        let tseconds = (seconds < 10) ? "0\(seconds)" : "\(seconds)";
        
        return "\(thours):\(tminutes):\(tseconds)"
    }
}
