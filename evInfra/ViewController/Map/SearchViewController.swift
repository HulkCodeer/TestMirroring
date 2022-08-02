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
import GRDB

class SearchViewController: UIViewController {
    
    public static let TABLE_VIEW_TYPE_CHARGER = 1
    public static let TABLE_VIEW_TYPE_ADDRESS = 2
    
    var searchType:Int?
    internal weak var delegate: ChargerSelectDelegate?
    
    let koreanTextMatcher = KoreanTextMatcher.init()
    
    private var tMapPathData: TMapPathData = TMapPathData.init()
    
    var mQueryValue : String?
    
    let INIT_KEYWORD = "EV충전소"
    
    // View.
    @IBOutlet weak var tableView: ChargerTableView!
    @IBOutlet weak var addrTableView: SearchTableView!
    
    @IBOutlet weak var chargerRadioBtn: UIButton!
    @IBOutlet weak var addrRadioBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var removeAddressButton: Bool = false
    
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
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "충전소 검색 화면"
        configureButton()
        prepareSearchBar()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureButton() {
        addrRadioBtn.isHidden = removeAddressButton
    }

    internal func prepareTableView() {
        hideProgress()
        
        addrTableView.isHidden = true
        tableView.isHidden = false
        
        searchType = SearchViewController.TABLE_VIEW_TYPE_CHARGER
        
        tableView.chargerTableDelegate = self
        tableView.isHiddenAlertFavoriteIcon = true
        tableView.keyboardDismissMode = .onDrag
        
        addrTableView.searchTableDelegate = self
        addrTableView.keyboardDismissMode = .onDrag

        tableView.chargerList = [ChargerStationInfo]()
        
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
    
    func refreshCursorAdapter() {
        let dbQueue = DataBaseHelper.sharedInstance.getDbQue()
        DispatchQueue.global().async {
            dbQueue?.inDatabase { db in
                // Perform database work
                do {
                    var request: QueryInterfaceRequest = StationInfoDto.select(Column("mChargerId"),Column("mLatitude"),Column("mLongitude"))
                    request = request.filter( Column("mDel") == 0)
                    if StringUtils.isNullOrEmpty(self.mQueryValue) == false {
                        request = request.filter(Column("mSnm").like("%" + self.mQueryValue! + "%") ||
                            Column("mAddress").like("%" + self.mQueryValue! + "%") ||
                            Column("mAddressDetail").like("%" + self.mQueryValue! + "%") ||
                            Column("mSnmSearchWord").like("%" + self.mQueryValue! + "%") ||
                            Column("mAddressSearchWord").like("%" + self.mQueryValue! + "%") ||
                            Column("mAddressDetailSearchWord").like("%" + self.mQueryValue! + "%")
                        )
                    }
                    
                    // 거리
                    let currentPosition = CLLocationManager().getCurrentCoordinate()
                    let sql = "ABS(\(currentPosition.latitude) - mLatitude) + ABS(\(currentPosition.longitude) - mLongitude) ASC"
                    request = request.order(sql: sql)
                    
                    self.tableView.chargerList?.removeAll()
                    let stationList = try request.fetchAll(db)
                    for station in stationList{
                        let chargerStationInfo = ChargerManager.sharedInstance.getChargerStationInfoById(charger_id: station.mChargerId!)
                        if (chargerStationInfo != nil){
                            self.tableView.chargerList?.append(chargerStationInfo!)
                        }
                    }
                }catch{                    
                    printLog(out: "refreshCursorAdapter Error : \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                // update your user interface
                self.reloadData()
            }
        }
    }

    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        if self.searchType != SearchViewController.TABLE_VIEW_TYPE_ADDRESS {
            // space 제거, 소문자로 변경 후 비교
            self.mQueryValue = text
            refreshCursorAdapter()
        } else {
            DispatchQueue.global(qos: .background).async {
                var searchWord = self.INIT_KEYWORD
                if !StringUtils.isNullOrEmpty(text) {
                    searchWord = text!
                }
                
                ChargerManager.sharedInstance.findAllPOI(keyword: searchWord) { [weak self] poiList in
                    guard let poiList = poiList else {
                        return
                    }
                    
                    self?.addrTableView.poiList = poiList
                    DispatchQueue.main.async {
                        self?.reloadData()
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

        delegate?.moveToSelected(chargerId: charger.mChargerId!)
        dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: SearchTableViewViewDelegate {
    func didAddrSelectRow(row: Int) {
        guard let poi = self.addrTableView.poiList?[row] else {
            return
        }
        
        delegate?.moveToSelected(chargerId: poi.getPOID()!)
        delegate?.moveToSelectLocation(lat: poi.getPOIPoint().getLatitude() , lon: poi.getPOIPoint().getLongitude() )
        dismiss(animated: true, completion: nil)
    }
}
