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
    func moveViewController()
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
    
    @IBOutlet var userImgView: UIImageView!
    @IBOutlet var communityImgView: UIImageView!
    @IBOutlet var eventImgView: UIImageView!
    @IBOutlet var evInfoImgView: UIImageView!
    @IBOutlet var settingsImgView: UIImageView!
    @IBOutlet var batteryImgView: UIImageView!
    
    @IBOutlet var userTotalView: UIView!
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
    @IBOutlet weak var sideMenuTab: UIView!
    @IBOutlet weak var boardCompanyBtn: UIButton!
    @IBOutlet weak var sideTableView: UITableView!
            
    // MARK: - VARIABLE
    
    private var disposeBag = DisposeBag()
                    
    // sub menu - 마이페이지
    private let SUB_MENU_CELL_MYPAGE = 0
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
        typealias MediumCategory = (category: MediumCategoryType, subCategory: [String])
        
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
                
        internal var meidumCategory: [MediumCategory] {
            switch self {
            case .mypage:
                return [(category: MediumCategoryType.mypage, subCategory: ["개인정보 관리", "내가 쓴 글 보기", "충전소 제보내역"]),
                        (category: MediumCategoryType.pay, subCategory: ["결제카드 관리", "회원카드 관리", "렌터카 정보 관리" , "충전이력 조회", "포인트 조회"])
                        ]
                
            case .community:
                return [(category: MediumCategoryType.generalCommunity, subCategory: ["EV Infra 공지", "자유 게시판", "충전소 게시판"]),
                        (category: MediumCategoryType.partnershipCoummunity, subCategory: Board.sharedInstance.getBoardTitleList())
                        ]
                
            case .event:
                return [(category: MediumCategoryType.event, subCategory: ["이벤트", "내 쿠폰함"])]
                
            case .evinfo:
                return [(category: MediumCategoryType.generalCommunity, subCategory: ["전기차 정보", "충전기 정보", "보조금 안내", "보조금 현황", "충전요금 안내"])]
                
            case .battery:
                return [(category: MediumCategoryType.generalCommunity, subCategory: ["내 차 배터리 관리"])]
                
            case .settings:
                return [(category: MediumCategoryType.generalCommunity, subCategory: ["전체 설정", "자주묻는 질문", "이용 안내", "버전 정보"])]
                
            }
        }
    }
        
    
    
    struct MyPage: MoveSmallCategoryView {
        let mediumCategory: MediumCategoryType
        let smallMenuList: [String] = ["개인정보 관리", "내가 쓴 글 보기", "충전소 제보내역"]
        
        func moveViewController() {
            
        }
    }
    
    struct Pay: MoveSmallCategoryView {
        let mediumCategory: MediumCategoryType
        let smallMenuList: [String] = ["결제카드 관리", "회원카드 관리", "렌터카 정보 관리" , "충전이력 조회", "포인트 조회"]
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
                
        tableViewLoad(index: menuIndex)
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
        tableViewLoad(index: MENU_MY_PAGE)
    }
    
    @IBAction func clickBoard(_ sender: Any) {
        tableViewLoad(index: MENU_BOARD)
    }

    @IBAction func clickEvent(_ sender: UIButton) {
        tableViewLoad(index: MENU_EVENT)
    }
    
    @IBAction func clickInfo(_ sender: Any) {
        tableViewLoad(index: MENU_EVINFO)
    }
    
    @IBAction func clickBattery(_ sender: Any) {
        tableViewLoad(index: MENU_BATTERY)
    }
    
    @IBAction func clickSettings(_ sender: UIButton) {
        tableViewLoad(index: MENU_SETTINGS)
    }
        
    internal func appeared() {
        // 로그인 버튼
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            self.btnLogin.isHidden = isLogin
        }
                
        newBadgeInMenu()
    }
         
    private func tableViewLoad(index: Int) {
        menuIndex = index

        userTotalView.backgroundColor = .clear
        communityTotalView.backgroundColor = .clear
        eventTotalView.backgroundColor = .clear
        evInfoTotalView.backgroundColor = .clear
        settingsTotalView.backgroundColor = .clear
        
        let backGroundColor = Colors.backgroundPrimary.color
        switch index {
        case MENU_MY_PAGE:
            userTotalView.backgroundColor = backGroundColor
            
        case MENU_BOARD:
            communityTotalView.backgroundColor = backGroundColor
            
        case MENU_EVENT:
            eventTotalView.backgroundColor = backGroundColor
            
        case MENU_EVINFO:
            evInfoTotalView.backgroundColor = backGroundColor
            
        case MENU_BATTERY:
            batteryTotalView.backgroundColor = backGroundColor
            
        case MENU_SETTINGS:
            settingsTotalView.backgroundColor = backGroundColor
            
        default:
            userTotalView.backgroundColor = backGroundColor
        }
        
        self.sideTableView.reloadData()
    }
}

