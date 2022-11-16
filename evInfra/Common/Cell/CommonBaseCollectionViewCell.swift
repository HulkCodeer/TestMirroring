//
//  CommonBaseCollectionViewCell.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/09/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift

internal class CommonBaseCollectionViewCell: UICollectionViewCell {
    internal lazy var totalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    internal var cellDisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellDisposeBag = DisposeBag()
    }

    override var bounds: CGRect {
        didSet {
            self.contentView.frame = self.bounds
        }
    }

    internal func makeUI() {
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
