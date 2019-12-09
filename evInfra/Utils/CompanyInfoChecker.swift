//
//  CompanyIconChecker.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 5..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CompanyIconChecker {
    let efm = EVFileManager.sharedInstance
    let dbManager = DBManager.sharedInstance
    var serverCompanyList: JSON? = nil
    var updateArray = Array<JSON>()
    var insertArray = Array<JSON>()
    var updateCount = 0
    var companyInfoCheckerDelegate: CompanyInfoCheckerDelegate? = nil
    let defaults = UserDefault()
    
    init(delegate: CompanyInfoCheckerDelegate) {
        self.companyInfoCheckerDelegate = delegate
    }
    
    func checkCompanyInfo() {
        dbManager.openDB()
        let companyArray = dbManager.getCompanyInfoList()
        let updateDate = defaults.readString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE)
        
        Server.getCompanyInfo(updateDate: updateDate) { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                let serverCompanyList = json["cominfo"]
                
                for (_, item):(String, JSON) in serverCompanyList {
                    if(item["icon_name"].stringValue.elementsEqual("")) {
                        continue
                    }
                    if let company = companyArray.filter({$0.id!.elementsEqual(item["id"].stringValue)}).first {
                        if let icName = company.iconName {
                            if !icName.elementsEqual(item["icon_name"].stringValue) {
                                self.efm.deleteFile(named: "\(icName).png")
                            }
                        }
                        self.updateArray.append(item)
                    } else {
                        self.insertArray.append(item)
                    }
                }
                self.companyInfoCheckerDelegate?.processDownloadFileSize(size: self.insertArray.count + self.updateArray.count)
                self.updateCompanyIconInfo(index: 0)
            }
        }
    }
    
    func updateCompanyIconInfo(index: Int) {
        if (index < updateArray.count) {
            let item = updateArray[index]
            let url = "\(Const.IMG_URL_COMP_MARKER)\(item["icon_name"].stringValue).png"
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent("\(item["icon_name"].stringValue).png")
                return (documentsURL, [.removePreviousFile])
            }
            
            Alamofire.download(url, to:destination)
                .downloadProgress { (progress) in
                    print("in downloadProgress")
                }
                .responseData { (data) in
                    print("Download Complete \(item["icon_name"].stringValue)")
                    self.dbManager.updateCompanyImage(companyId: item["id"].stringValue, imageName: item["icon_name"].stringValue)
                    self.dbManager.updateCompanyAppstore(companyId: item["id"].stringValue, appStore: item["as"].stringValue)
                    self.dbManager.updateCompanyHomepage(companyId: item["id"].stringValue, homepage: item["hp"].stringValue)
                    self.efm.makeMarkerImage(companyIcon: item["icon_name"].stringValue, companyId: item["id"].stringValue)
                    let nextIndex = index + 1
                    self.updateCount = self.updateCount + 1
                    self.companyInfoCheckerDelegate?.processOnDownloadCompanyImage(count: self.updateCount)
                    self.updateCompanyIconInfo(index: nextIndex)
            }
        } else {
            self.insertCompanyIconInfo(index: 0)
            defaults.saveString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE, value: Date().toString())
        }
    }
    
    func insertCompanyIconInfo(index: Int) {
        if (index < insertArray.count) {
            let item = insertArray[index]
            let url = "\(Const.IMG_URL_COMP_MARKER)\(item["icon_name"].stringValue).png"
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent("\(item["icon_name"].stringValue).png")
                return (documentsURL, [.removePreviousFile])
            }
            Alamofire.download(url, to:destination)
                .downloadProgress { (progress) in
                }
                .responseData { (data) in
                    print("Download Complete \(item["icon_name"].stringValue)")
                    self.dbManager.insertCompanyInfo(company_id: item["id"].stringValue, name: item["name"].stringValue, icon_name: item["icon_name"].stringValue, hompage: "", ios_appstore: "")
                    self.efm.makeMarkerImage(companyIcon: item["icon_name"].stringValue, companyId: item["id"].stringValue)
                    self.updateCount = self.updateCount + 1
                    self.companyInfoCheckerDelegate?.processOnDownloadCompanyImage(count: self.updateCount)
                    self.insertCompanyIconInfo(index: index + 1)
            }
        } else {
            ImageMarker.loadMarkers()
            companyInfoCheckerDelegate?.finishDownloadCompanyImage()
        }
    }
}
