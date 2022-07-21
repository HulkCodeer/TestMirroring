//
//  ChargerInfoViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON

internal final class ChargerInfoViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let chargerJson: JSON = ["lists": [
        [
            "model_id": 1,
            "name": "AC 완속 (5 Pin)",
            "ampare": "80 A",
            "voltage": "120 ~ 240 VAC",
            "current": "0.96 ~ 19.20 kW",
            "vehicles": "레이, 쏘울, 아이오닉, 스파크, 볼트, i3, Leaf",
            "level": "1, 2",
            "image": "charger_acsingle.jpg"
        ],[
            "model_id": 2,
            "name": "DC차데모 (급속)",
            "ampare": "100 ~ 120 A",
            "voltage": "500V DC",
            "current": "60kW (최대 전력)",
            "vehicles": "레이, 쏘울, 아이오닉, Leaf",
            "level": "3",
            "image": "charger_chademo.jpg"
        ],[
            "model_id": 3,
            "name": "DC Combo (급속)",
            "ampare": "200 A",
            "voltage": "200 ~ 600 VDC",
            "current": "125kW (최대전력)",
            "vehicles": "아이오닉, 스파크, 볼트, i3",
            "level": "3",
            "image": "charger_dccombo.jpg"
        ],[
            "model_id": 4,
            "name": "AC 3상 완속/급속 (7 Pin)",
            "ampare": "32 A",
            "voltage": "220 ~ 440 VAC",
            "current": "3.52 kW ~ 14.08 kW(최대전력)",
            "vehicles": "SM3 ZE",
            "level": "1 ~ 3",
            "image": "charger_ac3.jpg"
        ],[
            "model_id": 5,
            "name": "데스티네이션",
            "ampare": "12 A ~ 80 A ~ 250A (단상 ~ 3상)",
            "voltage": "110 VAC ~ 240 VAC ~ 500 VDC (단상 ~ 3상)",
            "current": "1.32 kW ~ 19.26 kW ~ 120/135 kW",
            "vehicles": "테슬라 전 차종",
            "level": "1 ~ 3",
            "image": "charger_ac3.jpg"
        ],[
            "model_id": 6,
            "name": "가정용 220V",
            "ampare": "차량에 따라 다름",
            "voltage": "220V DC",
            "current": "차량에 따라 다름",
            "vehicles": "트위지, 다니고",
            "level": "1",
            "image": "charge_normal.jpg"
        ]
        ]
    ]
    
    private var chargerModels = [ChargerModel]()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareActionBar(with: "충전기 정보")
        getchargerModels()
    }
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChargerInfoViewController {
    private func prepareCollectionView() {
        let cellwidth: CGFloat = (view.bounds.width - 1) / 2
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: cellwidth, height: cellwidth)
        
        //        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "InfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InfoCollectionViewCellReusable")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.reloadData()
    }
}

extension ChargerInfoViewController: UICollectionViewDataSource {
    @objc
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chargerModels.count
    }
    
    @objc
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCellReusable", for: indexPath) as? InfoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.cellImage.image = UIImage(named: chargerModels[indexPath.item].image ?? "")
        cell.cellImage.motionIdentifier = "\(chargerModels[indexPath.item].image ?? "")"
        cell.cellTitle.text = chargerModels[indexPath.item].name
        cell.transition(.fadeOut, .scale(0.75))
        
        return cell
    }
}

extension ChargerInfoViewController: UICollectionViewDelegate {
    @objc
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailView = self.storyboard?.instantiateViewController(ofType: ChargerDetailViewController.self) as? ChargerDetailViewController else { return }
        detailView.model = chargerModels[indexPath.item]
        GlobalDefine.shared.mainNavi?.push(viewController: detailView)
    }
}

extension ChargerInfoViewController {
    private func getchargerModels() {
        let json = chargerJson
        self.chargerModels.removeAll()
        let evJson = json["lists"]
        for json in evJson.arrayValue {
            let chargerModel = ChargerModel(json: json)
            self.chargerModels.append(chargerModel)
        }
        self.prepareCollectionView()
    }
}
