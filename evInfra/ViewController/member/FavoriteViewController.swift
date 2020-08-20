//
//  FavoriteViewController
//  evInfra
//
//  Created by Shin Park on 05/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material

class FavoriteViewController: UIViewController {

    @IBOutlet weak var tableView: ChargerTableView!
    
    var delegate:ChargerSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar()
        prepareTableView()
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "즐겨찾기"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension FavoriteViewController: ChargerTableViewDelegate {
    
    func prepareTableView() {
        tableView.chargerTableDelegate = self
        tableView.chargerList = ChargerManager.sharedInstance.getChargerStationInfoList().filter({(charger: ChargerStationInfo) -> Bool in
            return charger.mFavorite
        })
        tableView.reloadData()
    }
    
    func didSelectRow(row: Int) {
        guard let charger = tableView.chargerList?[row] else {
            return
        }
        
        delegate?.moveToSelected(chargerId: charger.mChargerId!)
        dismiss(animated: true, completion: nil)
    }
}
