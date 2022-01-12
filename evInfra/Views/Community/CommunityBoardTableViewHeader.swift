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
    func didSelectTag(_ selectedIndex: Int)
}

class CommunityBoardTableViewHeader: UIView {
    
    @IBOutlet var bannerCollectionView: UICollectionView!
    @IBOutlet var boardSubscriptionLabel: UILabel!
    
    private let pageControl = UIPageControl()
    
    private lazy var tagCollectionView = TTGTextTagCollectionView()
    private weak var delegate: CommunityBoardTableViewHeaderDelegate?
    
    private var tags: [String] = ["최신", "인기"]
    let images = ["adCommunity01.png", "adCommunity02.png"]

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupBannerView() {
        bannerCollectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        bannerCollectionView.dataSource = self
        bannerCollectionView.delegate = self
    }
    
    func setPageControll() {
        pageControl.numberOfPages = images.count
        pageControl.currentPageIndicatorTintColor = .lightGray
        pageControl.pageIndicatorTintColor = .white
        self.addSubview(pageControl)
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(bannerCollectionView.snp.top).offset(55)
            $0.centerX.equalTo(self)
            $0.bottom.equalTo(bannerCollectionView.snp.bottom).offset(-15)
        }
    }
    
    func setupTagCollectionViewLayout() {
        self.addSubview(tagCollectionView)
        
        tagCollectionView.snp.makeConstraints {
            $0.top.equalTo(boardSubscriptionLabel.snp.bottom
            ).offset(16)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
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
//        guard tag.selected else { return }
        
        if index == 0 {
            if tag.selected {
                
            } else {
                tag.selected = !tag.selected
            }
        } else {
            
        }
            
        debugPrint("\(Int(index)) tag \(tag.selected)")
        delegate?.didSelectTag(Int(index))
        
        debugPrint("delegete : select tag \(Int(index))")
    }
}

extension CommunityBoardTableViewHeader {
    func setupTagCollectionView() {
        tagCollectionView.delegate = self
        tagCollectionView.numberOfLines = 1
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
        let extraSpace = CGSize(width: 24, height: 14)

        let style = TTGTextTagStyle()
        style.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        style.cornerRadius = cornerRadiusValue
        style.borderWidth = 0.0
        style.shadowOpacity = shadowOpacity
        style.extraSpace = extraSpace
        // bordercolor 정의

        let selectedStyle = TTGTextTagStyle()
        selectedStyle.backgroundColor = .black
        selectedStyle.cornerRadius = cornerRadiusValue
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
    }
}

class BannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var bannerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerImageView.layer.cornerRadius = 16
    }
}


