//
//  EvInfoViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class EvInfoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var evModels = [EVModel]()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "전기차 정보 리스트 화면"
        self.prepareActionBar()
        self.getEvModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "전기차 정보"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func prepareCollectionView() {
        let cellwidth: CGFloat = (view.bounds.width - 2) / 3
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: cellwidth, height: cellwidth)
        
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "InfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InfoCollectionViewCellReusable")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.reloadData()
    }
    
    func getEvModels() {
        Server.getEvModelList { (isSuccess, value) in
            if isSuccess {
                self.evModels.removeAll()
                let json = JSON(value)
                let evJson = json["list"]
                for json in evJson.arrayValue {
                    let evModel = EVModel(json: json)
                    self.evModels.append(evModel)
                }
                self.prepareCollectionView()
            }
        }
    }
}

extension EvInfoViewController: UICollectionViewDataSource {
    @objc
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evModels.count
    }
    
    @objc
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCellReusable", for: indexPath) as! InfoCollectionViewCell
        cell.cellImage.sd_setImage(with: URL(string: "\(Const.IMG_URL_EV_MODEL)\(evModels[indexPath.item].image!).jpg"), placeholderImage: UIImage(named: "AppIcon"))
        cell.cellImage.motionIdentifier = "\(evModels[indexPath.item].image!).jpg"
        cell.cellTitle.text = evModels[indexPath.item].name
        cell.transition(.fadeOut, .scale(0.75))
        
        return cell
    }
}

extension EvInfoViewController: UICollectionViewDelegate {
    @objc
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView:EvDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "EvDetailViewController") as! EvDetailViewController
        detailView.index = indexPath.item
        detailView.model = evModels[indexPath.item]
        self.navigationController?.pushViewController(detailView, animated: true)
    }
}
