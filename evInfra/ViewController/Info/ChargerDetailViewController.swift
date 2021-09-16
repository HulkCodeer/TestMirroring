//
//  ChargerDetailViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Motion
import Material

class ChargerDetailViewController: UIViewController {
    var model: ChargerModel?
    
    @IBOutlet weak var chargerImageView: UIImageView!
    @IBOutlet weak var connectorName: UILabel!
    @IBOutlet weak var ampare: UILabel!
    @IBOutlet weak var voltage: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var vehicles: UILabel!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(index: Int) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareActionBar()
        self.chargerImageView.image = UIImage(named: model!.image!)
        self.chargerImageView.motionIdentifier = "\(model!.image!)"
        self.connectorName.text = model!.name!
        self.ampare.text = model!.ampare!
        self.voltage.text = model!.voltage!
        self.current.text = model!.current!
        self.level.text = model!.level!
        self.vehicles.text = model!.vehicles!
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

extension ChargerDetailViewController{
    func prepareActionBar() {
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "충전기 정보"
    }
}
