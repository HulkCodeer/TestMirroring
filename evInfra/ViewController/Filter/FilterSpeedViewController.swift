//
//  FilterSpeedViewController.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import RangeSeekSlider
class FilterSpeedViewController: UIViewController {
    @IBOutlet var rangeSliderSpeed: RangeSeekSlider!
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeSliderSpeed.delegate = self
        rangeSliderSpeed.numberFormatter.positiveSuffix = "kW"
        rangeSliderSpeed.hideLabels = true
    }
}
// MARK: - RangeSeekSliderDelegate

extension FilterSpeedViewController: RangeSeekSliderDelegate {

    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        if slider === rangeSliderSpeed {
            print("Standard slider updated. Min Value: \(minValue) Max Value: \(maxValue)")
        }
    }

    func didStartTouches(in slider: RangeSeekSlider) {
        print("did start touches")
    }

    func didEndTouches(in slider: RangeSeekSlider) {
        print("did end touches")
    }
}
