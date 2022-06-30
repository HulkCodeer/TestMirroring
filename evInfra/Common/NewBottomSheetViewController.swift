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

internal final class NewBottomSheetViewController: UIViewController {
    
    // MARK: UI
        
    private lazy var dimmedViewBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.backgroundOverlayDark.color
//        $0.backgroundColor = .purple
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(BottomSheetCell.self, forCellReuseIdentifier: "cell")
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 55
        $0.allowsSelection = false
        $0.allowsSelectionDuringEditing = false
        $0.isMultipleTouchEnabled = false
        $0.allowsMultipleSelection = false
        $0.allowsMultipleSelectionDuringEditing = false
        $0.contentInset = .zero
        $0.bounces = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    // MARK: VARIABLE
    
    internal var selectedCompletion: ((Int) -> Void)?
    internal var items: [String] = []
    
    private let disposebag = DisposeBag()
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = .clear
                        
        self.view.addSubview(dimmedViewBtn)
        dimmedViewBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dimmedViewBtn.rx.tap
            .asDriver()
            .drive(onNext: { _ in
                GlobalDefine.shared.mainNavi?.dismiss(animated: true)
            })
            .disposed(by: self.disposebag)
    }
}

extension NewBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? GroupMemeberCell
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
        $0.textColor = UIColor(named: "nt-9")
        $0.font = .systemFont(ofSize: 18, weight: .regular)
    }
    
    private lazy var containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        isAccessibilityElement = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.11)
        selectedBackgroundView = backgroundView
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        containerView.addSubview(label)
        contentView.addSubview(containerView)
        
        label.snp.makeConstraints {
            $0.margins.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.left.equalToSuperview().inset(16)
            $0.right.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure(with title: String) {
        label.text = title
    }
}
