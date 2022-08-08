//
//  NewLeftViewController.swift
//  evInfra
//
//  Created by 박현진 on 2022/08/08.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

protocol MoveSmallCategoryView {
    var mediumCategory: MediumCategoryType { get set }
    var smallMenuList: [String] { get set }
    func moveViewController(index: IndexPath)
}

enum MediumCategoryType: String {
    case mypage = "마이페이지"
    case pay = "PAY"
    
    case generalCommunity = "커뮤니티"
    case partnershipCoummunity = "제휴 커뮤니티"
    
    case event = "이벤트/쿠폰"
    
    case evInfo = "전기차 정보"
    
    case batteryInfo = "배터리 진단 정보"
    
    case settings = "설정"
}

internal final class NewLeftViewController: CommonBaseViewController, StoryboardView {
    
    // MARK: UI
    
    private lazy var userInfoTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var userInfoAndBerrytotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var profileTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var loginInduceTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var profileImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconProfileEmpty.image
    }
    
    private lazy var loginInduceGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "로그인을 해주세요"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = Colors.contentPrimary.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
    
    private lazy var moveLoginBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var loginUserBerryInfoTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.backgroundPositiveLight.color
        $0.IBcornerRadius = 8
    }
    
    private lazy var myBerryGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "MY 베리"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = Colors.gr6.color
        $0.textAlignment = .natural
        $0.numberOfLines = 1
    }
    
    private lazy var myBerryGuideArrow = ChevronArrow.init(.size20(.right)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBimageColor = Colors.gr3.color
    }
    
    private lazy var myBerryRefreshTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.IBcornerRadius = 20/2
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var myBerryRefreshImgView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Icons.iconRefreshXs.image
        $0.tintColor = Colors.gr4.color
    }
    
    private lazy var myBerryLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = Colors.gr6.color
        $0.textAlignment = .right
        $0.numberOfLines = 1
    }
    
    private lazy var useMyBerrySettingTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var useAllMyBerryGuideLbl = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "충전 시 베리 전액 사용"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = Colors.contentSecondary.color
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    private lazy var useAllMyBerrySw = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = Colors.contentPrimary.color
        $0.thumbTintColor = .white
        $0.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
    
    private lazy var menuListTotalView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var menuCategoryTypeStackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 0
        $0.backgroundColor = Colors.backgroundPrimary.color
    }
    
    private lazy var menuCategoryTypeView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    //@IBOutlet var useAllBerrySw: UISwitch!
    //@IBOutlet var profileImgView: UIImageView!
    //
    //@IBOutlet var myPageImgView: UIImageView!
    //@IBOutlet var communityImgView: UIImageView!
    //@IBOutlet var eventImgView: UIImageView!
    //@IBOutlet var evInfoImgView: UIImageView!
    //@IBOutlet var settingsImgView: UIImageView!
    //@IBOutlet var batteryImgView: UIImageView!
    //
    //@IBOutlet var mypageTotalView: UIView!
    //@IBOutlet var communityTotalView: UIView!
    //@IBOutlet var eventTotalView: UIView!
    //@IBOutlet var evInfoTotalView: UIView!
    //@IBOutlet var settingsTotalView: UIView!
    //@IBOutlet var batteryTotalView: UIView!
    //
    //@IBOutlet weak var myPageBtn: UIButton!
    //@IBOutlet weak var boardBtn: UIButton!
    //@IBOutlet weak var infoBtn: UIButton!
    //@IBOutlet weak var settingsBtn: UIButton!
    //@IBOutlet weak var btnLogin: UIButton!
    //@IBOutlet weak var boardCompanyBtn: UIButton!
    //@IBOutlet weak var sideTableView: UITableView!
    //
    
    // MARK: VARIABLE
    
    private var currentMenuCategoryType: MenuCategoryType = .mypage
    
    // MARK: SYSTEM FUNC
    
    override func loadView() {
        super.loadView()
        
        self.contentView.addSubview(userInfoTotalView)
        userInfoTotalView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        self.contentView.addSubview(menuListTotalView)
        menuListTotalView.snp.makeConstraints {
            $0.top.equalTo(userInfoTotalView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        let line = self.createLineView(color: Colors.borderOpaque.color)
        userInfoTotalView.addSubview(line)
        line.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        userInfoTotalView.addSubview(userInfoAndBerrytotalView)
        userInfoAndBerrytotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(line.snp.top)
        }
        
        userInfoAndBerrytotalView.addSubview(profileTotalView)
        profileTotalView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        profileTotalView.addSubview(loginInduceTotalView)
        loginInduceTotalView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        loginInduceTotalView.addSubview(profileImgView)
        profileImgView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        loginInduceTotalView.addSubview(loginInduceGuideLbl)
        loginInduceGuideLbl.snp.makeConstraints {
            $0.leading.equalTo(profileImgView.snp.trailing).offset(16)
            $0.top.trailing.bottom.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        loginInduceTotalView.addSubview(moveLoginBtn)
        moveLoginBtn.snp.makeConstraints {
            $0.leading.equalTo(loginInduceGuideLbl.snp.leading)
            $0.trailing.equalTo(loginInduceGuideLbl.snp.trailing)
            $0.height.equalTo(loginInduceGuideLbl.snp.height)
        }
        
        userInfoAndBerrytotalView.addSubview(loginUserBerryInfoTotalView)
        loginUserBerryInfoTotalView.snp.makeConstraints {
            $0.top.equalTo(profileTotalView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryGuideLbl)
        myBerryGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryGuideArrow)
        myBerryGuideArrow.snp.makeConstraints {
            $0.leading.equalTo(myBerryGuideLbl.snp.trailing)
            $0.centerY.equalTo(myBerryGuideLbl.snp.centerY)
            $0.width.height.equalTo(20)
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryRefreshTotalView)
        myBerryRefreshTotalView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(20)
        }
        
        myBerryRefreshTotalView.addSubview(myBerryRefreshImgView)
        myBerryRefreshImgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loginUserBerryInfoTotalView.addSubview(myBerryLbl)
        myBerryLbl.snp.makeConstraints {
            $0.trailing.equalTo(myBerryRefreshTotalView.snp.leading).offset(-6)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(26)
        }
        
        userInfoAndBerrytotalView.addSubview(useMyBerrySettingTotalView)
        useMyBerrySettingTotalView.snp.makeConstraints {
            $0.top.equalTo(loginUserBerryInfoTotalView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        useMyBerrySettingTotalView.addSubview(useAllMyBerryGuideLbl)
        useAllMyBerryGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        useMyBerrySettingTotalView.addSubview(useAllMyBerrySw)
        useAllMyBerrySw.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(useAllMyBerryGuideLbl)
        }
        
        menuListTotalView.addSubview(menuCategoryTypeStackView)
        menuCategoryTypeStackView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(70)
        }
        
        for menuCategoryType in MenuCategoryType {
            menuCategoryTypeStackView.addArrangedSubview(self.createMenuTypeView(menuCategoryType: menuCategoryType))
        }
        
        profileImgView.IBcornerRadius = 32/2
        profileImgView.sd_setImage(with: URL(string:"\(Const.urlProfileImage)\(MemberManager.shared.profileImage)"), placeholderImage: Icons.iconProfileEmpty.image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moveLoginBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let loginStoryboard = UIStoryboard(name : "Login", bundle: nil)
                let loginVC = loginStoryboard.instantiateViewController(ofType: LoginViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: loginVC)
            })
            .disposed(by: self.disposeBag)
                
            
        
    }
    
    func bind(reactor: LeftViewReactor) {
        
    }
    
    private func createMenuTypeView(menuCategoryType: MenuCategoryType) -> UIView {
        let view = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
        
        let mainTitleLbl = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = mainTitle
            $0.numberOfLines = 1
            $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            $0.textColor = Colors.contentTertiary.color
        }
        
        view.addSubview(mainTitleLbl)
        mainTitleLbl.snp.makeConstraints {
            $0.leading.equalTo(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        let lineView = self.createLineView()
        view.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        let quitAccountBtn = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(quitAccountBtn)
        quitAccountBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        quitAccountBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self, let _reactor = self.reactor else { return }
                
                Server.getPayRegisterStatus { (isSuccess, value) in
                    if isSuccess {
                        let json = JSON(value)
                        let payCode = json["pay_code"].intValue
                                            
                        switch PaymentStatus(rawValue: payCode) {
                        case .PAY_DEBTOR_USER: // 돈안낸 유저
                            Snackbar().show(message: "현재 회원님께서는 미수금이 있으므로 회원 탈퇴를 할 수 없습니다.")
                            
                        case .CHARGER_STATE_CHARGING: // 충전중
                            Snackbar().show(message: "현재 회원님께서는 충전중이으므로 회원 탈퇴를 할 수 없습니다.")
                                                
                        default: break
                        }
                        
                        printLog(out: "json data : \(json)")
                    } else {
                        Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
                    }
                }
                
                
            })
            .disposed(by: self.disposeBag)
        
        return view
    }
    
    
    enum MenuCategoryType: Int, CaseIterable {
        typealias MenuList = MoveSmallCategoryView
    
        case mypage = 0
        case community = 1
        case event = 2
        case evinfo = 3
        case battery = 4
        case settings = 5
    
        init(menuIndex: Int) {
            switch menuIndex {
            case 0: self = .mypage
            case 1: self = .community
            case 2: self = .event
            case 3: self = .evinfo
            case 4: self = .battery
            case 5: self = .settings
            default: self = .mypage
            }
        }
    
        internal var menuTitle: String {
            switch self {
            case .mypage: return "마이페이지"
            case .community: return "커뮤니티"
            case .event: return "이벤트"
            case .evinfo: return "전기차 정보"
            case .battery: return "배터리 정보"
            case .settings: return "설정"
            }
        }
    
        internal var menuList: [MenuList] {
            switch self {
            case .mypage:
                return [MyPage(), Pay()]
    
            case .community:
                return [GeneralCommunity(), PartnershipCommunity()]
    
            case .event:
                return [Event()]
    
            case .evinfo:
                return [EvInfo()]
    
            case .battery:
                return [BatteryInfo()]
    
            case .settings:
                return [Settings()]
    
            }
        }
    }
    
    struct Settings: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.settings
        var smallMenuList: [String] = ["전체 설정", "자주묻는 질문", "이용 안내", "버전 정보"]
    
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 전체 설정
                let reactor = SettingsReactor(provider: RestApi())
                let viewcon = NewSettingsViewController(reactor: reactor)
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    
            case 1: // 자주묻는 질문
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let termsVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                termsVC.tabIndex = .FAQTop
                GlobalDefine.shared.mainNavi?.push(viewController: termsVC)
    
            case 2:
                let loginStoryboard = UIStoryboard(name : "Login", bundle: nil)
                let guideVC = loginStoryboard.instantiateViewController(ofType: ServiceGuideViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: guideVC)
    
            default: break
            }
        }
    }
    
    struct BatteryInfo: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.batteryInfo
        var smallMenuList: [String] = ["내 차 배터리 관리"]
    
        func moveViewController(index: IndexPath) {
            Server.getBatteryJwt(completion: {(isSuccess, response) in
                if isSuccess {
                    let json = JSON(response)
                    if json["code"].stringValue.elementsEqual("1000") {
                        let accessToken = json["access_token"].stringValue
                        if !accessToken.isEmpty {
                            let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                            let termsVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                            termsVC.tabIndex = .BatteryInfo
                            termsVC.setHeader(key: "Authorization", value: "Bearer " + accessToken)
                            GlobalDefine.shared.mainNavi?.push(viewController: termsVC)
                        } else {
                            Snackbar().show(message: "인증실패")
                        }
                    } else {
                        Snackbar().show(message: "인증실패")
                    }
                } else {
                    Snackbar().show(message: "인증실패")
                }
            })
        }
    }
    
    struct EvInfo: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.evInfo
        var smallMenuList: [String] = ["전기차 정보", "충전기 정보", "보조금 안내", "보조금 현황", "충전요금 안내"]
    
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 전기차 정보
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let evInfoVC = infoStoryboard.instantiateViewController(ofType: EvInfoViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: evInfoVC)
            case 1: // 충전기 정보
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let chargerInfoVC = infoStoryboard.instantiateViewController(ofType: ChargerInfoViewController.self)
                // ChargerInfoViewController 자체 animation 사용
                GlobalDefine.shared.mainNavi?.push(viewController: chargerInfoVC)
            case 2: // 보조금 안내
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let bojoInfoVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                bojoInfoVC.tabIndex = .EvBonusGuide
                GlobalDefine.shared.mainNavi?.push(viewController: bojoInfoVC)
    
            case 3: // 보조금 현황
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let bojoDashVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                bojoDashVC.tabIndex = .EvBonusStatus
                GlobalDefine.shared.mainNavi?.push(viewController: bojoDashVC)
    
            case 4: // 충전요금 안내
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let priceInfoVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                priceInfoVC.tabIndex = .PriceInfo
                GlobalDefine.shared.mainNavi?.push(viewController: priceInfoVC)
    
            default: break
            }
        }
    }
    
    struct Event: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.event
        var smallMenuList: [String] = ["이벤트", "내 쿠폰함"]
    
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 이벤트
                let eventStoryboard = UIStoryboard(name : "Event", bundle: nil)
                let eventBoardVC = eventStoryboard.instantiateViewController(ofType: EventViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: eventBoardVC)
            case 1: // 내 쿠폰함
                MemberManager.shared.tryToLoginCheck { isLogin in
                    if isLogin {
                        let couponStoryboard = UIStoryboard(name : "Coupon", bundle: nil)
                        let coponVC = couponStoryboard.instantiateViewController(ofType: MyCouponViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: coponVC)
                    }else {
                        MemberManager.shared.showLoginAlert()
                    }
                }
    
            default: break
            }
        }
    }
    
    struct PartnershipCommunity: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.partnershipCoummunity
        var smallMenuList: [String] = Board.sharedInstance.getBoardTitleList()
    
        func moveViewController(index: IndexPath) {
            let title: String = smallMenuList[index.row]
            if !title.isEmpty {
                if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
                    UserDefault().saveInt(key: boardInfo.shardKey!, value: boardInfo.brdId!)
                    let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                    let companyBoardVC = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
                    companyBoardVC.category = Board.CommunityType.getCompanyType(shardKey: boardInfo.shardKey ?? "")
                    companyBoardVC.bmId = boardInfo.bmId!
                    companyBoardVC.brdTitle = title
                    companyBoardVC.mode = Board.ScreenType.FEED
                    GlobalDefine.shared.mainNavi?.push(viewController: companyBoardVC)
                }
            }
        }
    }
    
    struct GeneralCommunity: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.generalCommunity
        var smallMenuList: [String] = ["EV Infra 공지", "자유 게시판", "충전소 게시판"]
    
        func moveViewController(index: IndexPath) {
            switch index.row {
            case 0: // 공지사항
                let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                let noticeVC = boardStoryboard.instantiateViewController(ofType: NoticeViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: noticeVC)
    
            case 1: // 자유 게시판
                UserDefault().saveInt(key: UserDefault.Key.LAST_FREE_ID, value: Board.sharedInstance.freeBoardId)
    
                let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                let freeBoardVC = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
                freeBoardVC.category = Board.CommunityType.FREE.rawValue
                freeBoardVC.mode = Board.ScreenType.FEED
                GlobalDefine.shared.mainNavi?.push(viewController: freeBoardVC)
    
            case 2: // 충전소 게시판
                UserDefault().saveInt(key: UserDefault.Key.LAST_CHARGER_ID, value: Board.sharedInstance.chargeBoardId)
    
                let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                let stationBoardVC = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
                stationBoardVC.category = Board.CommunityType.CHARGER.rawValue
                stationBoardVC.mode = Board.ScreenType.FEED
                GlobalDefine.shared.mainNavi?.push(viewController: stationBoardVC)
    
            default: break
            }
        }
    }
    
    struct MyPage: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.mypage
        var smallMenuList: [String] = ["개인정보 관리", "내가 쓴 글 보기", "충전소 제보내역"]
    
        func moveViewController(index: IndexPath) {
            MemberManager.shared.tryToLoginCheck { isLogin in
                if isLogin {
                    switch index.row {
                    case 0: // 개인정보관리
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let mypageVC = memberStoryboard.instantiateViewController(ofType: MyPageViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: mypageVC)
    
                    case 1: // 내가 쓴 글 보기
                        var myWritingControllers = [MyWritingViewController]()
                        let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                        let freeMineVC = boardStoryboard.instantiateViewController(ofType: MyWritingViewController.self)
                        freeMineVC.boardCategory = Board.CommunityType.FREE.rawValue
                        freeMineVC.screenType = .LIST
    
                        let chargerMineVC = boardStoryboard.instantiateViewController(ofType: MyWritingViewController.self)
                        chargerMineVC.boardCategory = Board.CommunityType.CHARGER.rawValue
                        chargerMineVC.screenType = .FEED
    
                        myWritingControllers.append(chargerMineVC)
                        myWritingControllers.append(freeMineVC)
    
                        let tabsController = AppTabsController(viewControllers: myWritingControllers)
                        tabsController.actionTitle = "내가 쓴 글 보기"
                        for controller in myWritingControllers {
                            tabsController.appTabsControllerDelegates.append(controller)
                        }
                        GlobalDefine.shared.mainNavi?.push(viewController: tabsController)
    
                    case 2: // 충전소 제보 내역
                        let reportStoryboard = UIStoryboard(name : "Report", bundle: nil)
                        let reportVC = reportStoryboard.instantiateViewController(ofType: ReportBoardViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: reportVC)
    
                    default: break
                    }
                } else {
                    MemberManager.shared.showLoginAlert()
                }
            }
        }
    }
    
    struct Pay: MoveSmallCategoryView {
        var mediumCategory: MediumCategoryType = MediumCategoryType.pay
        var smallMenuList: [String] = ["결제카드 관리", "회원카드 관리", "렌터카 정보 관리" , "충전이력 조회", "포인트 조회"]
    
        func moveViewController(index: IndexPath) {
            MemberManager.shared.tryToLoginCheck { isLogin in
                if isLogin {
                    switch index.row {
                    case 0: // 개인정보 관리
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: myPayInfoVC)
    
                    case 1: // 회원카드 관리
                        let viewcon: UIViewController
                        if MemberManager.shared.hasMembership {
                            let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
                            viewcon = mbsStoryboard.instantiateViewController(ofType: MembershipCardViewController.self)
                        } else {
                            viewcon = MembershipGuideViewController()
                        }
    
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    
                    case 2: // 렌탈정보 관리
                        let viewcon = RentalCarCardListViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
    
                    case 3: // 충전이력조회
                        let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
                        let chargesVC = chargeStoryboard.instantiateViewController(ofType: ChargesViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: chargesVC)
    
                    case 4: // 포인트 조회
                        let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
                        let pointVC = chargeStoryboard.instantiateViewController(ofType: PointViewController.self)
                        GlobalDefine.shared.mainNavi?.push(viewController: pointVC)
    
                    default: break
                    }
                } else {
                    MemberManager.shared.showLoginAlert()
                }
            }
        }
    }
}


