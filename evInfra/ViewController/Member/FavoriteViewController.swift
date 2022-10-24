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
    private var favoriteChargers: [ChargerStationInfo] = []
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()

        prepareActionBar(with: "즐겨찾기")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        favoriteChargers = ChargerManager.sharedInstance.getChargerStationInfoList()
        prepareTableView()
        logEventWithFavoriteChargers()
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
        tableView.chargerList = favoriteChargers.filter({
            return $0.mFavorite
        })
        tableView.reloadData()
        
        emptyView.isHidden = tableView.chargerList?.count != 0
    }
    
    func logEventWithFavoriteChargers() {
        let numberOfFavorits = favoriteChargers.filter { $0.mFavorite }.count
        let numberOfAlarms = favoriteChargers.filter { $0.mFavoriteNoti }.count
        let property: [String: Any] = ["number": "\(numberOfFavorits)",
                                       "alarmOn": "\(numberOfAlarms)"]
        
        MapEvent.viewFavorites.logEvent(property: property)
        AmplitudeManager.shared.setUserProperty(with: numberOfFavorits)
        
    }
    
    func didSelectRow(row: Int) {
        guard let charger = tableView.chargerList?[row] else {
            return
        }
        let ampChargerStationModel = AmpChargerStationModel(charger)
        var property: [String: Any] = ampChargerStationModel.toProperty
        property["source"] = "즐겨찾기"
        MapEvent.viewStationSummarized.logEvent(property: property)
        
        delegate?.moveToSelected(chargerId: charger.mChargerId!)
        GlobalDefine.shared.mainNavi?.pop(subtype: CATransitionSubtype.fromBottom)
    }
}
