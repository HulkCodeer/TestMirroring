//
//  Extension.swift
//  evInfra
//
//  Created by PKH on 2022/01/19.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import PanModal
import SnapKit

class GroupViewController: UITableViewController {
    
    var members: [String] = []
    var selectedCompletion: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    // MARK: - View Configurations
    func setupTableView() {

        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor(named: "nt-white")
        tableView.register(GroupMemeberCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? GroupMemeberCell
            else { return UITableViewCell() }

        cell.configure(with: members[indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCompletion?(indexPath.row)
//        self.dismiss(animated: true, completion: nil)
    }
}

extension GroupViewController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panScrollable: UIScrollView? {
        return tableView
    }
}

class GroupMemeberCell: UITableViewCell {
    let label: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "nt-9")
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    lazy var containerView: UIView = {
       let view = UIView()
        return view
    }()
    
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