//extension NewLeftViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return currentMenuCategoryType.menuList.count
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = Bundle.main.loadNibNamed("LeftViewTableHeader", owner: self, options: nil)?.first as! LeftViewTableHeader
//        let headerValue = currentMenuCategoryType.menuList[section].mediumCategory.rawValue
//        headerView.cellTitle.text = headerValue
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentMenuCategoryType.menuList[section].smallMenuList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = sideTableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! SideMenuTableViewCell
//        cell.menuLabel.text = currentMenuCategoryType.menuList[indexPath.section].smallMenuList[indexPath.row]
//
//        // 게시판, 이벤트 등에 새글 표시
//        setNewBadge(cell: cell, index: indexPath)
//
//        if currentMenuCategoryType == .mypage &&
//            currentMenuCategoryType.menuList[indexPath.section].mediumCategory == .pay {
//            updateMyPageTitle(cell: cell, index: indexPath)
//        }
//
//        // 설정 - 버전정보 표시
//        if currentMenuCategoryType == .settings &&
//            "버전정보".equals(currentMenuCategoryType.menuList[indexPath.section].smallMenuList[indexPath.row]) {
//            cell.menuContent.isHidden = false
//            cell.menuContent.text = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
//        } else {
//            cell.menuContent.isHidden = true
//        }
//        return cell
//    }
//
//    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//        currentMenuCategoryType.menuList[indexPath.section].moveViewController(index: indexPath)
//    }
//}




