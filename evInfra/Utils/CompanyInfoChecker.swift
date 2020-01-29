//
//  CompanyInfoChecker.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 5..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CompanyInfoChecker {
    
    let efm = EVFileManager.sharedInstance
    let dbManager = DBManager.sharedInstance

    var companyInfoCheckerDelegate: CompanyInfoCheckerDelegate? = nil
    
    init(delegate: CompanyInfoCheckerDelegate) {
        self.dbManager.openDB()
        self.companyInfoCheckerDelegate = delegate
    }
    
    func checkCompanyInfo() {
        let updateDate = UserDefault().readString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE)
        Server.getCompanyInfo(updateDate: updateDate) { (isSuccess, value) in
            var downloadArray = Array<JSON>()
            if isSuccess {
                let json = JSON(value)
                if json["code"] == 1000 {
                    let companyList = json["list"]
                    if companyList.count > 0 {
                        for (_, item):(String, JSON) in companyList {
                            self.dbManager.insertOrReplace(json: item)
                            
                            print("company snm: \(item["name"].stringValue), icon name: \(item["ic_name"].stringValue)")
                            if !item["ic_name"].stringValue.elementsEqual("") {
                                if updateDate < item["ic_date"].stringValue {
                                    downloadArray.append(item)
                                }
                            }
                        }
                        
                        // icon 이 외의 정보가 업데이트 된 경우 update date 저장
                        // icon 업데이트인 경우 download 완료 후 update date 저장
                        if downloadArray.count == 0 {
                            UserDefault().saveString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE, value: Date().toString())
                        }
                    }
                }
            }
            
            if downloadArray.count > 0 {
                self.companyInfoCheckerDelegate?.processDownloadFileSize(size: downloadArray.count)
                self.downlaodCompanyIcon(companyList: downloadArray)
            } else {
                self.companyInfoCheckerDelegate?.finishDownloadCompanyImage()
            }
        }
    }
    
    func downlaodCompanyIcon(companyList: Array<JSON>) {
        var updateCount = 0
        for item in companyList {
            let url = "\(Const.IMG_URL_COMP_MARKER)\(item["ic_name"].stringValue).png"
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent("\(item["ic_name"].stringValue).png")
                return (documentsURL, [.removePreviousFile])
            }
            
            Alamofire.download(url, to:destination)
                .downloadProgress { (progress) in
                }
                .responseData { (data) in
                    print("Download Complete \(item["ic_name"].stringValue)")
                    self.efm.makeMarkerImage(companyIcon: item["ic_name"].stringValue, companyId: item["id"].stringValue)

                    // update UI
                    updateCount += 1
                    self.companyInfoCheckerDelegate?.processOnDownloadCompanyImage(count: updateCount)
                    
                    if companyList.count <= updateCount {
                        print("Download finish. list: \(companyList.count), download: \(updateCount)")
                        
                        UserDefault().saveString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE, value: Date().toString())
                        self.companyInfoCheckerDelegate?.finishDownloadCompanyImage()
                    }
            }
        }
    }
}
