//
//  ChargerDetailViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

internal final class ChargerDetailViewController: BaseViewController {
    @IBOutlet weak var chargerImageView: UIImageView!
    @IBOutlet weak var connectorName: UILabel!
    @IBOutlet weak var ampare: UILabel!
    @IBOutlet weak var voltage: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var vehicles: UILabel!
    
    internal var model: ChargerModel?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public init(index: Int) {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let model = model else { return }
        prepareActionBar(with: "충전기 정보")
        
        chargerImageView.image = UIImage(named: model.image)
        chargerImageView.motionIdentifier = "\(model.image)"
        connectorName.text = model.name ?? ""
        ampare.text = model.ampare ?? ""
        voltage.text = model.voltage ?? ""
        current.text = model.current ?? ""
        level.text = model.level ?? ""
        vehicles.text = model.vehicles ?? ""
    }
}
