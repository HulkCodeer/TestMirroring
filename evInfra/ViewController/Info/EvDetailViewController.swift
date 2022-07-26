//
//  EVDetailViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Motion
import Material

class EvDetailViewController: UIViewController {
    
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var apes: UILabel!
    @IBOutlet weak var maxSpeed: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var battery: UILabel!
    
    var index: Int
    var model: EVModel?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        index = 0
        super.init(coder: aDecoder)
    }
    
    public init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        
        carImage.sd_setImage(with: URL(string: "\(Const.IMG_URL_EV_MODEL)\(model!.image!).jpg"), placeholderImage: UIImage(named: "AppIcon"))
        carImage.motionIdentifier = "\(model!.image!).jpg"
        
        vehicleName.text = model!.name
        company.text = model!.company
        apes.text = model!.apes
        maxSpeed.text = model!.speed
        distance.text = model!.distance
        battery.text = model!.batt
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension EvDetailViewController {
    func prepareActionBar() {
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "전기차 정보"
    }
}
