//
//  NewGroupViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/06/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReusableKit
import RxSwift

internal final class NewBottomSheetViewController: CommonBaseViewController {
    
    enum Consts {
        static let nextBtnTotalHeight = 80
        static let nextBtnHeight = 48
        static let headerTitleHeight = 52
        static let cellHeight = 48.0
    }
    
    // MARK: UI
        
    private lazy var dimmedViewBtn = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private lazy var headerTitleLbl = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = Colors.backgroundAlwaysDark.color
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.textAlignment = .center
    }
    
    private lazy var tableView = UITableView().then {
        $0.register(BottomSheetCell.self, forCellReuseIdentifier: "cell")
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = Consts.cellHeight
        $0.allowsSelection = true
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var nextBtnTotalView = UIView()
    
    private lazy var nextBtn = RectButton(level: .primary).then {
        $0.setTitle("다음", for: .normal)
        $0.setTitle("다음", for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.IBcornerRadius = 9
        $0.isEnabled = false
    }
    
    private lazy var safeAreaBottomView = UIView().then {
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    // MARK: VARIABLE
    internal var headerTitleStr: String = ""
    internal var selectedCompletion: ((Int) -> Void)?
    internal var nextBtnCompletion: ((Int) -> Void)?
    internal var dimmedViewBtnCompletion: (() -> Void)?
    internal var items: [String] = []
    
    private var selectedIndex: Int = -1 {
        didSet {
            nextBtn.isEnabled = selectedIndex != -1
        }
    }
    private let disposebag = DisposeBag()
    private let safeAreaInsetBottomHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    private var selectedCellCompletion: ((Int) -> Void)?
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.contentView.backgroundColor = .clear
        
                                
        self.view.addSubview(dimmedViewBtn)
        dimmedViewBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.lessThanOrEqualTo(UIScreen.main.bounds.size.height/2)
            let animationBottomMargin = Consts.headerTitleHeight + (Int(Consts.cellHeight) * items.count) + Int(Float(safeAreaInsetBottomHeight)) + (self.nextBtnCompletion != nil ? Consts.nextBtnTotalHeight:0)
            $0.bottom.equalToSuperview().offset(animationBottomMargin)
        }
        
        headerTitleLbl.snp.makeConstraints {
            $0.height.equalTo(Consts.headerTitleHeight)
        }
                        
        tableView.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(Int(Consts.cellHeight) * items.count)
        }
        
        safeAreaBottomView.snp.makeConstraints {
            $0.height.equalTo(safeAreaInsetBottomHeight)
        }
                        
        totalStackView.addArrangedSubview(headerTitleLbl)
        totalStackView.addArrangedSubview(tableView)
        totalStackView.addArrangedSubview(safeAreaBottomView)
        
        headerTitleLbl.text = self.headerTitleStr
        
        guard let _nextBtnCompletion = self.nextBtnCompletion else { return }
        totalStackView.addArrangedSubview(nextBtnTotalView)
        nextBtnTotalView.snp.makeConstraints {
            $0.height.equalTo(Consts.nextBtnTotalHeight)
        }
        
        nextBtnTotalView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(Consts.nextBtnHeight)
            $0.centerY.equalToSuperview()
        }
        
        nextBtn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                _nextBtnCompletion(self.selectedIndex)
            })
            .disposed(by: self.disposebag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedCellCompletion = { [weak self] index in
            guard let self = self else { return }
            
            if let _selectedCompletion = self.selectedCompletion {
                _selectedCompletion(index)
            } else {
                self.selectedIndex = index
                self.tableView.reloadData()
            }
        }
        
        dimmedViewBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dimmedViewBtnCompletion?()
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            })
            .disposed(by: self.disposebag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0 , options: .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }
            let translationY = self.totalStackView.frame.height
            self.totalStackView.transform = CGAffineTransform(translationX: 0, y:  translationY * (-1))
        }, completion: nil)
    }
}

extension NewBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BottomSheetCell
            else { return UITableViewCell() }
        
        cell.configure(index: indexPath.row, title: items[indexPath.row], selectedCellCompletion: self.selectedCellCompletion, isSelected: self.selectedIndex == indexPath.row)
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Consts.cellHeight
    }
}

internal final class BottomSheetCell: UITableViewCell {
    
    // MARK: - UI
    
    private lazy var containerView = UIView()
    
    private lazy var label = UILabel().then {
        $0.textAlignment = .left
        $0.textColor = Colors.contentSecondary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var checkImgView = UIImageView().then {
        $0.image = Icons.iconCheckMd.image
        $0.tintColor = Colors.contentPositive.color
    }
    
    private lazy var totalTapBtn = UIButton()
    
    // MARK: - VARIABLE
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.makeUI()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
            
    private func makeUI() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().offset(-14)
            $0.trailing.equalToSuperview()
        }
                        
        containerView.addSubview(checkImgView)
        checkImgView.snp.makeConstraints {
            $0.centerY.equalTo(label.snp.centerY)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        containerView.addSubview(totalTapBtn)
        totalTapBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func configure(index: Int, title: String, selectedCellCompletion: ((Int) -> Void)?, isSelected: Bool) {
        label.text = title
        
        checkImgView.isHidden = !isSelected
        totalTapBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                selectedCellCompletion?(index)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func createLineView(color: UIColor? = Colors.borderOpaque.color) -> UIView {
        UIView().then {
            
            $0.backgroundColor = color
        }
    }
}
