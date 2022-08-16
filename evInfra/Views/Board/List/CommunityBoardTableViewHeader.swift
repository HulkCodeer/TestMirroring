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

protocol CommunityBoardTableViewHeaderDelegate: AnyObject {
    func didSelectTag(_ selectedType: Board.SortType)
}

internal final class CommunityBoardTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var bannerCollectionView: UICollectionView!
    
    private let pageControl = UIPageControl()
    private lazy var tagCollectionView = TTGTextTagCollectionView()
    private lazy var boardSubscriptionLabel = UILabel().then {
        $0.text = "자유롭게 이야기를 나누어요."
        $0.textColor = Colors.nt5.color
        $0.font = .systemFont(ofSize: 12, weight: .regular)
    }
    
    weak var delegate: CommunityBoardTableViewHeaderDelegate?
    
    private var tags: [String] = []
    private var adManager = EIAdManager.sharedInstance
    private var topBanners: [AdsInfo] = [AdsInfo]()
    internal var boardType: String = Board.CommunityType.FREE.rawValue
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setUI() {
        self.bannerCollectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        self.bannerCollectionView.dataSource = self
        self.bannerCollectionView.delegate = self
        self.bannerCollectionView.layer.cornerRadius = 16
        self.bannerCollectionView.backgroundColor = .clear
        self.tags = ["최신", "인기"]
        
        setSubscriptionLabel()
        setupTagCollectionView()
        setPageControll()
    }
    
    internal func fetchAds(categoryType: Board.CommunityType) {
        let promotionPageType: Promotion.Page = Board.CommunityType.convertToEventKey(communityType: categoryType)
        
        adManager.getAdsList(page: promotionPageType, layer: .top) { topBanners in
            self.topBanners = topBanners
            
            DispatchQueue.main.async {
                self.bannerCollectionView.reloadData()
            }
        }
    }

    internal func setupBannerView(categoryType: Board.CommunityType) {
        var description = ""
        switch categoryType {
        case .FREE:
            description = "자유롭게 이야기를 나누어요."
            setupTagCollectionViewLayout()
        case .CHARGER:
            description = "충전소 관련 이야기를 모아봐요."
            setRemakeSubscriptionLabel()
        case .CORP_GS:
            description = "GS칼텍스 전용 게시판입니다."
            setRemakeSubscriptionLabel()
        case .CORP_JEV:
            description = "제주전기차서비스 전용 게시판입니다."
            setRemakeSubscriptionLabel()
        case .CORP_STC:
            description = "에스트래픽 전용 게시판입니다."
            setRemakeSubscriptionLabel()
        case .CORP_SBC:
            description = "EV Infra에 의견을 전달해 보세요."
            setRemakeSubscriptionLabel()
        default:
            break
        }
        
        boardSubscriptionLabel.text = description
    }
    
    private func setSubscriptionLabel() {
        self.addSubview(boardSubscriptionLabel)
        
        boardSubscriptionLabel.snp.makeConstraints {
            $0.top.equalTo(bannerCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-50)
            $0.height.equalTo(16)
        }
    }
    
    private func setPageControll() {
        self.addSubview(pageControl)
        
        pageControl.numberOfPages = topBanners.count
        pageControl.currentPageIndicatorTintColor = .lightGray
        pageControl.pageIndicatorTintColor = .white
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(bannerCollectionView.snp.top).offset(55)
            $0.centerX.equalTo(self)
            $0.bottom.equalTo(bannerCollectionView.snp.bottom).offset(-15)
        }
    }
    
    private func setupTagCollectionViewLayout() {
        self.addSubview(tagCollectionView)
        
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(boardSubscriptionLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setRemakeSubscriptionLabel() {
        boardSubscriptionLabel.snp.updateConstraints {
            $0.top.equalTo(bannerCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(16)
        }
    }
    
    private func setSelectedPage(currentPage: Int) {
        pageControl.currentPage = currentPage
    }
}

extension CommunityBoardTableViewHeader: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        setSelectedPage(currentPage: Int(round(value)))
    }
}

extension CommunityBoardTableViewHeader: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 68)
    }
}

extension CommunityBoardTableViewHeader: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topBanners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell else { return UICollectionViewCell.init() }
        let banner = topBanners[indexPath.row]
        cell.bannerImageView.sd_setImage(with: URL(string: "\(Const.AWS_SERVER)/image/\(String(describing: topBanners[indexPath.row].img))")) { (image, error, _, _) in
            if let _ = error {
                cell.bannerImageView.image = UIImage(named: "")
            } else {
                cell.bannerImageView.image = image
                self.adManager.logEvent(adIds: [banner.evtId], action: .view, page: .free, layer: .top)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let banner = topBanners[indexPath.row]
        // 배너 클릭 로깅
        adManager.logEvent(adIds: [banner.evtId], action: .click, page: .free, layer: .top)
        // open url
        let adUrl = banner.extUrl
        guard let url = URL(string: adUrl), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

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

extension CommunityBoardTableViewHeader {
    func setupTagCollectionView() {
        tagCollectionView.delegate = self
        tagCollectionView.numberOfLines = 1
        tagCollectionView.selectionLimit = 1
        tagCollectionView.alignment = .left
        tagCollectionView.scrollDirection = .horizontal
        tagCollectionView.showsHorizontalScrollIndicator = false
        tagCollectionView.showsVerticalScrollIndicator = false

        tagCollectionView.contentInset = UIEdgeInsets(
            top: 1,
            left: 0,
            bottom: 1,
            right: 8.0
        )

        let cornerRadiusValue: CGFloat = 12.0
        let shadowOpacity: CGFloat = 0.0
        let extraSpace = CGSize.init(width: 24, height: 14)

        let style = TTGTextTagStyle()
        style.backgroundColor = UIColor(named: "nt-0")!
        style.cornerRadius = cornerRadiusValue
        style.borderWidth = 1
        style.shadowOpacity = shadowOpacity
        style.extraSpace = extraSpace
        style.borderColor = UIColor(named: "nt-2")!

        let selectedStyle = TTGTextTagStyle()
        selectedStyle.backgroundColor = UIColor(named: "nt-9")!
        selectedStyle.cornerRadius = cornerRadiusValue
        selectedStyle.borderWidth = 0
        selectedStyle.shadowOpacity = shadowOpacity
        selectedStyle.extraSpace = extraSpace

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
}

class BannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var bannerImageView: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerImageView.layer.cornerRadius = 16
    }
}


