//
//  CommunityBoardTableViewHeader.swift
//  evInfra
//
//  Created by PKH on 2022/01/07.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import SnapKit
import TTGTags

protocol CommunityBoardTableViewHeaderDelegate: AnyObject {
    func didSelectTag(_ selectedType: Board.SortType)
}

class CommunityBoardTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var bannerCollectionView: UICollectionView!
    
    private let pageControl = UIPageControl()
    private lazy var tagCollectionView = TTGTextTagCollectionView()
    private lazy var boardSubscriptionLabel: UILabel = {
       let label = UILabel()
        label.text = "자유롭게 이야기를 나누어요."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "nt-5")
        return label
    }()
    
    weak var delegate: CommunityBoardTableViewHeaderDelegate?
    
    private var tags: [String] = []
    private let images = ["adCommunity01.png", "adCommunity02.png"]

    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setUI() {
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

    func setupBannerView(categoryType: String) {

        var description = ""
        switch categoryType {
        case Board.CommunityType.FREE.rawValue:
            description = "자유롭게 이야기를 나누어요."
            setupTagCollectionViewLayout()
            break
        case Board.CommunityType.CHARGER.rawValue:
            description = "충전소 관련 이야기를 모아봐요."
            setRemakeSubscriptionLabel()
            break
        case Board.CommunityType.CORP_GS.rawValue:
            description = "GS칼텍스 전용 게시판입니다."
            setRemakeSubscriptionLabel()
            break
        case Board.CommunityType.CORP_JEV.rawValue:
            description = "제주전기차서비스 전용 게시판입니다."
            setRemakeSubscriptionLabel()
            break
        case Board.CommunityType.CORP_STC.rawValue:
            description = "에스트래픽 전용 게시판입니다."
            setRemakeSubscriptionLabel()
            break
        case Board.CommunityType.CORP_SBC.rawValue:
            description = "EV Infra에 의견을 전달해 보세요."
            setRemakeSubscriptionLabel()
            break
        default:
            break
        }
        
        boardSubscriptionLabel.text = description
    }
    
    func setSubscriptionLabel() {
        self.addSubview(boardSubscriptionLabel)
        
        boardSubscriptionLabel.snp.makeConstraints {
            $0.top.equalTo(bannerCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-50)
            $0.height.equalTo(16)
        }
    }
    
    func setPageControll() {
        self.addSubview(pageControl)
        
        pageControl.numberOfPages = images.count
        pageControl.currentPageIndicatorTintColor = .lightGray
        pageControl.pageIndicatorTintColor = .white
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(bannerCollectionView.snp.top).offset(55)
            $0.centerX.equalTo(self)
            $0.bottom.equalTo(bannerCollectionView.snp.bottom).offset(-15)
        }
    }
    
    func setupTagCollectionViewLayout() {
        self.addSubview(tagCollectionView)
        
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(boardSubscriptionLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setRemakeSubscriptionLabel() {
        boardSubscriptionLabel.snp.remakeConstraints {
            $0.top.equalTo(bannerCollectionView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(16)
        }
    }
    
    func setSelectedPage(currentPage: Int) {
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
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell else { return UICollectionViewCell.init() }
        
        cell.bannerImageView.image = UIImage(named: images[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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


