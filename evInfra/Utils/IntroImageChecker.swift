//
//  IntroImageDownloader.swift
//  evInfra
//
//  Created by SH on 2021/01/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class IntroImageChecker {
    
    let efm = EVFileManager.sharedInstance
    
    var introImageCheckerDelegate :IntroImageCheckerDelegate? = nil
    
    init() {}
    
    init(delegate : IntroImageCheckerDelegate) {
        self.introImageCheckerDelegate = delegate
    }
    
    func getIntroImage() {
        let imgName = UserDefault().readString(key: UserDefault.Key.APP_INTRO_IMAGE)
        let endDate = UserDefault().readString(key: UserDefault.Key.APP_INTRO_END_DATE)
        if !imgName.isEmpty , !Date().isPassedDate(date: endDate){
            if self.efm.isFileExist(named : imgName){
                let path = self.efm.getFilePath(named: imgName)
                self.introImageCheckerDelegate?.finishCheckIntro(imgName: imgName, path : path)
            } else {
                self.introImageCheckerDelegate?.showDefaultImage()
            }
        } else {
            self.introImageCheckerDelegate?.showDefaultImage()
        }
    }
    
    func checkIntroImage(response : JSON){
        if let introName = response["img_name"].string, !introName.equals("") {
            if let endDate = response["until"].string, !endDate.equals("") {
                if Date().isPassedDate(date : endDate) {
                    UserDefault().saveString(key: UserDefault.Key.APP_INTRO_IMAGE, value : "")
                    UserDefault().saveString(key: UserDefault.Key.APP_INTRO_END_DATE, value : "")
                } else {
                    let savedImg = UserDefault().readString(key: UserDefault.Key.APP_INTRO_IMAGE)
                    if savedImg.equals("") || !savedImg.equals(introName) {
                        downloadIntroImage(imgName : introName, endDate: endDate)
                    }
                }
            }
        }
    }
    
    private func downloadIntroImage(imgName : String, endDate :String) {
        let url = "\(Const.IMG_URL_INTRO)\(imgName)"
                
        let destination: DownloadRequest.Destination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(imgName)
            return (documentsURL, [.removePreviousFile])
        }
        
        AF.download(url, to:destination)
            .downloadProgress { (progress) in
            }
            .responseData { (data) in
                print("Download Complete \(imgName)")
                UserDefault().saveString(key: UserDefault.Key.APP_INTRO_IMAGE, value : imgName)
                UserDefault().saveString(key: UserDefault.Key.APP_INTRO_END_DATE, value : endDate)
        }
    }
}
