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
    
    // MARK: UI
        
    private lazy var dimmedViewBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private lazy var headerTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = Colors.backgroundAlwaysDark.color
        $0.backgroundColor = Colors.backgroundPrimary.color
        $0.textAlignment = .center
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(BottomSheetCell.self, forCellReuseIdentifier: "cell")
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 55
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
    
    private lazy var safeAreaBottomView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    // MARK: VARIABLE
    internal var headerTitleStr: String = ""
    internal var selectedCompletion: ((Int) -> Void)?
    internal var items: [String] = []
    
    private let disposebag = DisposeBag()
    private let safeAreaInsetBottomHeight = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    
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
            $0.bottom.equalToSuperview().offset(52 + 1 + (55 * items.count) + Int(safeAreaInsetBottomHeight))
        }
        
        headerTitleLbl.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        let line = self.createLineView()
        line.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        tableView.snp.makeConstraints {
            $0.height.lessThanOrEqualTo(55 * items.count)
        }
        
        safeAreaBottomView.snp.makeConstraints {
            $0.height.equalTo(safeAreaInsetBottomHeight)
        }
                        
        totalStackView.addArrangedSubview(headerTitleLbl)
        totalStackView.addArrangedSubview(line)
        totalStackView.addArrangedSubview(tableView)
        totalStackView.addArrangedSubview(safeAreaBottomView)
        
        headerTitleLbl.text = self.headerTitleStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dimmedViewBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
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

        cell.configure(with: items[indexPath.row])
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCompletion?(indexPath.row)
    }
}

internal final class BottomSheetCell: UITableViewCell {
    private lazy var label = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .left
        $0.textColor = Colors.contentSecondary.color
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private lazy var containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
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
        containerView.addSubview(label)
        contentView.addSubview(containerView)
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().offset(-14)
            $0.trailing.equalToSuperview()
        }
        
        let line = self.createLineView()
        containerView.addSubview(line)
        line.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    internal func configure(with title: String) {
        label.text = title
    }
    
    private func createLineView(color: UIColor? = Colors.borderOpaque.color) -> UIView {
        UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = color
        }
    }
}
