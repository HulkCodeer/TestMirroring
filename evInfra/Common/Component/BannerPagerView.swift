//
//  BannerPagerView.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/09/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import FSPagerView

internal final class BannerPagerView: FSPagerView {
    
    // MARK: - UI
    
    private lazy var indicatorView = UIView().then {
        $0.backgroundColor = Colors.backgroundAlwaysDark.color.withAlphaComponent(0.4)
        $0.layer.borderWidth = 0
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
        $0.isHidden = true
    }
    
    private lazy var indicatorLabel = UILabel().then {
        $0.textColor = Colors.backgroundPrimary.color
        $0.textAlignment = .center
        $0.fontSize = 12
    }
    
    // MARK: - VARIABLE
    
    internal var banners: [AdsInfo] = [AdsInfo]() {
        didSet {
            let isHidden = banners.count == 0 ? true : false
            self.indicatorView.isHidden = isHidden
            self.indicatorLabel.isHidden = isHidden
            self.indicatorLabel.text = "\(self.bannerIndex) / \(banners.count)"
            self.automaticSlidingInterval = isHidden ? 0.0 : 4.0
            self.isScrollEnabled = !isHidden
        }
    }
    
    internal var promotionPage: Promotion.Page = .free
    private var promotionLayer: Promotion.Layer = .top
    private var bannerIndex: Int = 1
    
    // MARK: - SYSTEM FUNC
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(_ layer: Promotion.Layer) {
        super.init(frame: .zero)
        
        self.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.width.equalTo(42)
            $0.height.equalTo(22)
            $0.trailing.equalTo(self.snp.trailing).offset(-10)
            $0.bottom.equalTo(self.snp.bottom).offset(-8)
        }
        
        self.addSubview(indicatorLabel)
        indicatorLabel.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.top.equalTo(indicatorView.snp.top).offset(2)
            $0.leading.equalTo(indicatorView.snp.leading).offset(8)
            $0.trailing.equalTo(indicatorView.snp.trailing).offset(-8)
            $0.bottom.equalTo(indicatorView.snp.bottom).offset(-2)
        }
        
        self.register(NewBannerCollecionViewCell.self, forCellWithReuseIdentifier: "NewBannerCollecionViewCell")
        self.delegate = self
        self.dataSource = self
        self.isInfinite = true
        self.isScrollEnabled = true
        self.automaticSlidingInterval = 4.0
        self.layer.masksToBounds = true
        self.backgroundColor = .clear
        
        switch layer {
        case .top:
            self.promotionLayer = layer
            self.layer.cornerRadius = 8
        default: break
        }
    }
    
    internal func configure(page: Promotion.Page, banners: [AdsInfo]) {
        self.promotionPage = page
        self.banners = banners
    }
}

// MARK: - FSPagerView Delegate
extension BannerPagerView: FSPagerViewDelegate {
    internal func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        guard !banners.isEmpty else { return }

        let banner = banners[index]
        // 배너 클릭 로깅
        EIAdManager.sharedInstance.logEvent(adIds: [banner.evtId], action: .click, page: promotionPage, layer: promotionLayer)
        self.logEvent(with: .clickBanner, banner: banner)
        // open url
        let adUrl = banner.extUrl
        guard let url = URL(string: adUrl), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    internal func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.bannerIndex = targetIndex + 1
        self.indicatorLabel.text = "\(self.bannerIndex) / \(banners.count)"
    }
    
    internal func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.bannerIndex = pagerView.currentIndex + 1
        self.indicatorLabel.text = "\(self.bannerIndex) / \(banners.count)"
    }
}

// MARK: - FSPagerView DataSource
extension BannerPagerView: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count == 0 ? 1 : banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: "NewBannerCollecionViewCell", at: index) as? NewBannerCollecionViewCell else { return FSPagerViewCell() }
        
        guard !banners.isEmpty else {
            cell.bannerImageView.image = UIImage(named: "adCommunity01.png")
            return cell
        }

        let banner = banners[index]
        cell.bannerImageView.sd_setImage(with: URL(string: "\(Const.AWS_IMAGE_SERVER)/\(banner.img)"), placeholderImage: UIImage(named: "adCommunity01.png")) { (image, error, _, _) in
            if let _ = error {
                cell.bannerImageView.image = UIImage(named: "adCommunity01.png")
            } else {
                cell.bannerImageView.image = image
                EIAdManager.sharedInstance.logEvent(adIds: [banner.evtId], action: .view, page: self.promotionPage, layer: self.promotionLayer)
            }
        }
        return cell
    }
}

// MARK: - Amplitude Logging 이벤트
extension BannerPagerView {
    private func logEvent(with event: EventType.PromotionEvent, banner: AdsInfo) {
        switch event {
        case .clickBanner:
            var bannerType: String = ""
            switch self.promotionLayer {
            case .top:
                bannerType = "상단배너"
            case .bottom where self.promotionPage == .start:
                bannerType = "시작배너"
            case .mid:
                bannerType = "중간배너"
            default: break
            }
            
            let property: [String: Any] = ["bannerType": bannerType,
                                           "adID": banner.evtId,
                                           "adName": banner.evtTitle]
            AmplitudeManager.shared.logEvent(type: .promotion(event), property: property)
        default: break
        }
    }
}