extension LeftViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentMenuCategoryType.meidumCategory.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("LeftViewTableHeader", owner: self, options: nil)?.first as! LeftViewTableHeader
        let headerValue = currentMenuCategoryType.meidumCategory[section].category.rawValue
        headerView.cellTitle.text = headerValue
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMenuCategoryType.meidumCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sideTableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! SideMenuTableViewCell
        cell.menuLabel.text = currentMenuCategoryType.meidumCategory[indexPath.section].subCategory[indexPath.row]  
        
        // 게시판, 이벤트 등에 새글 표시
        setNewBadge(cell: cell, index: indexPath)
        
        if currentMenuCategoryType == .mypage &&
            currentMenuCategoryType.meidumCategory[indexPath.section].category == .pay {
            updateMyPageTitle(cell: cell, index: indexPath)
        }
        
        // 설정 - 버전정보 표시
        if currentMenuCategoryType == .settings &&
            "버전정보".equals(currentMenuCategoryType.meidumCategory[indexPath.section].subCategory[indexPath.row]) {
            cell.menuContent.isHidden = false
            cell.menuContent.text = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        } else {
            cell.menuContent.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch currentMenuCategoryType {
        case .mypage:
            selectedMyPageMenu(index: indexPath)
        case .community:
            selectedBoardMenu(index: indexPath)
        case .event:
            selectedEvnetCouponMenu(index: indexPath)
        case .evinfo:
            selectedEvInfoMenu(index: indexPath)
        case .battery:
            selectedBatteryMenu(index: indexPath)
        case .settings:
            selectedSettingsMenu(index: indexPath)
        }
    }
}

extension LeftViewController {
    private func selectedMyPageMenu(index: IndexPath) {
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                switch index.section {
                case self.SUB_MENU_CELL_MYPAGE:
                    switch index.row {
                    case self.SUB_MENU_MY_PERSONAL_INFO: // 개인정보관리
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let mypageVC = memberStoryboard.instantiateViewController(ofType: MyPageViewController.self)
                        self.navigationController?.push(viewController: mypageVC)
                    
                    case self.SUB_MENU_MY_WRITING: // 내가 쓴 글 보기
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
                        self.navigationController?.push(viewController: tabsController)
                    
                    case self.SUB_MENU_REPORT_STATION: // 충전소 제보 내역
                        let reportStoryboard = UIStoryboard(name : "Report", bundle: nil)
                        let reportVC = reportStoryboard.instantiateViewController(ofType: ReportBoardViewController.self)
                        self.navigationController?.push(viewController: reportVC)

                    default:
                        print("out of index")
                    }
                    
                case self.SUB_MENU_CELL_PAY:
                    switch index.row {
                    case self.SUB_MENU_MY_PAYMENT_INFO:
                        let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
                        let myPayInfoVC = memberStoryboard.instantiateViewController(ofType: MyPayinfoViewController.self)
                        self.navigationController?.push(viewController: myPayInfoVC)
                
                    case self.SUB_MENU_MY_EVCARD_INFO: // 회원카드 관리
                        let viewcon: UIViewController
                        if MemberManager.shared.hasMembership {
                            let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
                            viewcon = mbsStoryboard.instantiateViewController(ofType: MembershipCardViewController.self)
                        } else {
                            viewcon = MembershipGuideViewController()
                        }
                        
                        self.navigationController?.push(viewController: viewcon)
                        break
                        
                    case self.SUB_MENU_MY_LENTAL_INFO: // 렌탈정보 관리
                        let viewcon = RentalCarCardListViewController()
                        self.navigationController?.push(viewController: viewcon)
                        break

                    case self.SUB_MENU_MY_CHARGING_HISTORY: // 충전이력조회
                        let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
                        let chargesVC = chargeStoryboard.instantiateViewController(ofType: ChargesViewController.self)
                        self.navigationController?.push(viewController: chargesVC)

                    case self.SUB_MENU_MY_POINT: // 포인트 조회
                        let chargeStoryboard = UIStoryboard(name : "Charge", bundle: nil)
                        let pointVC = chargeStoryboard.instantiateViewController(ofType: PointViewController.self)
                        self.navigationController?.push(viewController: pointVC)
                        break

                    default:
                        print("out of index")
                    }
                default:
                    print("out of index")
                }
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }
    
