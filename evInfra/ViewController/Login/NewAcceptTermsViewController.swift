//
//  NewAcceptTermsViewController.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReusableKit

internal final class NewAcceptTermsViewController: CommonBaseViewController {
    // MARK: UI
    
    private enum Reusable {
        static let acceptTermsCell = ReusableCell<AcceptTermsCell>(nibName: AcceptTermsCell.reuseID)
    }
    
    private lazy var naviTotalView = CommonNaviView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.naviTitleLbl.text = "회원 가입"
    }
    
    private lazy var mainTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "더 나은 충전 생활을 위해"
    }
    
    private lazy var subTitleLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
        $0.text = "아래와 같은 동의가 필요합니다."
    }
    
    private lazy var allAcceptTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var allAcceptCheckBtn = CheckBox().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private lazy var allAcceptTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .natural
        $0.numberOfLines = 2
        $0.textColor = Colors.contentPrimary.color
    }

    private lazy var allAcceptTitleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(Reusable.acceptTermsCell)
        $0.backgroundColor = UIColor.clear
        $0.separatorStyle = .none
        $0.rowHeight = UITableViewAutomaticDimension
        $0.estimatedRowHeight = 56
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
        
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(naviTotalView)
        naviTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        self.contentView.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(naviTotalView.snp.bottom).offset(24)
            $0.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(subTitleLbl)
        subTitleLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(mainTitleLbl.snp.bottom).offset(8)
            $0.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(allAcceptTotalView)
        allAcceptTotalView.snp.makeConstraints {
            $0.top.equalTo(subTitleLbl.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        allAcceptTotalView.addSubview(allAcceptCheckBtn)
        allAcceptCheckBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        allAcceptTotalView.addSubview(allAcceptTitleLabel)
        allAcceptTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(allAcceptCheckBtn.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
        }
        
        let lineView = self.createLineView()
        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.mainNavi?.navigationBar.isHidden = true
    }
}

