//
//  ViewPagerController.swift
//  evInfra
//
//  Created by Shin Park on 30/01/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import UIKit
import Parchment
import SwiftyJSON

class ViewPagerController: UIViewController {
    
    var charger: ChargerStationInfo? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(charger: ChargerStationInfo) {
        super.init(nibName: nil, bundle: nil)

        self.charger = charger
        
        // 충전소 이용률이 없으면 서버로부터 가져옴
        if (self.charger?.usage.isEmpty)! {
            getUsage()
        } else {
            preparePagingView()
        }
    }
    
    func preparePagingView() {
        let pagingViewController = PagingViewController()
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
    }
    
    func getUsage() {
        Server.getStationUsage(chargerId: (charger?.mChargerId)!) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let result = json["code"].intValue
                switch result {
                case 1000:
                    for countJson in json["data"].arrayValue {
                        self.charger?.usage.append(countJson.intValue)
                    }
                
                default: // 9000 error
                    print("server response error")
                }
            }
            self.preparePagingView()
        }
    }
}

extension ViewPagerController: PagingViewControllerDataSource {
    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return ChargerImageViewController(charger: charger!, index: index)
    }

    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        var title = "인공위성 사진"
        if index == 1 && !(self.charger?.usage.isEmpty)! {
            title = "시간대별 이용현황"
        }
        return PagingIndexItem(index: index, title: title)
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        if (self.charger?.usage.isEmpty)! {
            return 1
        } else {
            return 2
        }
    }
}

extension ViewPagerController: PagingViewControllerDelegate {
    // We want the size of our paging items to equal the width of the
    // city title. Parchment does not support self-sizing cells at
    // the moment, so we have to handle the calculation ourself. We
    // can access the title string by casting the paging item to a
    // PagingTitleItem, which is the PagingItem type used by
    // FixedPagingViewController.
    /*
     func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat? {
     guard let item = pagingItem as? PagingIndexItem else { return 0 }
     
     let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
     let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
     let attributes = [NSAttributedString.Key.font: pagingViewController.font]
     
     let rect = item.title.boundingRect(with: size,
     options: .usesLineFragmentOrigin,
     attributes: attributes,
     context: nil)
     
     let width = ceil(rect.width) + insets.left + insets.right
     
     if isSelected {
     return width * 1.5
     } else {
     return width
     }
     }
     */
}
