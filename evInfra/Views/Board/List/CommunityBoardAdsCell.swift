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
    
    private var adUrl: String? = ""
    private var adId: String? = ""
    
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
        adsProfileImageView.sd_setImage(with: URL(string: "\(Const.AWS_IMAGE_SERVER)/\(item.mb_profile ?? "")"), placeholderImage: UIImage(named: "ic_person_base36"))
        adsTitleLabel.text = item.nick_name
        adsDescriptionLabel.text = "advertisement"
        adsImageView.sd_setImage(with: URL(string: "\(Const.AWS_IMAGE_SERVER)/\(item.cover_filename ?? "")")) { (_, _, _, _) in
            EIAdManager.sharedInstance.logEvent(adIds: [item.document_srl ?? ""], action: .view, page: .free, layer: .mid)
        }
        adUrl = item.title
        adId = item.document_srl
    }
    
    @objc private func openURL() {
        guard let adUrl = adUrl else {
            return
        }
        
        if let url = URL(string: adUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                EIAdManager.sharedInstance.logEvent(adIds: [adId ?? ""], action: Promotion.Action.click, page: Promotion.Page.event, layer: Promotion.Layer.mid)
            }
        }
    }
}
