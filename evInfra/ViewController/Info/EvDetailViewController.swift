//
//  EVDetailViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

internal final class EvDetailViewController: BaseViewController {
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var apes: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var battery: UILabel!
    
    internal var index: Int
    internal var model: EVModel?
            
    required init?(coder aDecoder: NSCoder) {
        index = 0
        super.init(coder: aDecoder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let model = model else { return }

        carImage.sd_setImage(with: URL(string: "\(Const.IMG_URL_EV_MODEL)\(model.image ?? "").jpg"), placeholderImage: UIImage(named: "AppIcon"))
        carImage.motionIdentifier = "\(model.image ?? "").jpg"
        vehicleName.text = model.name
        company.text = model.company
        apes.text = model.apes
        maxSpeed.text = model.speed
        distance.text = model.distance
        battery.text = model.batt
    }
}
