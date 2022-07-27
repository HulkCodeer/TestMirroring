//
//  RentalCarCardListViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Material
import SwiftyJSON

internal final class RentalCarCardListViewController: UIViewController {
    
    // MARK: UI
    
    private lazy var partnershipJoinView = PartnershipJoinView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.isHidden = true
    }
    
    private lazy var rentalCarCardList = RentalCarCardListView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false        
        $0.isHidden = true
    }
    
    // MARK: VARIABLE
    
    private var partnershipInfoList = [MemberPartnershipInfo]()
    
    // MARK: SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(partnershipJoinView)
        partnershipJoinView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(rentalCarCardList)
        rentalCarCardList.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "롯데렌터카/SK렌터카 회원카드 목록 화면"
        prepareActionBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                self.checkMembershipData()
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }

    func checkMembershipData() {
        Server.getRetnalCarCardInfo { [weak self] (isSuccess, value) in
            guard let self = self else { return }
            if isSuccess {
                let json = JSON(value)
                printLog(out: "JSON getRetnalCarCardInfo DATA : \(json)")
                self.partnershipInfoList.removeAll()
                var isShowJoinView: Bool = false

                if json["code"].stringValue.elementsEqual("1101") { // MBS_CARD_NOT_ISSUED 발급받은 회원카드가 없음
                    UserDefault().saveBool(key: UserDefault.Key.INTRO_SKR, value: false)
                    self.partnershipJoinView.showInfoView(infoList : self.partnershipInfoList)
                    isShowJoinView = true
                } else {
                    for jsonRow in json["list"].arrayValue {
                        let item : MemberPartnershipInfo = MemberPartnershipInfo(jsonRow)
                        self.partnershipInfoList.append(item)
                    }
                    self.rentalCarCardList.showInfoView(infoList: self.partnershipInfoList)
                    isShowJoinView = false
                }

                self.partnershipJoinView.isHidden = !isShowJoinView
                self.rentalCarCardList.isHidden = isShowJoinView
            }
        }
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "회원카드 관리"
        self.navigationController?.isNavigationBarHidden = false
    }

    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
}

extension RentalCarCardListViewController: PartnershipListViewDelegate {    
    func paymentStatusInfo() -> PaymentStatus { return .none }    
    func addNewPartnership() {}
    
    func showEvinfraMembershipInfo(info : MemberPartnershipInfo) {
        let mbsInfoVC = storyboard?.instantiateViewController(withIdentifier: "MembershipInfoViewController") as! MembershipInfoViewController
        mbsInfoVC.setCardInfo(info : info)
        navigationController?.push(viewController: mbsInfoVC)
    }
    
    func moveMembershipUseGuideView() {
        let viewcon = MembershipUseGuideViewController()
        navigationController?.push(viewController: viewcon)
    }
    
    func moveReissuanceView(info: MemberPartnershipInfo) {
        let reactor = MembershipReissuanceReactor(provider: RestApi())
        let viewcon = MembershipReissuanceViewController()
        viewcon.reactor = reactor
        
        for item in partnershipInfoList {
            switch item.clientId {
            case 1 : // evinfra
                reactor.cardNo = item.cardNo ?? ""
                navigationController?.push(viewController: viewcon)
                                            
//            case 23 : //sk rent
//                viewSkrList.isHidden = false
//                cardCnt -= 1
//                MemberManager.setSKRentConfig()
//                isSKR = true
//                break;
//
//            case 24 : //lotte rent
//                viewLotteList.isHidden = false
//                labelCarNo.text = item.carNo
//                labelContrDate.text = item.startDate! + " ~ " + item.endDate!
//                cardCnt -= 1
//                break
            default :
                print("out of index")
            }
        }
    }
}
extension RentalCarCardListViewController: PartnershipJoinViewDelegate {

    func showMembershipIssuanceView() {
        let storyboard = UIStoryboard(name : "Membership", bundle: nil)
        let mbsIssueVC = storyboard.instantiateViewController(ofType: MembershipIssuanceViewController.self)
        navigationController?.push(viewController: mbsIssueVC)
    }
    func showSKMemberQRView() {
        let storyboard = UIStoryboard(name : "Membership", bundle: nil)
        let mbsQRVC = storyboard.instantiateViewController(ofType: MembershipQRViewController.self)
        navigationController?.push(viewController: mbsQRVC)
    }
    
    func showLotteRentCertificateView() {
        let storyboard = UIStoryboard(name : "Membership", bundle: nil)
        let lotteVC = storyboard.instantiateViewController(ofType: LotteRentCertificateViewController.self)
        navigationController?.push(viewController: lotteVC)
    }
}

