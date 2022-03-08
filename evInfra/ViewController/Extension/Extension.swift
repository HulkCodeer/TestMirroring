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
import Material
import AVFoundation

extension UIViewController {
    func prepareActionBar(with title: String) {
        navigationController?.isNavigationBarHidden = false
        
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "nt-9")
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.titleLabel.text = title
    }
    
    @objc
    func backButtonTapped() {
        self.navigationController?.pop()
    }
}

class BaseViewController: UIViewController {
    let picker = UIImagePickerController()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
       let activitiIndicator = UIActivityIndicatorView()
        activitiIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activitiIndicator.center = self.view.center
        
        
        activitiIndicator.color = UIColor(named: "nt-5")
        activitiIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activitiIndicator.activityIndicatorViewStyle = .large
        } else {
            // Fallback on earlier versions
        }
        
        activitiIndicator.stopAnimating()
        
        return activitiIndicator
    }()
    
    // 공통
    func openPhotoLib() {
        picker.sourceType = .photoLibrary
        self.present(picker, animated: false, completion: nil)
    }
    
    // 공통
    func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined || status == .denied {
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { grated in
                if !grated {
                    self.showAuthAlert()
                }
            }
        } else if status == .authorized {
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // 공통
    private func showAuthAlert() {
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            Snackbar().show(message: "카메라 기능이 활성화되지 않았습니다.")
            self.navigationController?.pop()
        }
        
        let openAction = UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        var actions = Array<UIAlertAction>()
        actions.append(cancelAction)
        actions.append(openAction)
        
        UIAlertController.showAlert(title: "카메라 기능이 활성화되지 않았습니다.", message: "사진추가를 위해 카메라 권한이 필요합니다.", actions: actions)
    }
}

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
        tableView.isScrollEnabled = false
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
        return 55.0
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCompletion?(indexPath.row)
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
