//
//  LeftViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material
import SwiftyJSON
import RxSwift
import RxCocoa

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

internal final class LeftViewController: UIViewController {
    // MARK: UI
    
    @IBOutlet var profileImgView: UIImageView!
    
    @IBOutlet var myPageImgView: UIImageView!
    @IBOutlet var communityImgView: UIImageView!
    @IBOutlet var eventImgView: UIImageView!
    @IBOutlet var evInfoImgView: UIImageView!
    @IBOutlet var settingsImgView: UIImageView!
    @IBOutlet var batteryImgView: UIImageView!
    
    @IBOutlet var mypageTotalView: UIView!
    @IBOutlet var communityTotalView: UIView!
    @IBOutlet var eventTotalView: UIView!
    @IBOutlet var evInfoTotalView: UIView!
    @IBOutlet var settingsTotalView: UIView!
    @IBOutlet var batteryTotalView: UIView!
    
    @IBOutlet weak var myPageBtn: UIButton!
    @IBOutlet weak var boardBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var boardCompanyBtn: UIButton!
    @IBOutlet weak var sideTableView: UITableView!
            
    // MARK: - VARIABLE
    
    private var disposeBag = DisposeBag()
                    
    // sub menu - 마이페이지
    private let SUB_MENU_CELL_PAY    = 1
    
    // 마이페이지
    private let SUB_MENU_MY_PERSONAL_INFO   = 0
    private let SUB_MENU_MY_WRITING         = 1
    private let SUB_MENU_REPORT_STATION     = 2
    
    // PAY
    private let SUB_MENU_MY_PAYMENT_INFO     = 0
    private let SUB_MENU_MY_EVCARD_INFO      = 1
    private let SUB_MENU_MY_LENTAL_INFO      = 2
    private let SUB_MENU_MY_CHARGING_HISTORY = 3
    private let SUB_MENU_MY_POINT            = 4

    // sub menu - 게시판
    private let SUB_MENU_CELL_BOARD         = 0
    private let SUB_MENU_CELL_COMPANY_BOARD = 1
    
    // 게시판
    private let SUB_MENU_NOTICE        = 0 // 공지사항
    private let SUB_MENU_FREE_BOARD    = 1 // 자유게시판
    private let SUB_MENU_CHARGER_BOARD = 2 // 충전소게시판
    
    // sub menu - 이벤트
    private let SUB_MENU_CELL_EVENT = 0
    private let SUB_MENU_EVENT      = 0 // 이벤트
    private let SUB_MENU_MY_COUPON  = 1 // 내 쿠폰함

    // sub menu - 전기차정보
    private let SUB_MENU_CELL_EV_INFO = 0
    
    private let SUB_MENU_EVINFO       = 0
    private let SUB_MENU_CHARGER_INFO = 1
    private let SUB_MENU_BOJO         = 2
    private let SUB_MENU_BONUS        = 3
    private let SUB_MENU_CHARGE_PRICE = 4
    
    // sub menu - 배터리 저보
    private let SUB_MENU_CELL_BATTERY = 0
    
    // sub menu - 설정
    private let SUB_MENU_CELL_SETTINGS = 0
    
    private let SUB_MENU_ALL_SETTINGS  = 0
    private let SUB_MENU_FAQ  = 1
    private let SUB_MENU_SERVICE_GUIDE = 2
    private let SUB_MENU_VERSION       = 3
    private var currentMenuCategoryType: MenuCategoryType = .mypage
    
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
                    case 0:
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

            
    // MARK: - SYSTEM FUNC
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImgView.IBcornerRadius = 40/2
        profileImgView.sd_setImage(with: URL(string:"\(Const.urlProfileImage)\(MemberManager.shared.profileImage)"), placeholderImage: Icons.iconProfileEmpty.image)
                
        sideTableView.delegate = self
        sideTableView.dataSource = self
        sideTableView.separatorStyle = UITableViewCellSeparatorStyle.none
                
        tableViewLoad(menuCategoryType: currentMenuCategoryType)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationDrawerController?.reHideStatusBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationDrawerController?.reShowStatusBar()
    }
    
    @IBAction func clickLogin(_ sender: Any) {
        let loginStoryboard = UIStoryboard(name : "Login", bundle: nil)
        let loginVC = loginStoryboard.instantiateViewController(ofType: LoginViewController.self)
        GlobalDefine.shared.mainNavi?.push(viewController: loginVC)
    }
    
    @IBAction func clickMyPage(_ sender: Any) {
        tableViewLoad(menuCategoryType: MenuCategoryType.mypage)
    }
    
    @IBAction func clickBoard(_ sender: Any) {
        tableViewLoad(menuCategoryType: MenuCategoryType.community)
    }

    @IBAction func clickEvent(_ sender: UIButton) {
        tableViewLoad(menuCategoryType: MenuCategoryType.event)
    }
    
    @IBAction func clickInfo(_ sender: Any) {
        tableViewLoad(menuCategoryType: MenuCategoryType.evinfo)
    }
    
    @IBAction func clickBattery(_ sender: Any) {
        tableViewLoad(menuCategoryType: MenuCategoryType.battery)
    }
    
    @IBAction func clickSettings(_ sender: UIButton) {
        tableViewLoad(menuCategoryType: MenuCategoryType.settings)
    }
        
    internal func appeared() {
        // 로그인 버튼
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            self.btnLogin.isHidden = isLogin
        }
                
        newBadgeInMenu()
    }
         
    private func tableViewLoad(menuCategoryType: MenuCategoryType) {
        currentMenuCategoryType = menuCategoryType

        mypageTotalView.backgroundColor = .clear
        communityTotalView.backgroundColor = .clear
        eventTotalView.backgroundColor = .clear
        evInfoTotalView.backgroundColor = .clear
        batteryTotalView.backgroundColor = .clear
        settingsTotalView.backgroundColor = .clear
        
        let backGroundColor = Colors.backgroundPrimary.color
        switch menuCategoryType {
        case .mypage:
            mypageTotalView.backgroundColor = backGroundColor
            
        case .community:
            communityTotalView.backgroundColor = backGroundColor
            
        case .event:
            eventTotalView.backgroundColor = backGroundColor
            
        case .evinfo:
            evInfoTotalView.backgroundColor = backGroundColor
            
        case .battery:
            batteryTotalView.backgroundColor = backGroundColor
            
        case .settings:
            settingsTotalView.backgroundColor = backGroundColor
                    
        }
        
        self.sideTableView.reloadData()
    }
}

