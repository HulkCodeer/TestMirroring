//
//  CommunityBoardTableViewHeader.swift
//  evInfra
//
//  Created by PKH on 2022/01/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import Then
import TTGTags
import SDWebImage
import FSPagerView

protocol CommunityBoardTableViewHeaderDelegate: AnyObject {
    func didSelectTag(_ selectedType: Board.SortType)
}

internal final class CommunityBoardTableViewHeader: UITableViewHeaderFooterView {
    
    // MARK: - UI
    private lazy var bannerPagerView: BannerPagerView = BannerPagerView(.top)
    private lazy var tagCollectionView: TTGTextTagCollectionView = TTGTextTagCollectionView()
    
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
    
    private lazy var boardSubscriptionLabel = UILabel().then {
        $0.text = "자유롭게 이야기를 나누어요."
        $0.textColor = Colors.nt5.color
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    // MARK: - VARIABLE
    weak var delegate: CommunityBoardTableViewHeaderDelegate?
    
    private var tags: [String] = []
    private var adManager = EIAdManager.sharedInstance
    private var topBanners: [AdsInfo] = [AdsInfo]()
    private var bannerIndex: Int = 1
    private var boardType: Board.CommunityType = .FREE {
        didSet {
            fetchAds()
            setupBannerView()
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.tags = ["최신", "인기"]

        bannerPagerView.register(NewBannerCollecionViewCell.self, forCellWithReuseIdentifier: "NewBannerCollecionViewCell")
        bannerPagerView.dataSource = self
        bannerPagerView.delegate = self
        
        let screenWidth = UIScreen.main.bounds.width - 32
        let imgViewHeight = (68 / 328) * screenWidth
        
        self.addSubview(bannerPagerView)
        bannerPagerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(screenWidth)
            $0.height.equalTo(imgViewHeight)
        }
        
        self.addSubview(boardSubscriptionLabel)
        boardSubscriptionLabel.snp.makeConstraints {
            $0.top.equalTo(bannerPagerView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-50)
            $0.height.equalTo(16)
        }
        
        self.addSubview(tagCollectionView)
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(boardSubscriptionLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        self.bannerPagerView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.width.equalTo(42)
            $0.height.equalTo(22)
            $0.trailing.equalTo(bannerPagerView.snp.trailing).offset(-10)
            $0.bottom.equalTo(bannerPagerView.snp.bottom).offset(-8)
        }
        
        self.indicatorView.addSubview(indicatorLabel)
        indicatorLabel.snp.makeConstraints {
            $0.height.equalTo(18)
            $0.top.equalTo(indicatorView.snp.top).offset(2)
            $0.leading.equalTo(indicatorView.snp.leading).offset(8)
            $0.trailing.equalTo(indicatorView.snp.trailing).offset(-8)
            $0.bottom.equalTo(indicatorView.snp.bottom).offset(-2)
        }
        
        let cornerRadiusValue: CGFloat = 12.0
        let shadowOpacity: CGFloat = 0.0
        let extraSpace = CGSize.init(width: 24, height: 14)

        let style = TTGTextTagStyle()
        style.backgroundColor = Colors.nt0.color
        style.cornerRadius = cornerRadiusValue
        style.borderWidth = 1
        style.shadowOpacity = shadowOpacity
        style.extraSpace = extraSpace
        style.borderColor = Colors.nt2.color

        let selectedStyle = TTGTextTagStyle()
        selectedStyle.backgroundColor = Colors.nt9.color
        selectedStyle.cornerRadius = cornerRadiusValue
        selectedStyle.borderWidth = 0
        selectedStyle.shadowOpacity = shadowOpacity
        selectedStyle.extraSpace = extraSpace
        
        tagCollectionView.delegate = self
        tagCollectionView.numberOfLines = 1
        tagCollectionView.selectionLimit = 1
        tagCollectionView.alignment = .left
        tagCollectionView.scrollDirection = .horizontal
        tagCollectionView.showsHorizontalScrollIndicator = false
        tagCollectionView.showsVerticalScrollIndicator = false
        tagCollectionView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 8.0)

        tags.forEach { tag in
            let font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
            let tagContents = TTGTextTagStringContent(
                text: tag,
                textFont: font,
                textColor: .black
            )
            let selectedTagContents = TTGTextTagStringContent(
                text: tag,
                textFont: font,
                textColor: .white
            )

            let tag = TTGTextTag(
                content: tagContents,
                style: style,
                selectedContent: selectedTagContents,
                selectedStyle: selectedStyle
            )

            tagCollectionView.addTag(tag)
        }
        
        tagCollectionView.updateTag(at: 0, selected: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configuration(with category: Board.CommunityType) {
        self.boardType = category
    }
    
    private func fetchAds() {
        let promotionPageType: Promotion.Page = Board.CommunityType.convertToEventKey(communityType: self.boardType)
        
        adManager.getAdsList(page: promotionPageType, layer: .top) { topBanners in
            self.topBanners = topBanners
            
            let isHidden = self.topBanners.count == 0 ? true : false
            self.indicatorView.isHidden = isHidden
            self.indicatorLabel.text = "\(self.bannerIndex) / \(topBanners.count)"
            self.bannerPagerView.automaticSlidingInterval = isHidden ? 0.0 : 4.0
            self.bannerPagerView.isScrollEnabled = !isHidden
            
            DispatchQueue.main.async {
                self.bannerPagerView.reloadData()
            }
        }
    }

    private func setupBannerView() {
        switch self.boardType {
        case .FREE:
            tagCollectionView.isHidden = false
        case .CHARGER, .CORP_GS, .CORP_JEV, .CORP_STC, .CORP_SBC:
            tagCollectionView.isHidden = true
            setRemakeSubscriptionLabel()
        default:
            break
        }
        
        boardSubscriptionLabel.text = self.boardType.description
    }
    
    private func setRemakeSubscriptionLabel() {
        boardSubscriptionLabel.snp.updateConstraints {
            $0.top.equalTo(bannerPagerView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(16)
        }
    }
}

// MARK: - FSPagerView Delegate
extension CommunityBoardTableViewHeader: FSPagerViewDelegate {
    internal func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        guard !topBanners.isEmpty else { return }
        
        let promotionPageType: Promotion.Page = Board.CommunityType.convertToEventKey(communityType: self.boardType)
        let banner = topBanners[index]
        // 배너 클릭 로깅
        adManager.logEvent(adIds: [banner.evtId], action: .click, page: promotionPageType, layer: .top)
        logEvent(with: .clickBanner, banner: banner)
        // open url
        let adUrl = banner.extUrl
        guard let url = URL(string: adUrl), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    internal func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.bannerIndex = targetIndex + 1
        self.indicatorLabel.text = "\(self.bannerIndex) / \(topBanners.count)"
    }
    
    internal func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.bannerIndex = pagerView.currentIndex + 1
        self.indicatorLabel.text = "\(self.bannerIndex) / \(topBanners.count)"
    }
}

// MARK: - FSPagerView DataSource
extension CommunityBoardTableViewHeader: FSPagerViewDataSource {
    internal func numberOfItems(in pagerView: FSPagerView) -> Int {
        return topBanners.count == 0 ? 1 : topBanners.count
    }
    
