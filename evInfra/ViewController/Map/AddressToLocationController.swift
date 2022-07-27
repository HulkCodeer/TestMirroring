//
//  AddressToLocationController.swift
//  evInfra
//
//  Created by 이신광 on 26/10/2018.
//  Copyright © 2018 soft-berry. All rights reserved.
//

import UIKit
import Material

protocol AddressToLocationDelegate {
    func moveToLocation(lat:Double, lon:Double)
}

class AddressToLocationController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var tMapPathData: TMapPathData = TMapPathData.init()
    
    var delegate: AddressToLocationDelegate?
    
    var poiList: [TMapPOIItem]? = nil
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "충전소 위치 검색 화면"
        prepareSearchBar()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension AddressToLocationController {
    internal func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor(rgb: 0xE4E4E4)
        tableView.keyboardDismissMode = .onDrag
    }

    func setPOI(list: [TMapPOIItem]) {
        poiList = list
    }

    internal func reloadData() {
        tableView.reloadData()
    }
}

extension AddressToLocationController: SearchBarDelegate {
    internal func prepareSearchBar() {
        // Access the searchBar.
        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        searchBar.delegate = self
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        reloadData()
    }
    
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let pattern = text?.trimmed, 0 < pattern.utf16.count else {
            reloadData()
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            if let poiList = self.tMapPathData.requestFindAllPOI(text) {
                if poiList.count > 0 {
                    DispatchQueue.main.async {
                        self.setPOI(list: poiList as! [TMapPOIItem])
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension AddressToLocationController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pois = poiList else {
            return
        }
        guard let latitude = pois[indexPath.row].getPOIPoint()?.getLatitude() else {
            Snackbar().show(message: "위치를 가져올수 없습니다. 종료 후 다시 시도해주세요")
            return
        }
        guard let longitude = pois[indexPath.row].getPOIPoint()?.getLongitude() else {
            Snackbar().show(message: "위치를 가져올수 없습니다. 종료 후 다시 시도해주세요")
            return
        }
        
        if let delegate = self.delegate {
            delegate.moveToLocation(lat: latitude, lon: longitude)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddressToLocationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addrSearchCell", for: indexPath) as! AddressSearchCell
        
        guard let pois = poiList else {
            return cell
        }
        cell.addressTextView.text = pois[indexPath.row].name + " - " + pois[indexPath.row].address
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
}
