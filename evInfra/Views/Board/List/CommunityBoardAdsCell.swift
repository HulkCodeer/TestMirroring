//
//  CommunityBoardAdsCell.swift
//  evInfra
//
//  Created by PKH on 2022/03/02.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SDWebImage

class CommunityBoardAdsCell: UITableViewCell {
    
    @IBOutlet weak var adsProfileImageView: UIImageView!
    @IBOutlet weak var adsTitleLabel: UILabel!
    @IBOutlet weak var adsDescriptionLabel: UILabel!
    @IBOutlet weak var adsImageView: UIImageView!
    
    internal var category: Board.CommunityType = .FREE
    
    private var adUrl: String? = ""
    private var adId: String? = ""
    private var item: BoardListItem? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        adsProfileImageView.sd_cancelCurrentImageLoad()
        adsProfileImageView.image = nil
        adsImageView.sd_cancelCurrentImageLoad()
        adsImageView.image = nil
    }
    
    private func setUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL))
        adsImageView.addGestureRecognizer(tapGesture)
        adsImageView.isUserInteractionEnabled = true
        
        adsProfileImageView.layer.cornerRadius = adsProfileImageView.frame.height/2
    }
    
    func configuration(item: BoardListItem) {
        self.item = item
        adsProfileImageView.sd_setImage(with: URL(string: "\(Const.AWS_IMAGE_SERVER)/\(item.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))
        adsTitleLabel.text = item.nick_name
        adsDescriptionLabel.text = "advertisement"
        adsImageView.sd_setImage(with: URL(string: "\(Const.AWS_IMAGE_SERVER)/\(item.cover_filename ?? "")")) { (_, _, _, _) in
            let page: Promotion.Page = Board.CommunityType.convertToEventKey(communityType: self.category)
            EIAdManager.sharedInstance.logEvent(adIds: [item.document_srl ?? ""], action: .view, page: page, layer: .mid)
        }
        adUrl = item.module_srl
        adId = item.document_srl
    }
    
    @objc private func openURL() {
        guard let adUrl = adUrl else {
            return
        }
        
        if let url = URL(string: adUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                let page: Promotion.Page = Board.CommunityType.convertToEventKey(communityType: category)
                EIAdManager.sharedInstance.logEvent(adIds: [adId ?? ""], action: Promotion.Action.click, page: page, layer: .mid)
                
                guard let item = self.item else { return }
                let property: [String: Any] = ["bannerType": "게시판 배너",
                                               "adID": item.document_srl ?? "",
                                               "adName": item.title ?? ""]
                PromotionEvent.clickBanner.logEvent(property: property)
                
            }
        }
    }
}

