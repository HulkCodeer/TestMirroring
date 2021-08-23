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

    var companyInfoCheckerDelegate: CompanyInfoCheckerDelegate? = nil
    
    init(delegate: CompanyInfoCheckerDelegate) {
        self.companyInfoCheckerDelegate = delegate
        let pathVersion = UserDefault().readInt(key: UserDefault.Key.COMPANY_ICON_IMAGE_PATH_VERSION)
        if (pathVersion == 0) {
            UserDefault().saveString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE, value: "")
            UserDefault().saveInt(key: UserDefault.Key.COMPANY_ICON_IMAGE_PATH_VERSION, value: 1)
        }
    }
    
    func checkCompanyInfo() {
        let companyList = ChargerManager.sharedInstance.getCompanyInfoListAll()!
        
        var downloadArray = Array<CompanyInfoDto>()
        
        if companyList.count > 0 {
            for company in companyList {
                if StringUtils.isNullOrEmpty(company.icon_name) == false {
                    print("company snm: \(company.name!), icon name: \(company.icon_name!)")
                    if company.isChangeIcon() {
                        downloadArray.append(company)
                    }
                }
            }
            
            // icon 이 외의 정보가 업데이트 된 경우 update date 저장
            // icon 업데이트인 경우 download 완료 후 update date 저장
            if downloadArray.count == 0 {
                UserDefault().saveString(key: UserDefault.Key.COMPANY_ICON_UPDATE_DATE, value: Date().toString())
            }
        }
        
        if downloadArray.count > 0 {
            self.companyInfoCheckerDelegate?.processDownloadFileSize(size: downloadArray.count)
            self.downlaodCompanyIcon(companyList: downloadArray)
        } else {
            self.companyInfoCheckerDelegate?.finishDownloadCompanyImage()
        }
    }
    
    func downlaodCompanyIcon(companyList: Array<CompanyInfoDto>) {
        var updateCount = 0
        for company in companyList {
            let url = "\(Const.IMG_URL_COMP_MARKER)\(company.icon_name!).png"
            
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent("\(company.icon_name!).png")
                return (documentsURL, [.removePreviousFile])
            }
            
            Alamofire.download(url, to:destination)
                .downloadProgress { (progress) in
                }
                .responseData { (data) in
                    print("Download Complete \(company.icon_name!)")
                    self.efm.makeMarkerImage(companyIcon: company.icon_name!, companyId: company.company_id!)

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
