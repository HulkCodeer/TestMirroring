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
    private var bannerPagerView: BannerPagerView = BannerPagerView(.top)
    private lazy var tagCollectionView: TTGTextTagCollectionView = TTGTextTagCollectionView()
    
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
            bannerPagerView.promotionPage = Board.CommunityType.convertToEventKey(communityType: self.boardType)
            fetchAds()
            setupBannerView()
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.tags = ["최신", "인기"]
        
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
            self.bannerPagerView.banners = topBanners
            
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
