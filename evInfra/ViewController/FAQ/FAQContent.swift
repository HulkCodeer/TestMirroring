//
//  FAQContent.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/09/06.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import Material
import Foundation
public class FAQContent {
    var mComment:String = ""
    var mImgName:String = ""
    
    func getComment() -> String?{
        return self.mComment
    }
    func setComment(comment:String?) {
        self.mComment = comment ?? ""
    }
    
    func getImgName() -> String?{
        return self.mImgName
    }
    func setImgName(imgName:String?) {
        self.mImgName = imgName ?? ""
    }
}