//// MARK: - VARIABLE
//
//private var disposeBag = DisposeBag()


//override func viewDidLoad() {
//    super.viewDidLoad()
//
//    useAllBerrySw.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

//
//    sideTableView.delegate = self
//    sideTableView.dataSource = self
//    sideTableView.separatorStyle = UITableViewCellSeparatorStyle.none
//
//    tableViewLoad(menuCategoryType: currentMenuCategoryType)
//}
//
//override func viewDidAppear(_ animated: Bool) {
//    self.navigationDrawerController?.reHideStatusBar()
//}
//
//override func viewDidDisappear(_ animated: Bool) {
//    super.viewDidDisappear(animated)
//    self.navigationDrawerController?.reShowStatusBar()
//}
//
//
//@IBAction func clickMyPage(_ sender: Any) {
//    tableViewLoad(menuCategoryType: MenuCategoryType.mypage)
//}
//
//@IBAction func clickBoard(_ sender: Any) {
//    tableViewLoad(menuCategoryType: MenuCategoryType.community)
//}
//
//@IBAction func clickEvent(_ sender: UIButton) {
//    tableViewLoad(menuCategoryType: MenuCategoryType.event)
//}
//
//@IBAction func clickInfo(_ sender: Any) {
//    tableViewLoad(menuCategoryType: MenuCategoryType.evinfo)
//}
//
//@IBAction func clickBattery(_ sender: Any) {
//    tableViewLoad(menuCategoryType: MenuCategoryType.battery)
//}
//
//@IBAction func clickSettings(_ sender: UIButton) {
//    tableViewLoad(menuCategoryType: MenuCategoryType.settings)
//}
//
//internal func appeared() {
//    // 로그인 버튼
//    MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
//        guard let self = self else { return }
//        self.btnLogin.isHidden = isLogin
//    }
//
//    newBadgeInMenu()
//}
//
//private func tableViewLoad(menuCategoryType: MenuCategoryType) {
//    currentMenuCategoryType = menuCategoryType
//
//    mypageTotalView.backgroundColor = .clear
//    communityTotalView.backgroundColor = .clear
//    eventTotalView.backgroundColor = .clear
//    evInfoTotalView.backgroundColor = .clear
//    batteryTotalView.backgroundColor = .clear
//    settingsTotalView.backgroundColor = .clear
//
//    let backGroundColor = Colors.backgroundPrimary.color
//    switch menuCategoryType {
//    case .mypage:
//        mypageTotalView.backgroundColor = backGroundColor
//
//    case .community:
//        communityTotalView.backgroundColor = backGroundColor
//
//    case .event:
//        eventTotalView.backgroundColor = backGroundColor
//
//    case .evinfo:
//        evInfoTotalView.backgroundColor = backGroundColor
//
//    case .battery:
//        batteryTotalView.backgroundColor = backGroundColor
//
//    case .settings:
//        settingsTotalView.backgroundColor = backGroundColor
//
//    }
//
//    self.sideTableView.reloadData()
//}
//}

