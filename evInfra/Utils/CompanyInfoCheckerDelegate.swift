//
//  ServerPrepareDeleagate.swift
//  evInfra
//
//  Created by bulacode on 2018. 7. 12..
//  Copyright © 2018년 soft-berry. All rights reserved.
//


import UIKit

protocol CompanyInfoCheckerDelegate {
    func processDownloadFileSize(size: Int)
    func processOnDownloadCompanyImage(count: Int)
    func finishDownloadCompanyImage()
}
