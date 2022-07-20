//
//  PoiTableView.swift
//  evInfra
//
//  Created by Shin Park on 2018. 4. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

protocol PoiTableViewDelegate: class {
    func didSelectRow(poiItem: TMapPOIItem)
}

class PoiTableView: UITableView {
    
    internal weak var poiTableDelegate: PoiTableViewDelegate?
    
    var poiList: [TMapPOIItem]? = nil

    required override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        self.dataSource = self
        self.delegate = self
        
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 60
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.dataSource = self
        self.delegate = self
        
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 60
    }
}

extension PoiTableView {
    func setPOI(list: [TMapPOIItem]) {
        poiList = list
    }
}

extension PoiTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiList?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Prepares the cells within the tableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        guard let pois = poiList else {
            return cell
        }
        
        cell.textLabel?.text = pois[indexPath.row].name
        cell.detailTextLabel?.text = pois[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pois = poiList else {
            return
        }
        poiTableDelegate?.didSelectRow(poiItem: pois[indexPath.row])
    }
}

extension PoiTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
