//
//  FAQTop.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/09/06.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import Material
import Foundation

public class FAQTop {
    var mFaqPriority:Int!
    var mFAQTopTitle:String!
    var mFAQContentArr:[FAQContent] = [FAQContent]()
    
    // 우선순위
    func getFAQPriority() -> Int {
        return mFaqPriority
    }
    func setFAQPriority(priority:Int) {
        self.mFaqPriority = priority
    }
    // 제목
    func getFAQTitle() -> String {
        return mFAQTopTitle
    }
    func setFAQTitle(title:String) {
        self.mFAQTopTitle = title
    }
    // 내용
    func getFAQContentArr() -> [FAQContent] {
        return mFAQContentArr
    }
    func setFAQContentArr(contentArr:[FAQContent]) {
        self.mFAQContentArr = contentArr
    }
}
