//
//  TagListViewCell.swift
//  evInfra
//
//  Created by SH on 2021/08/04.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import Foundation
import UIKit
open class TagValue {
    var title: String = ""
    var img: String = ""
    var selected: Bool = false
    init(title: String, img: String, selected: Bool){
        self.title = title
        self.img = img
        self.selected = selected
    }
}

protocol DelegateTagListViewCell {
    func tagClicked(index: Int)
}
class TagListViewCell : UICollectionViewCell {
    var delegateTagClick : DelegateTagListViewCell?
    var position : Int = 0
    var select : Bool = false
    var tagValue : TagValue?
    
    var tagImage : UIImage?
    
    @IBOutlet var tagImg: UIImageView!
    @IBOutlet var tagStr: UILabel!
    @IBOutlet var tagContainer: UIView!
    @IBOutlet var tagView: UIStackView!
    
    // MARK: - Life cycle method
    override func awakeFromNib() {
        super.awakeFromNib()
        tagContainer.layer.backgroundColor = UIColor(named: "background-secondary")?.cgColor
        tagContainer.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
        tagContainer.layer.borderWidth = 1.0
        tagContainer.layer.cornerRadius = tagContainer.frame.height/2
        
        tagStr.textColor = UIColor(named: "content-primary")
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.onClickTag (_:)))
        tagView.addGestureRecognizer(gesture)
    }

    func cellConfig(arrData : Array<TagValue> , index : Int){
        tagValue = arrData[index]
        position = index
        select = arrData[index].selected
        tagStr.text = arrData[index].title
        tagStr.sizeToFit()
        if(!arrData[index].img.isEmpty){
            tagImg.isHidden = false
            tagImg.image = UIImage(named: arrData[index].img)?.tint(with: UIColor.black)
        }
    }
    
    @objc func onClickTag(_ sender:UITapGestureRecognizer){
        select = !select
        setTagSelected(selected: select)
        delegateTagClick?.tagClicked(index: position)
    }
    
    func setTagSelected(selected: Bool) {
        select = selected
        if(selected){
            tagContainer.layer.borderWidth = 0.0
            tagContainer.layer.backgroundColor = UIColor(named: "content-positive")?.cgColor
            tagImg.image = UIImage(named: tagValue!.img)?.tint(with: UIColor(named: "content-on-color")!)
            tagStr.textColor = UIColor(named: "content-on-color")
        } else {
            tagContainer.layer.backgroundColor = UIColor(named: "background-secondary")?.cgColor
            tagContainer.layer.borderColor = UIColor(named: "border-opaque")?.cgColor
            tagContainer.layer.borderWidth = 1.0
            tagImg.image = UIImage(named: tagValue!.img)?.tint(with: UIColor(named: "content-primary")!)
            tagStr.textColor = UIColor(named: "content-primary")
        }
    }
    
    func getInteresticSize(strText:String,cv:UICollectionView,imgShow:Bool)-> CGSize{
        let font = (Name:tagStr.font.fontName,Size:tagStr.font.pointSize)
        let textSize = tagStr.textSize(font: UIFont(name: font.Name, size: font.Size)!, text: strText)
        let imgSize:CGFloat = tagImg.image!.width

        // 50 - Label Padding
        if textSize.width + 16 >= cv.frame.size.width{
            let height = tagStr.heightForView(text: strText, font: UIFont(name: font.Name, size: font.Size+1)!, width: cv.frame.size.width - 15)
            return CGSize(width: cv.frame.size.width + CGFloat(imgSize), height: height + 8)
        }else{
            return CGSize(width: textSize.width + 16 + CGFloat(imgSize), height: textSize.height + 8)
        }
    }
}
