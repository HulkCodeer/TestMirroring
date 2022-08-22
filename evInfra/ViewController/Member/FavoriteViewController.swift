//
//  FavoriteViewController
//  evInfra
//
//  Created by Shin Park on 05/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material

class FavoriteViewController: BaseViewController {

    @IBOutlet weak var tableView: ChargerTableView!
    @IBOutlet var emptyView: UIView!
    
    internal weak var delegate: ChargerSelectDelegate?
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareActionBar(with: "즐겨찾기")
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let favoriteChargers = ChargerManager.sharedInstance.getChargerStationInfoList()
        AmplitudeManager.shared.setUserProperty(with: favoriteChargers)
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "nt-9")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "nt-9")
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
        tableView.isHiddenAlertFavoriteIcon = false
        tableView.chargerTableDelegate = self
        tableView.chargerList = ChargerManager.sharedInstance.getChargerStationInfoList().filter({(charger: ChargerStationInfo) -> Bool in
            return charger.mFavorite
        })
        tableView.reloadData()
        
        if (tableView.chargerList?.count == 0) {
            emptyView.isHidden = false
        }else{
            emptyView.isHidden = true
        }
    }
    
    func didSelectRow(row: Int) {
        guard let charger = tableView.chargerList?[row] else {
            return
        }
        
        delegate?.moveToSelected(chargerId: charger.mChargerId!)
        GlobalDefine.shared.mainNavi?.pop(subtype: kCATransitionFromBottom)
    }
}
