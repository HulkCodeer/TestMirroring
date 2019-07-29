//
//  EVInfoViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 26..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON

class EVInfoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var evModels = [EVModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareActionBar()
        self.getEvModels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(rgb: 0x15435C)
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)

        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.textColor = UIColor(rgb: 0x15435C)
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
                let evJson = json["lists"]
                for json in evJson.arrayValue {
                    let evModel = EVModel(json: json)
                    self.evModels.append(evModel)
                }
                self.prepareCollectionView()
            }
        }
    }
}

extension EVInfoViewController: UICollectionViewDataSource {
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
        cell.cellImage.sd_setImage(with: URL(string: "\(Const.urlModelImage)\(evModels[indexPath.item].image!).jpg"), placeholderImage: UIImage(named: "AppIcon"))
        cell.cellImage.motionIdentifier = "\(evModels[indexPath.item].image!).jpg"
        cell.cellTitle.text = evModels[indexPath.item].name
        cell.transition(.fadeOut, .scale(0.75))
        
        return cell
    }
}

extension EVInfoViewController: UICollectionViewDelegate {
    @objc
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailView:EVDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "EVDetailViewController") as! EVDetailViewController
        detailView.index = indexPath.item
        detailView.model = evModels[indexPath.item]
        self.navigationController?.pushViewController(detailView, animated: true)
    }
}
