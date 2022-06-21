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
import RxSwift
import RxCocoa
import Material
import SwiftyJSON
import GRDB

internal final class SearchViewController: UIViewController {
    private enum TableViewType {
        case charger
        case address
    }
    
    private let koreanTextMatcher = KoreanTextMatcher.init()
    private var tMapPathData: TMapPathData = TMapPathData.init()
    private var mQueryValue : String?
    private var searchType: TableViewType? = .charger
    private let INIT_KEYWORD = "EV충전소"
    private let disposeBag = DisposeBag()
    
    internal var delegate: ChargerSelectDelegate?
    internal var routeType: RoutePosition = .none
    internal var removeAddressButton: Bool = false
    
    // View
    @IBOutlet weak var tableView: ChargerTableView!
    @IBOutlet weak var addrTableView: SearchTableView!
    @IBOutlet weak var chargerRadioBtn: UIButton!
    @IBOutlet weak var addrRadioBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var currentLocationButton: UIButton!
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureButton()
        prepareSearchBar()
        prepareTableView()
        bind()
    }
    
    private func configureButton() {
        addrRadioBtn.isHidden = removeAddressButton
        
        chargerRadioBtn.setImage(UIImage(named: "iconRadioUnselected"), for: .normal)
        chargerRadioBtn.setImage(UIImage(named: "iconRadioSelected"), for: .selected)
        addrRadioBtn.setImage(UIImage(named: "iconRadioUnselected"), for: .normal)
        addrRadioBtn.setImage(UIImage(named: "iconRadioSelected"), for: .selected)
    }
    
    private func bind() {
        chargerRadioBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard !self.chargerRadioBtn.isSelected else { return }
                
                self.searchType = .charger
                self.setUnSelectButton(type: self.addrRadioBtn)
                self.chargerRadioBtn.isSelected = true
                self.searbarRefresh()
            }).disposed(by: disposeBag)
        
        addrRadioBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard !self.addrRadioBtn.isSelected else { return }
                
                self.searchType = .address
                self.setUnSelectButton(type: self.chargerRadioBtn)
                self.addrRadioBtn.isSelected = true
                self.searbarRefresh()
            }).disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard self.searchType == .address else {
                    self.mQueryValue = ""
                    self.refreshCursorAdapter()
                    return
                }
                
                self.findAllPOI(with: self.INIT_KEYWORD)
            }).disposed(by: disposeBag)
    }
    
    private func setUnSelectButton(type button: UIButton) {
        guard button.isSelected else { return }
        button.isSelected = false
    }

    private func prepareTableView() {
        hideProgress()
        
        addrTableView.isHidden = true
        tableView.isHidden = false
       
        searchType = .charger
        
        tableView.chargerTableDelegate = self
        tableView.isHiddenAlertFavoriteIcon = true
        tableView.keyboardDismissMode = .onDrag
        
        addrTableView.searchTableDelegate = self
        addrTableView.keyboardDismissMode = .onDrag

        tableView.chargerList = [ChargerStationInfo]()
        searbarRefresh()
    }
    
    private func reloadData() {
        guard searchType == .address else {
            tableView.reloadData()
            tableView.isHidden = false
            addrTableView.isHidden = true
            return
        }
        
        addrTableView.reloadData()
        addrTableView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showProgress() {
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    private func hideProgress() {
        indicator.isHidden = true
        indicator.stopAnimating()
    }
}

// MARK: SearchBar Delegate
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
    
    private func refreshCursorAdapter() {
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
        guard searchType == .address else {
            self.mQueryValue = text
            refreshCursorAdapter()
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            var searchWord = self.INIT_KEYWORD
            if !StringUtils.isNullOrEmpty(text) {
                searchWord = text!
            }
            
            self.findAllPOI(with: searchWord)
        }
    }
    
    private func findAllPOI(with keyword: String) {
        ChargerManager.sharedInstance.findAllPOI(keyword: keyword) { [weak self] poiList in
            guard let self = self,
                  let poiList = poiList else { return }
           
            self.addrTableView.poiList = poiList
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
}

// MARK: 충전소 검색 Delegate
extension SearchViewController: ChargerTableViewDelegate {
    func didSelectRow(row: Int) {
        guard let charger = self.tableView.chargerList?[row] else {
            return
        }
        
        switch routeType {
        case .start:
            let start = Notification.Name(rawValue: "startMarker")
            NotificationCenter.default.post(name: start, object: charger)
        case .mid:
            let via = Notification.Name(rawValue: "viaMarker")
            NotificationCenter.default.post(name: via, object: charger)
        case .end:
            let destination = Notification.Name(rawValue: "destinationMarker")
            NotificationCenter.default.post(name: destination, object: charger)
        default:
            break
        }

        delegate?.moveToSelected(chargerId: charger.mChargerId!)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: 주소검색 Delegate
extension SearchViewController: SearchTableViewViewDelegate {
    func didAddrSelectRow(row: Int) {
        guard let poi = self.addrTableView.poiList?[row] else {
            return
        }
        
        let station = StationInfoDto()
        station.mSnm = poi.getPOIName()
        station.mAddress = poi.getPOIAddress()
        station.mLatitude = poi.getPOIPoint().getLatitude()
        station.mLongitude = poi.getPOIPoint().getLongitude()
        
        let charger = ChargerStationInfo(station)
        
        switch routeType {
        case .start:
            let start = Notification.Name(rawValue: "startMarker")
            NotificationCenter.default.post(name: start, object: charger)
        case .mid:
            let via = Notification.Name(rawValue: "viaMarker")
            NotificationCenter.default.post(name: via, object: charger)
        case .end:
            let destination = Notification.Name(rawValue: "destinationMarker")
            NotificationCenter.default.post(name: destination, object: charger)
        default:
            break
        }
        
        delegate?.moveToSelectLocation(lat: poi.getPOIPoint().getLatitude() , lon: poi.getPOIPoint().getLongitude() )
        dismiss(animated: true, completion: nil)
    }
}
