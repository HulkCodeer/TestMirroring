//
//  EvInfoViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON

internal final class EvInfoViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var evModels = [EVModel]()
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
        getEvModels()
    }
    
    private func prepareCollectionView() {
        collectionView.reloadData()
    }
    
    private func getEvModels() {
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
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @objc
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return evModels.count
    }
    
    @objc
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCellReusable", for: indexPath) as? InfoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.cellImage.sd_setImage(with: URL(string: "\(Const.IMG_URL_EV_MODEL)\(evModels[indexPath.item].image ?? "").jpg"), placeholderImage: UIImage(named: "AppIcon"))
        cell.cellImage.motionIdentifier = "\(evModels[indexPath.item].image ?? "").jpg"
        cell.cellTitle.text = evModels[indexPath.item].name
        cell.transition(.fadeOut, .scale(0.75))
        
        return cell
    }
}

extension EvInfoViewController: UICollectionViewDelegate {
    @objc
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailView = self.storyboard?.instantiateViewController(ofType: EvDetailViewController.self) as? EvDetailViewController else { return }
        detailView.index = indexPath.item
        detailView.model = evModels[indexPath.item]
        GlobalDefine.shared.mainNavi?.push(viewController: detailView)
    }
}
