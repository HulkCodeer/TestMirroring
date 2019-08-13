/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *    *    Redistributions of source code must retain the above copyright notice, this
 *        list of conditions and the following disclaimer.
 *
 *    *    Redistributions in binary form must reproduce the above copyright notice,
 *        this list of conditions and the following disclaimer in the documentation
 *        and/or other materials provided with the distribution.
 *
 *    *    Neither the name of CosmicMind nor the names of its
 *        contributors may be used to endorse or promote products derived from
 *        this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material
import SwiftyJSON

class SearchViewController: UIViewController {
    
    public static let TABLE_VIEW_TYPE_CHARGER = 1
    public static let TABLE_VIEW_TYPE_ADDRESS = 2
    
    var searchType:Int?
    var isPayableList: Bool = false
    var delegate:ChargerSelectDelegate?
    
    let chargerManager = ChargerListManager.sharedInstance
    
    let koreanTextMatcher = KoreanTextMatcher.init()
    
    private var tMapPathData: TMapPathData = TMapPathData.init()
    
    // View.
    @IBOutlet weak var tableView: ChargerTableView!
    @IBOutlet weak var addrTableView: SearchTableView!
    
    @IBOutlet weak var chargerRadioBtn: UIButton!
    @IBOutlet weak var addrRadioBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBAction func onClickChargerBtn(_ sender: UIButton) {
        searchType = SearchViewController.TABLE_VIEW_TYPE_CHARGER
        
        if self.addrRadioBtn.isSelected {
            self.addrRadioBtn.isSelected = false
            self.addrRadioBtn.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
        }

        if !sender.isSelected {
            sender.isSelected = true
            sender.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
            //self.reloadData()
            self.searbarRefresh()
        }
    }
    
    @IBAction func onClickAddressBtn(_ sender: UIButton) {
        searchType = SearchViewController.TABLE_VIEW_TYPE_ADDRESS
        
        if self.chargerRadioBtn.isSelected {
            self.chargerRadioBtn.isSelected = false
            self.chargerRadioBtn.setImage(UIImage(named: "ic_radio_unchecked"), for: .normal)
        }

        if !sender.isSelected {
            sender.isSelected = true
            sender.setImage(UIImage(named: "ic_radio_checked"), for: .normal)
            //self.reloadData()
            self.searbarRefresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareSearchBar()
        prepareTableView()
    }

    internal func prepareTableView() {
        hideProgress()
        
        addrTableView.isHidden = true
        tableView.isHidden = false
        
        searchType = SearchViewController.TABLE_VIEW_TYPE_CHARGER
        
        tableView.chargerTableDelegate = self
        tableView.keyboardDismissMode = .onDrag
        
        addrTableView.searchTableDelegate = self
        addrTableView.keyboardDismissMode = .onDrag

        if isPayableList {
            self.showProgress()
            Server.getChargerListForPayment() { (isSuccess, value) in
                self.hideProgress()
                if isSuccess {
                    let json = JSON(value)
                    let chargerList = json["charger_list"].arrayValue
                    var payableIds:[String] = [String]()
                    var payableList: [Charger] = [Charger]()
                    for item in chargerList{
                        if let id = item.rawString(){
                                payableIds.append(id)
                        }
                    }
                    payableIds = Array(Set(payableIds))
                    for id in payableIds {
                        if let charger = self.chargerManager.getChargerFromChargerId(id: id){
                            payableList.append(charger)
                        }
                    }
                    self.tableView.chargerList = payableList
                    self.tableView.reloadData()

                } else {
                    Snackbar().show(message: "충전소 목록을 받아오지 못했습니다.\n잠시 후 다시 시도해 주세요.")
                }
            }
        } else {
            tableView.chargerList = self.chargerManager.chargerList
        }
        
        onClickChargerBtn(chargerRadioBtn)
    }
    
    internal func reloadData() {
        if searchType != SearchViewController.TABLE_VIEW_TYPE_ADDRESS {
            tableView.reloadData()
            
            tableView.isHidden = false
            addrTableView.isHidden = true
        } else {
            addrTableView.reloadData()
            
            addrTableView.isHidden = false
            tableView.isHidden = true
        }
    }
    
    func responseChargerListForPayment(response: JSON){
        
    }
    
    func showProgress() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    func hideProgress() {
        indicator.isHidden = true
        indicator.stopAnimating()
    }
    
    struct decodeChargerList: Codable {
        var charger_list: [Charger]
    }
}

extension SearchViewController: SearchBarDelegate {
    internal func prepareSearchBar() {
        // Access the searchBar.
        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        searchBar.didChangeValue(forKey: searchBar.textField.text ?? "")
        searchBar.delegate = self
    }
    
    internal func searbarRefresh() {
        // Access the searchBar.
        guard let searchBar = searchBarController?.searchBar else {
            return
        }
        self.searchBar(searchBar: searchBar, didChange: searchBar.textField, with: searchBar.textField.text)
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
            // Background Thread
            if self.searchType != SearchViewController.TABLE_VIEW_TYPE_ADDRESS {
                // space 제거, 소문자로 변경 후 비교
                let trimmedPattern = pattern.replacingOccurrences(of: " ", with: "").lowercased()
                self.tableView.chargerList = self.chargerManager.chargerList?.filter({(charger: Charger) -> Bool in
                    let trimmedStationName = charger.stationName.replacingOccurrences(of: " ", with: "").lowercased()
                    return self.koreanTextMatcher.isMatch(text: trimmedStationName, pattern: trimmedPattern)
                })
                DispatchQueue.main.async {
                    // Run UI Updates or call completion block
                    self.reloadData()
                }
            } else {
                if let poiList = self.tMapPathData.requestFindAllPOI(text) {
                    if poiList.count > 0 {
                        self.addrTableView.poiList = poiList as? [TMapPOIItem]
                        DispatchQueue.main.async {
                            self.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension SearchViewController: ChargerTableViewDelegate {
    func didSelectRow(row: Int) {
        guard let charger = self.tableView.chargerList?[row] else {
            return
        }

        delegate?.moveToSelected(chargerId: charger.chargerId)
        dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: SearchTableViewViewDelegate {
    func didAddrSelectRow(row: Int) {
        guard let poi = self.addrTableView.poiList?[row] else {
            return
        }
        
        delegate?.moveToSelectLocation(lat: poi.getPOIPoint()?.getLatitude() ?? 0, lon: poi.getPOIPoint()?.getLongitude() ?? 0)
        dismiss(animated: true, completion: nil)
    }
}