    internal func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = bannerPagerView.dequeueReusableCell(withReuseIdentifier: "NewBannerCollecionViewCell", at: index) as? NewBannerCollecionViewCell else { return FSPagerViewCell() }
        
        guard !topBanners.isEmpty else {
            cell.bannerImageView.image = UIImage(named: "adCommunity01.png")
            return cell
        }

        let banner = topBanners[index]
        cell.bannerImageView.sd_setImage(with: URL(string: "\(Const.AWS_IMAGE_SERVER)/\(banner.img)"), placeholderImage: UIImage(named: "adCommunity01.png")) { (image, error, _, _) in
            if let _ = error {
                cell.bannerImageView.image = UIImage(named: "adCommunity01.png")
            } else {
                cell.bannerImageView.image = image
                self.adManager.logEvent(adIds: [banner.evtId], action: .view, page: .free, layer: .top)
            }
        }
        return cell
    }
}

// MARK: - TTGTextTagCollecionView Delegate
extension CommunityBoardTableViewHeader: TTGTextTagCollectionViewDelegate {
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTap tag: TTGTextTag!, at index: UInt) {
        
        tag.selected = !tag.selected
        textTagCollectionView.updateTag(at: index, selected: true)
            
        let selectedIndex = Int(index)
        
        var type: Board.SortType = .LATEST
        Board.SortType.allCases.forEach {
            let index = Int($0.rawValue)
            if index == selectedIndex {
                type = $0
            }
        }
        
        delegate?.didSelectTag(type)
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, canTap tag: TTGTextTag!, at index: UInt) -> Bool {
        guard let allTags = textTagCollectionView.allTags() else { return false }
        
        for (index, _) in allTags.enumerated() {
            tagCollectionView.updateTag(at: UInt(index), selected: false)
        }
        
        return true
    }
}

// MARK: - Amplitude Logging 이벤트
extension CommunityBoardTableViewHeader {
    private func logEvent(with event: EventType.PromotionEvent, banner: AdsInfo) {
        switch event {
        case .clickBanner:
            let property: [String: Any] = ["bannerType": "상단배너",
                                           "adID": banner.evtId,
                                           "adName": banner.evtTitle]
            AmplitudeManager.shared.logEvent(type: .promotion(event), property: property)
        default: break
        }
    }
}

// MARK: - Banner Cell
internal final class NewBannerCollecionViewCell: FSPagerViewCell {
    internal lazy var bannerImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(bannerImageView)
        bannerImageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