//extension LeftViewController {
//private func updateMyPageTitle(cell: SideMenuTableViewCell, index: IndexPath) {
//    if index.row == 0 {
//        if MemberManager.shared.hasPayment {
//            cell.menuLabel.text = "결제 정보 관리"
//        } else {
//            cell.menuLabel.text = "결제 정보 등록"
//        }
//    } else if index.row == 1 {
//        if MemberManager.shared.hasMembership {
//            cell.menuLabel.text = "회원카드 관리"
//        } else {
//            cell.menuLabel.text = "회원카드 신청"
//        }
//    }
//}
//
//// 각 게시판에 badge
//private func setNewBadge(cell: SideMenuTableViewCell, index: IndexPath) {
//    cell.newBadge.isHidden = true
//    let latestIds = Board.sharedInstance.latestBoardIds
//
//    switch currentMenuCategoryType {
//    case .mypage:
//        if index.section == 1 {
//            if index.row == 0 { // 미수금 표시
//                if UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) {
//                    cell.newBadge.isHidden = false
//                }
//            }
//        }
//
//    case .community:
//        if index.section == 0 {
//            switch index.row {
//            case 0:
//                if let latestNoticeId = latestIds[Board.KEY_NOTICE] {
//                    let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
//                    if noticeId < latestNoticeId {
//                        cell.newBadge.isHidden = false
//                    }
//                }
//
//            case 1:
//                if let latestFreeBoardId = latestIds[Board.KEY_FREE_BOARD] {
//                    let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
//                    if freeId < latestFreeBoardId {
//                        cell.newBadge.isHidden = false
//                    }
//                }
//
//            case 2:
//                if let latestChargerBoardId = latestIds[Board.KEY_CHARGER_BOARD] {
//                    let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
//                    if chargerId < latestChargerBoardId {
//                        cell.newBadge.isHidden = false
//                    }
//                }
//
//            default:
//                cell.newBadge.isHidden = true
//            }
//        }
//
//        if index.section == 1 {
//            let title: String = currentMenuCategoryType.menuList[index.section].smallMenuList[index.row]
//            if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
//                let companyId = UserDefault().readInt(key: boardInfo.shardKey!)
//                if companyId < boardInfo.brdId! {
//                    cell.newBadge.isHidden = false
//                }
//            }
//        }
//
//    case .event:
//        if index.section == 0 {
//            switch index.row {
//            case 0:
//                if let latestEventId = latestIds[Board.KEY_EVENT] {
//                    let eventId = UserDefault().readInt(key: UserDefault.Key.LAST_EVENT_ID)
//                    if eventId < latestEventId {
//                        cell.newBadge.isHidden = false
//                    }
//                }
//            default:
//                cell.newBadge.isHidden = true
//            }
//        }
//    default:
//        cell.newBadge.isHidden = true
//    }
//}
//
//// 메인화면 메뉴이미지에 badge
//private func newBadgeInMenu() {
////        if Board.sharedInstance.hasNewBoard() {
////            if let image = UIImage(named: "icon_comment_lg") {
////                communityImgView.setImage(image, for: .normal)
////            }
////        } else {
////            if let image = UIImage(named: "icon_comment_lg") {
////                communityImgView.setImage(image, for: .normal)
////            }
////        }
//
//    let _image: UIImage = UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) ? UIImage(named: "icon_user_badge") ?? UIImage() : UIImage(named: "icon_user") ?? UIImage()
//
//    myPageImgView.image = _image
//
//    // refresh new badge in sub menu
//    sideTableView.reloadData()
//}
//}