    private func selectedBoardMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_BOARD:
            switch index.row {
            case SUB_MENU_NOTICE: // 공지사항
                let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                let noticeVC = boardStoryboard.instantiateViewController(ofType: NoticeViewController.self)
                navigationController?.push(viewController: noticeVC)
            
            case SUB_MENU_FREE_BOARD: // 자유 게시판
                UserDefault().saveInt(key: UserDefault.Key.LAST_FREE_ID, value: Board.sharedInstance.freeBoardId)
                
                let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                let freeBoardVC = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
                freeBoardVC.category = Board.CommunityType.FREE.rawValue
                freeBoardVC.mode = Board.ScreenType.FEED
                navigationController?.push(viewController: freeBoardVC)
            
            case SUB_MENU_CHARGER_BOARD: // 충전소 게시판
                UserDefault().saveInt(key: UserDefault.Key.LAST_CHARGER_ID, value: Board.sharedInstance.chargeBoardId)
                
                let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                let stationBoardVC = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
                stationBoardVC.category = Board.CommunityType.CHARGER.rawValue
                stationBoardVC.mode = Board.ScreenType.FEED
                GlobalDefine.shared.mainNavi?.push(viewController: stationBoardVC)
            default:
                print("out of index")
            }
        case SUB_MENU_CELL_COMPANY_BOARD: // 사업자 게시판
            let title:String = self.companyNameArr[index.row]
            if !title.isEmpty {
                if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
                    UserDefault().saveInt(key: boardInfo.shardKey!, value: boardInfo.brdId!)
                    let boardStoryboard = UIStoryboard(name : "Board", bundle: nil)
                    let companyBoardVC = boardStoryboard.instantiateViewController(ofType: CardBoardViewController.self)
                    companyBoardVC.category = Board.CommunityType.getCompanyType(shardKey: boardInfo.shardKey ?? "")
                    companyBoardVC.bmId = boardInfo.bmId!
                    companyBoardVC.brdTitle = title
                    companyBoardVC.mode = Board.ScreenType.FEED
                    navigationController?.push(viewController: companyBoardVC)
                }
            }
        default:
            print("out of index")
        }
    }
    
    private func selectedEvnetCouponMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_EVENT:
            switch index.row {
            case SUB_MENU_EVENT: // 이벤트
                let eventStoryboard = UIStoryboard(name : "Event", bundle: nil)
                let eventBoardVC = eventStoryboard.instantiateViewController(ofType: EventViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: eventBoardVC)
            case SUB_MENU_MY_COUPON: // 내 쿠폰함
                MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
                    guard let self = self else { return }
                    if isLogin {
                        let couponStoryboard = UIStoryboard(name : "Coupon", bundle: nil)
                        let coponVC = couponStoryboard.instantiateViewController(ofType: MyCouponViewController.self)
                        self.navigationController?.push(viewController: coponVC)
                    }else {
                        MemberManager.shared.showLoginAlert()
                    }
                }
                
            default:
                print("out of index")
            }
        default:
            print("out of index")
        }
    }
    
    private func selectedEvInfoMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_EV_INFO:
            switch index.row {
            case SUB_MENU_EVINFO: // 전기차 정보
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let evInfoVC = infoStoryboard.instantiateViewController(ofType: EvInfoViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: evInfoVC)
            case SUB_MENU_CHARGER_INFO: // 충전기 정보
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let chargerInfoVC = infoStoryboard.instantiateViewController(ofType: ChargerInfoViewController.self)
                // ChargerInfoViewController 자체 animation 사용
                GlobalDefine.shared.mainNavi?.push(viewController: chargerInfoVC)
            case SUB_MENU_BOJO: // 보조금 안내
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let bojoInfoVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                bojoInfoVC.tabIndex = .EvBonusGuide
                GlobalDefine.shared.mainNavi?.push(viewController: bojoInfoVC)
            
            case SUB_MENU_BONUS: // 보조금 현황
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let bojoDashVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                bojoDashVC.tabIndex = .EvBonusStatus
                GlobalDefine.shared.mainNavi?.push(viewController: bojoDashVC)
                
            case SUB_MENU_CHARGE_PRICE: // 충전요금 안내
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let priceInfoVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                priceInfoVC.tabIndex = .PriceInfo
                GlobalDefine.shared.mainNavi?.push(viewController: priceInfoVC)
                
            default:
                print("out of index")
            }
        
        default:
            print("out of index")
        }
    }
    
    private func selectedBatteryMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_BATTERY:
            requestGetJwt()
        default:
            print("out of index")
        }
    }
    
    private func requestGetJwt() {
        Server.getBatteryJwt(completion: {(isSuccess, response) in
            if isSuccess {
                let json = JSON(response)
                if json["code"].stringValue.elementsEqual("1000") {
                    let accessToken = json["access_token"].stringValue
                    if !accessToken.isEmpty {
                        self.startBatteryWebView(token: accessToken)
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
    
    private func startBatteryWebView(token: String) {
        let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
        let termsVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
        termsVC.tabIndex = .BatteryInfo
        termsVC.setHeader(key: "Authorization", value: "Bearer " + token)
        GlobalDefine.shared.mainNavi?.push(viewController: termsVC)
    }
    
    private func selectedSettingsMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_SETTINGS:
            switch index.row {
            case SUB_MENU_ALL_SETTINGS: // 전체 설정
                let reactor = SettingsReactor(provider: RestApi())
                let viewcon = NewSettingsViewController(reactor: reactor)                
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
            case SUB_MENU_FAQ: // 자주묻는 질문
                let infoStoryboard = UIStoryboard(name : "Info", bundle: nil)
                let termsVC = infoStoryboard.instantiateViewController(ofType: TermsViewController.self)
                termsVC.tabIndex = .FAQTop
                GlobalDefine.shared.mainNavi?.push(viewController: termsVC)
            
            case SUB_MENU_SERVICE_GUIDE:
                let loginStoryboard = UIStoryboard(name : "Login", bundle: nil)
                let guideVC = loginStoryboard.instantiateViewController(ofType: ServiceGuideViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: guideVC)

            default:
                print("out of index")
            }

        default:
            print("out of index")
        }
    }
    
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
        
        switch menuIndex {
        case MENU_MY_PAGE:
            if index.section == SUB_MENU_CELL_PAY {
                if index.row == SUB_MENU_MY_PAYMENT_INFO { // 미수금 표시
                    if UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) {
                        cell.newBadge.isHidden = false
                    }
                }
            }
            break
        case MENU_BOARD:
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
                    if !sideMenuArrays.isEmpty {
                        if let latestChargerBoardId = latestIds[Board.KEY_CHARGER_BOARD] {
                            let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
                            if chargerId < latestChargerBoardId {
                                cell.newBadge.isHidden = false
                            }
                        }
                    }
                    
                default:
                    cell.newBadge.isHidden = true
                }
            }
            
            if index.section == SUB_MENU_CELL_COMPANY_BOARD {
                let title:String = self.companyNameArr[index.row]
                if let boardInfo = Board.sharedInstance.getBoardNewInfo(title: title) {
                    let companyId = UserDefault().readInt(key: boardInfo.shardKey!)
                    if companyId < boardInfo.brdId! {
                        cell.newBadge.isHidden = false
                    }
                }
            }
        case MENU_EVENT:
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
//                boardBtn.setImage(image, for: .normal)
//            }
//        } else {
//            if let image = UIImage(named: "icon_comment_lg") {
//                boardBtn.setImage(image, for: .normal)
//            }
//        }
//
//        if UserDefault().readBool(key: UserDefault.Key.HAS_FAILED_PAYMENT) {
//            if let image = UIImage(named: "icon_user_badge") {
//                myPageBtn.setImage(image, for: .normal)
//            }
//        } else {
//            if let image = UIImage(named: "icon_user") {
//                myPageBtn.setImage(image, for: .normal)
//            }
//        }
        // refresh new badge in sub menu
        sideTableView.reloadData()
    }
}