extension NewAcceptTermsViewController: UITableViewDelegate, UITableViewDataSource {
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
    
//    @IBOutlet weak var cbAcceptAll: M13Checkbox!
//    @IBOutlet weak var cbUsingTerm: M13Checkbox!
//    @IBOutlet weak var cbPersonalInfo: M13Checkbox!
//    @IBOutlet weak var cbLocation: M13Checkbox!
//    @IBOutlet weak var ivNext: UIImageView!
//    @IBOutlet weak var cbMarketing: M13Checkbox!
//    @IBOutlet weak var cbAd: M13Checkbox!
//    @IBOutlet weak var cbContents: M13Checkbox!
//    @IBOutlet weak var btnNext: UIButton!
//    @IBOutlet weak var policyStackView: UIStackView!
//
//    @IBOutlet var usingTermBtn: UIButton!
//    @IBOutlet var personalTermBtn: UIButton!
//    @IBOutlet var locationTermBtn: UIButton!
//    @IBOutlet var marketingTermBtn: UIButton!
//
//
//    // MARK: VARIABLE
//
//    internal var user: Login?
//    internal var delegate: AcceptTermsViewControllerDelegate?
//
//    private var policyCheckboxs: [M13Checkbox] = []
//
//    // MARK: SYSTEM FUNC
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        policyCheckboxs.append(cbUsingTerm)
//        policyCheckboxs.append(cbPersonalInfo)
//        policyCheckboxs.append(cbLocation)
//        policyCheckboxs.append(cbMarketing)
//        policyCheckboxs.append(cbAd)
//        policyCheckboxs.append(cbContents)
//
//        prepareActionBar()
//        prepareCheckbox()
//        enableSignUpButton()
//    }
//
//
//    func prepareCheckbox() {
//        let checkboxColor = UIColor(named: "content-primary")
//
//        cbUsingTerm.boxType = .square
//        cbUsingTerm.checkState = .unchecked
//        cbUsingTerm.tintColor = checkboxColor
//
//        cbPersonalInfo.boxType = .square
//        cbPersonalInfo.checkState = .unchecked
//        cbPersonalInfo.tintColor = checkboxColor
//
//        cbLocation.boxType = .square
//        cbLocation.checkState = .unchecked
//        cbLocation.tintColor = checkboxColor
//
//        cbAcceptAll.boxType = .square
//        cbAcceptAll.checkState = .unchecked
//        cbAcceptAll.tintColor = checkboxColor
//
//        cbMarketing.boxType = .square
//        cbMarketing.checkState = .unchecked
//        cbMarketing.tintColor = checkboxColor
//
//        cbAd.boxType = .square
//        cbAd.checkState = .unchecked
//        cbAd.tintColor = checkboxColor
//
//        cbContents.boxType = .square
//        cbContents.checkState = .unchecked
//        cbContents.tintColor = checkboxColor
//    }
//
//
//    @IBAction func onValueChanged(_ sender: M13Checkbox) {
//        if cbUsingTerm.checkState == .checked &&
//            cbPersonalInfo.checkState == .checked &&
//            cbLocation.checkState == .checked
//        {
//            cbAcceptAll.setCheckState(.checked, animated: true)
//        } else {
//            cbAcceptAll.setCheckState(.unchecked, animated: true)
//        }
//        enableSignUpButton()
//    }
//
//    @IBAction func onValueChangedAcceptAll(_ sender: M13Checkbox) {
//        switch sender.checkState {
//        case .unchecked:
//            cbUsingTerm.setCheckState(.unchecked, animated: true)
//            cbPersonalInfo.setCheckState(.unchecked, animated: true)
//            cbLocation.setCheckState(.unchecked, animated: true)
//            cbMarketing.setCheckState(.unchecked, animated: true)
//            cbAd.setCheckState(.unchecked, animated: true)
//            cbContents.setCheckState(.unchecked, animated: true)
//
//        case .checked:
//            cbUsingTerm.setCheckState(.checked, animated: true)
//            cbPersonalInfo.setCheckState(.checked, animated: true)
//            cbLocation.setCheckState(.checked, animated: true)
//            cbMarketing.setCheckState(.checked, animated: true)
//            cbAd.setCheckState(.checked, animated: true)
//            cbContents.setCheckState(.checked, animated: true)
//
//        default: break
//        }
//        enableSignUpButton()
//    }
//
//    @IBAction func onClickSeeUsingTerms(_ sender: Any) {
//        seeTerms(index: .usingTerms)
//    }
//
//    @IBAction func onClickSeePersonalInfoTerms(_ sendeer: Any) {
//        seeTerms(index: .personalInfoTerms)
//    }
//
//    @IBAction func onClickSeeLocationTerms(_ sender: Any) {
//        seeTerms(index: .locationTerms)
//    }
//
//    @IBAction func onClickSeeMarketingTerms(_ sender: Any) {
//        seeTerms(index: .marketing)
//    }
//
//    @IBAction func onClickSeeAdTerms(_ sender: Any) {
//        seeTerms(index: .ad)
//    }
//
//    @IBAction func onClickSeeContentsTerms(_ sender: Any) {
//        seeTerms(index: .contents)
//    }
//
//    @IBAction func onClickNextBtn(_ sender: Any) {
//        let viewcon = UIStoryboard(name : "Login", bundle: nil).instantiateViewController(ofType: SignUpViewController.self)
//        viewcon.delegate = self
//        viewcon.user = user
//        self.navigationController?.push(viewController: viewcon)
//    }
//
//    private func seeTerms(index: NewTermsViewController.TermsType) {
//        let viewcon = NewTermsViewController()
//        viewcon.tabIndex = index
//        self.navigationController?.push(viewController: viewcon)
//    }
//
//    private func enableSignUpButton() {
//        switch cbAcceptAll.checkState {
//        case .unchecked:
//            btnNext.isEnabled = false
//            btnNext.setBackgroundColor(UIColor(named: "background-disabled")!, for: .normal)
//            btnNext.setTitleColor(UIColor(named: "content-disabled"), for: .normal)
//            ivNext.tintColor = UIColor(named: "content-disabled")
//
//        case .checked:
//            btnNext.isEnabled = true
//            btnNext.setBackgroundColor(UIColor(named: "background-positive")!, for: .normal)
//            btnNext.setTitleColor(UIColor(named: "content-primary"), for: .normal)
//            ivNext.tintColor = UIColor(named: "content-primary")
//
//        case .mixed: break
//        }
//    }
//}
//extension AcceptTermsViewController: SignUpViewControllerDelegate {
//    func successSignUp() {
//        self.navigationController?.pop()
//        if let delegate = self.delegate {
//            delegate.onSignUpDone()
//        }
//    }
//}
