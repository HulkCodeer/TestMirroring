//
//  CompanyTableViewCell.swift
//  evInfra
//
//  Created by SH on 2021/08/24.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
protocol CompanyTableCellDelegate {
    func onClickTag(tagName: String, value: Bool)
}
class CompanyTableViewCell: UITableViewCell {
    
    @IBOutlet var groupTitle: UILabel!
    @IBOutlet var tagView: DynamicCollectionView!
    
    var delegate: CompanyTableCellDelegate?
    var tagList = Array<TagValue>()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tagView.collectionViewLayout = TagFlowLayout()
        tagView.register(UINib(nibName: "TagListViewCell", bundle: nil), forCellWithReuseIdentifier: "tagListViewCell")
        self.autoresizingMask = UIViewAutoresizing.flexibleHeight
        tagView.delegate = self
        tagView.dataSource = self
        tagView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func getCellHeight() -> CGFloat {
        return tagView.collectionViewLayout.collectionViewContentSize.height
    }
}


// MARK: - Collectionview Methods
extension CompanyTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagListViewCell", for: indexPath) as! TagListViewCell
        cell.cellConfig(arrData: tagList, index: indexPath.row)
        cell.delegateTagClick = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath : IndexPath) -> CGSize {
        let strText = tagList[indexPath.row].title
        return self.getInteresticSize(strText: strText)
    }
    
    func getInteresticSize(strText:String)-> CGSize{
        let nsStr = strText as NSString
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = nsStr.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
        let imgSize = 24
        
        return CGSize(width: labelSize.width + 8 + CGFloat(imgSize), height: labelSize.height + 8)
    }
}



extension CompanyTableViewCell: DelegateTagListViewCell{
    func tagClicked(index: Int, value: Bool) {
        // tag selected
        if let delegate = self.delegate {
            delegate.onClickTag(tagName: tagList[index].title, value: value)
        }
    }
}

class DynamicCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }
}
