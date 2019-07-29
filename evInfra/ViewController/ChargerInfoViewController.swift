//
//  ChargerInfoViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 5. 9..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class ChargerInfoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let chargerJson: JSON = ["lists": [
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
            "name": "데스티네이션/슈퍼차져",
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
    
    var chargerModels = [ChargerModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareActionBar()
        self.getchargerModels()
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
    
    // MARK: - Click Event
    
    @IBAction func onClickBackBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChargerInfoViewController {
    func prepareActionBar() {
        var backButton: IconButton!
        backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
        navigationItem.titleLabel.text = "충전기 정보"
        self.navigationController?.isNavigationBarHidden = false
    }
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func prepareCollectionView() {
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
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chargerModels.count
    }
    
    @objc
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCellReusable", for: indexPath) as! InfoCollectionViewCell
        cell.cellImage.image = UIImage(named: chargerModels[indexPath.item].image!)
        cell.cellImage.motionIdentifier = "\(chargerModels[indexPath.item].image!)"
        cell.cellTitle.text = chargerModels[indexPath.item].name
        cell.transition(.fadeOut, .scale(0.75))
        
        return cell
    }
}

extension ChargerInfoViewController: UICollectionViewDelegate {
    @objc
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("here!!!")
        let detailView:ChargerDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChargerDetailViewController") as! ChargerDetailViewController
        detailView.model = chargerModels[indexPath.item]
        self.navigationController?.pushViewController(detailView, animated: true)
    }
}

extension ChargerInfoViewController {
    func getchargerModels() {
        let json = chargerJson
        self.chargerModels.removeAll()
        let evJson = json["lists"]
        for json in evJson.arrayValue{
            let chargerModel = ChargerModel(json: json)
            self.chargerModels.append(chargerModel)
        }
        self.prepareCollectionView()
    }
}