extension LeftViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentMenuCategoryType.menuList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("LeftViewTableHeader", owner: self, options: nil)?.first as! LeftViewTableHeader
        let headerValue = currentMenuCategoryType.menuList[section].mediumCategory.rawValue
        headerView.cellTitle.text = headerValue
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMenuCategoryType.menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sideTableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! SideMenuTableViewCell
        cell.menuLabel.text = currentMenuCategoryType.menuList[indexPath.section].smallMenuList[indexPath.row]
        
        // 게시판, 이벤트 등에 새글 표시
        setNewBadge(cell: cell, index: indexPath)
        
        if currentMenuCategoryType == .mypage &&
            currentMenuCategoryType.menuList[indexPath.section].mediumCategory == .pay {
            updateMyPageTitle(cell: cell, index: indexPath)
        }
        
        // 설정 - 버전정보 표시
        if currentMenuCategoryType == .settings &&
            "버전정보".equals(currentMenuCategoryType.menuList[indexPath.section].smallMenuList[indexPath.row]) {
            cell.menuContent.isHidden = false
            cell.menuContent.text = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        } else {
            cell.menuContent.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        currentMenuCategoryType.menuList[indexPath.section].moveViewController(index: indexPath)
    }
}

extension LeftViewController {
    private func updateMyPageTitle(cell: SideMenuTableViewCell, index: IndexPath) {
        if index.row == SUB_MENU_MY_PAYMENT_INFO {
            if MemberManager.shared.hasPayment {
                cell.menuLabel.text = "결제 정보 관리"
            } else {
                cell.menuLabel.text = "결제 정보 등록"
            }
        } else if index.row == SUB_MENU_MY_EVCARD_INFO {
            if MemberManager.shared.hasMembership {
                cell.menuLabel.text = "회원카드 관리"
            } else {
                cell.menuLabel.text = "회원카드 신청"
            }
        }
    }
        
    // 각 게시판에 badge
    private func setNewBadge(cell: SideMenuTableViewCell, index: IndexPath) {
        cell.newBadge.isHidden = true
        let latestIds = Board.sharedInstance.latestBoardIds
        
        switch currentMenuCategoryType {
        case .mypage:
            if index.section == SUB_MENU_CELL_PAY {
                if index.row == SUB_MENU_MY_PAYMENT_INFO { // 미수금 표시
                    if UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) {
                        cell.newBadge.isHidden = false
                    }
                }
            }
            
        case .community:
            if index.section == SUB_MENU_CELL_BOARD {
                switch index.row {
                case SUB_MENU_NOTICE:
                    if let latestNoticeId = latestIds[Board.KEY_NOTICE] {
                        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
                        if noticeId < latestNoticeId {
                            cell.newBadge.isHidden = false
                        }
                    }
                    
                case SUB_MENU_FREE_BOARD:
                    if let latestFreeBoardId = latestIds[Board.KEY_FREE_BOARD] {
                        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
                        if freeId < latestFreeBoardId {
                            cell.newBadge.isHidden = false
                        }
                    }
                    
                case SUB_MENU_CHARGER_BOARD:
                    if let latestChargerBoardId = latestIds[Board.KEY_CHARGER_BOARD] {
                        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
                        if chargerId < latestChargerBoardId {
                            cell.newBadge.isHidden = false
                        }
                    }
                    
                default:
                    cell.newBadge.isHidden = true
                }
            }
            
            if index.section == SUB_MENU_CELL_COMPANY_BOARD {
                let title: String = currentMenuCategoryType.menuList[index.section].smallMenuList[index.row]
                if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
                    let companyId = UserDefault().readInt(key: boardInfo.shardKey!)
                    if companyId < boardInfo.brdId! {
                        cell.newBadge.isHidden = false
                    }
                }
            }
            
        case .event:
            if index.section == SUB_MENU_CELL_EVENT {
                switch index.row {
                case SUB_MENU_EVENT:
                    if let latestEventId = latestIds[Board.KEY_EVENT] {
                        let eventId = UserDefault().readInt(key: UserDefault.Key.LAST_EVENT_ID)
                        if eventId < latestEventId {
                            cell.newBadge.isHidden = false
                        }
                    }
                default:
                    cell.newBadge.isHidden = true
                }
            }
        default:
            cell.newBadge.isHidden = true
        }
    }
    
    // 메인화면 메뉴이미지에 badge
    private func newBadgeInMenu() {
//        if Board.sharedInstance.hasNewBoard() {
//            if let image = UIImage(named: "icon_comment_lg") {
//                communityImgView.setImage(image, for: .normal)
//            }
//        } else {
//            if let image = UIImage(named: "icon_comment_lg") {
//                communityImgView.setImage(image, for: .normal)
//            }
//        }

        let _image: UIImage = UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) ? UIImage(named: "icon_user_badge") ?? UIImage() : UIImage(named: "icon_user") ?? UIImage()
                
        myPageImgView.image = _image
        
        // refresh new badge in sub menu
        sideTableView.reloadData()
    }
}
