//
//  LeftViewController.swift
//  evInfra
//
//  Created by bulacode on 2018. 2. 19..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import Material

class LeftViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let cellIdentifier = "sideMenuCell"
    
    // main menu
    let MENU_MY_PAGE    = 0
    let MENU_BOARD      = 1
    let MENU_EVENT      = 2
    let MENU_EVINFO     = 3
    let MENU_SETTINGS   = 4
    
    // sub menu - 마이페이지
    let SUB_MENU_CELL_MYPAGE = 0
    let SUB_MENU_CELL_PAY    = 1
    
    // 마이페이지
    let SUB_MENU_MY_PERSONAL_INFO   = 0
    let SUB_MENU_MY_WRITING         = 1
    let SUB_MENU_REPORT_STATION     = 2
    
    // PAY
    let SUB_MENU_MY_PAYMENT_INFO     = 0
    let SUB_MENU_MY_EVCARD_INFO      = 1
    let SUB_MENU_MY_CHARGING_HISTORY = 2
    let SUB_MENU_MY_POINT            = 3

    // sub menu - 게시판
    let SUB_MENU_CELL_BOARD         = 0
    let SUB_MENU_CELL_COMPANY_BOARD = 1
    
    // 게시판
    let SUB_MENU_NOTICE        = 0 // 공지사항
    let SUB_MENU_FREE_BOARD    = 1 // 자유게시판
    let SUB_MENU_CHARGER_BOARD = 2 // 충전소게시판
    
    // 사업자 게시판
    let SUB_MENU_GS_CALTEX  = 0 // GS 칼텍스
    let SUB_MENU_JEVS       = 1 // 제주전기자동차서비스
    let SUB_MENU_STRAFFIC   = 2 // 에스트래픽
    
    // sub menu - 이벤트
    let SUB_MENU_CELL_EVENT = 0
    let SUB_MENU_EVENT      = 0 // 이벤트
    let SUB_MENU_MY_COUPON  = 1 // 내 쿠폰함

    // sub menu - 전기차정보
    let SUB_MENU_CELL_EV_INFO = 0
    
    let SUB_MENU_EVINFO       = 0
    let SUB_MENU_CHARGER_INFO = 1
    let SUB_MENU_BOJO         = 2
    let SUB_MENU_BONUS        = 3
    
    // sub menu - 설정
    let SUB_MENU_CELL_SETTINGS = 0
    
    let SUB_MENU_ALL_SETTINGS  = 0
    let SUB_MENU_SERVICE_GUIDE = 1
    let SUB_MENU_VERSION       = 2
    
    var sideSectionArrays = [["마이페이지", "PAY"], ["커뮤니티", "제휴 커뮤니티"], ["이벤트/쿠폰"], ["전기차 정보"], ["설정"]]
    var sideMenuArrays = [[["개인정보 관리", "내가쓴글 보기", "충전소 제보내역"],
                           ["결제카드 관리", "회원카드 관리", "충전이력 조회", "포인트 조회"]],
                          [["EV Infra 공지", "자유 게시판", "충전소 게시판"],
                           ["GS 칼텍스", "제주전기자동차서비스", "에스트래픽"]],
                          [["이벤트", "내 쿠폰함"]],
                          [["전기차 정보", "충전기 정보", "보조금 안내", "보조금 현황"]],
                          [["전체 설정", "이용 안내", "버전 정보"]]]
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var sideMenuTab: UIView!
    @IBOutlet weak var myPageBtn: UIButton!
    @IBOutlet weak var boardBtn: UIButton!
    @IBOutlet weak var boardCompanyBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    var menuIndex = 0
    
    @IBAction func clickLogin(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.push(viewController: loginVC)
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
    
    @IBAction func clickSettings(_ sender: UIButton) {
        tableViewLoad(index: MENU_SETTINGS)
    }
    
    @IBOutlet weak var sideTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideTableView.delegate = self
        sideTableView.dataSource = self
        
        sideTableView.separatorStyle = UITableViewCellSeparatorStyle.none
//        sideTableView.estimatedSectionHeaderHeight = 47
        
        tableViewLoad(index: menuIndex);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appDelegate.hideStatusBar()
        newBadgeInMenu()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appDelegate.showStatusBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appeared() {
        // 로그인 버튼
        if MemberManager().isLogin() {
            btnLogin.gone()
        } else {
            btnLogin.visible()
        }
    }
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return sideSectionArrays[menuIndex].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuArrays[menuIndex][section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("LeftViewTableHeader", owner: self, options: nil)?.first as! LeftViewTableHeader
        let headerValue = sideSectionArrays[menuIndex][section]
        headerView.cellTitle.text = headerValue
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sideTableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! SideMenuTableViewCell
        cell.menuLabel.text = sideMenuArrays[menuIndex][indexPath.section][indexPath.row]
        
        // 게시판, 이벤트 등에 새글 표시
        setNewBadge(cell: cell, index: indexPath)
        
        // 설정 - 버전정보 표시
        if menuIndex == MENU_SETTINGS && indexPath.row == SUB_MENU_VERSION {
            cell.menuContent.isHidden = false
            cell.menuContent.text = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        } else {
            cell.menuContent.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if menuIndex == MENU_MY_PAGE { // 마이페이지
            selectedMyPageMenu(index: indexPath)
        } else if menuIndex == MENU_BOARD { // 게시판
            selectedBoardMenu(index: indexPath)
        } else if menuIndex == MENU_EVENT { // 이벤트 게시판
            selectedEvnetCouponMenu(index: indexPath)
        } else if menuIndex == MENU_EVINFO { // 전기차 정보
            selectedEvInfoMenu(index: indexPath)
        } else if menuIndex == MENU_SETTINGS { // 전체 설정
            selectedSettingsMenu(index: indexPath)
        }
    }
    
    func tableViewLoad(index: Int) {
        menuIndex = index
        myPageBtn.backgroundColor = UIColor(rgb: 0xFFFFFF, alpha: 0x00)
        boardBtn.backgroundColor = UIColor(rgb: 0xFFFFFF, alpha: 0x00)
        boardCompanyBtn.backgroundColor = UIColor(rgb: 0xFFFFFF, alpha: 0x00)
        infoBtn.backgroundColor = UIColor(rgb: 0xFFFFFF, alpha: 0x00)
        settingsBtn.backgroundColor = UIColor(rgb: 0xFFFFFF, alpha: 0x00)
        
        switch index {
        case MENU_MY_PAGE:
            myPageBtn.backgroundColor = UIColor(rgb: 0xFFFFFF)
        case MENU_BOARD:
            boardBtn.backgroundColor = UIColor(rgb: 0xFFFFFF)
        case MENU_EVENT:
            boardCompanyBtn.backgroundColor = UIColor(rgb: 0xFFFFFF)
        case MENU_EVINFO:
            infoBtn.backgroundColor = UIColor(rgb: 0xFFFFFF)
        case MENU_SETTINGS:
            settingsBtn.backgroundColor = UIColor(rgb: 0xFFFFFF)
        default:
            myPageBtn.backgroundColor = UIColor(rgb: 0xFFFFFF)
        }
        self.sideTableView.reloadData()
    }
}

extension LeftViewController {
    private func selectedMyPageMenu(index: IndexPath) {
        if MemberManager().isLogin() {
            switch index.section {
            case SUB_MENU_CELL_MYPAGE:
                switch index.row {
                case SUB_MENU_MY_PERSONAL_INFO: // 개인정보관리
                    let mypageVC = storyboard?.instantiateViewController(withIdentifier: "MyPageViewController") as! MyPageViewController
                    navigationController?.push(viewController: mypageVC)
                
                case SUB_MENU_MY_WRITING: // 내가 쓴 글 보기
                    var myWritingControllers = [MyWritingViewController]()
                    let freeMineVC = storyboard?.instantiateViewController(withIdentifier: "MyWritingViewController") as! MyWritingViewController
                    freeMineVC.boardCategory = BoardData.BOARD_CATEGORY_FREE
                    let chargerMineVC = storyboard?.instantiateViewController(withIdentifier: "MyWritingViewController") as! MyWritingViewController
                    chargerMineVC.boardCategory = BoardData.BOARD_CATEGORY_CHARGER
                    
                    myWritingControllers.append(chargerMineVC)
                    myWritingControllers.append(freeMineVC)
                    
                    let tabsController = AppTabsController(viewControllers: myWritingControllers)
                    tabsController.actionTitle = "내가 쓴 글 보기"
                    for controller in myWritingControllers {
                        tabsController.appTabsControllerDelegates.append(controller)
                    }
                    navigationController?.push(viewController: tabsController)
                
                case SUB_MENU_REPORT_STATION: // 충전소 제보 내역
                    let reportVC = storyboard?.instantiateViewController(withIdentifier: "ReportBoardViewController") as! ReportBoardViewController
                    navigationController?.push(viewController: reportVC)

                default:
                    print("out of index")
                }
            case SUB_MENU_CELL_PAY:
                switch index.row {
                case SUB_MENU_MY_PAYMENT_INFO:
                    let myPayInfoVC = storyboard?.instantiateViewController(withIdentifier: "MyPayinfoViewController") as! MyPayinfoViewController
                    navigationController?.push(viewController: myPayInfoVC)
            
                case SUB_MENU_MY_EVCARD_INFO: // 회원카드 관리
                    let mbsStoryboard = UIStoryboard(name : "Membership", bundle: nil)
                    let mbscdVC = mbsStoryboard.instantiateViewController(withIdentifier: "MembershipCardViewController") as! MembershipCardViewController
                    navigationController?.push(viewController: mbscdVC)
                    break

                case SUB_MENU_MY_CHARGING_HISTORY: // 충전이력조회
                    let chargesVC = storyboard?.instantiateViewController(withIdentifier: "ChargesViewController") as! ChargesViewController
                    navigationController?.push(viewController: chargesVC)

                case SUB_MENU_MY_POINT: // 포인트 조회
                    let pointVC = storyboard?.instantiateViewController(withIdentifier: "PointViewController") as! PointViewController
                    navigationController?.push(viewController: pointVC)
                    break

                default:
                    print("out of index")
                }
            default:
                print("out of index")
            }
        } else {
            MemberManager().showLoginAlert(vc: self)
        }
    }
    
    private func selectedBoardMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_BOARD:
            switch index.row {
            case SUB_MENU_NOTICE: // 공지사항
                let noticeVC = storyboard?.instantiateViewController(withIdentifier: "NoticeViewController") as! NoticeViewController
                navigationController?.push(viewController: noticeVC)
            
            case SUB_MENU_FREE_BOARD: // 자유 게시판
                let freeBoardVC = storyboard?.instantiateViewController(withIdentifier: "CardBoardViewController") as! CardBoardViewController
                freeBoardVC.category = BoardData.BOARD_CATEGORY_FREE
                navigationController?.push(viewController: freeBoardVC)
            
            case SUB_MENU_CHARGER_BOARD: // 충전소 게시판
                let stationBoardVC = storyboard?.instantiateViewController(withIdentifier: "CardBoardViewController") as! CardBoardViewController
                stationBoardVC.category = BoardData.BOARD_CATEGORY_CHARGER
                navigationController?.push(viewController: stationBoardVC)
            default:
                print("out of index")
            }
        case SUB_MENU_CELL_COMPANY_BOARD:
            let companyBoardVC = storyboard?.instantiateViewController(withIdentifier: "CardBoardViewController") as! CardBoardViewController
            companyBoardVC.category = BoardData.BOARD_CATEGORY_COMPANY
            switch index.row {
            case SUB_MENU_GS_CALTEX:
                companyBoardVC.companyId = CompanyInfo.COMPANY_ID_GSC
                navigationController?.push(viewController: companyBoardVC)

            case SUB_MENU_JEVS:
                companyBoardVC.companyId = CompanyInfo.COMPANY_ID_JEVS
                navigationController?.push(viewController: companyBoardVC)

            case SUB_MENU_STRAFFIC:
                companyBoardVC.companyId = CompanyInfo.COMPANY_ID_STRAFFIC
                navigationController?.push(viewController: companyBoardVC)

            default:
                print("out of index")
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
                let eventBoardVC = self.storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
                self.navigationController?.push(viewController: eventBoardVC)

            case SUB_MENU_MY_COUPON: // 내 쿠폰함
                let coponVC = self.storyboard?.instantiateViewController(withIdentifier: "MyCouponViewController") as! MyCouponViewController
                self.navigationController?.push(viewController: coponVC)

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
                let evInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "EVInfoViewController") as! EvInfoViewController
                self.navigationController?.push(viewController: evInfoVC)
            
            case SUB_MENU_CHARGER_INFO: // 충전기 정보
                let chargerInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "ChargerInfoViewController") as! ChargerInfoViewController
                // ChargerInfoViewController 자체 animation 사용
                self.navigationController?.pushViewController(chargerInfoVC, animated: true)
            
            case SUB_MENU_BOJO: // 보조금 안내
                let bojoInfoVC: TermsViewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
                bojoInfoVC.tabIndex = .EvBonusGuide
                self.navigationController?.push(viewController: bojoInfoVC)
            
            case SUB_MENU_BONUS: // 보조금 현황
                let bojoDashVC: TermsViewController = self.storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
                bojoDashVC.tabIndex = .EvBonusStatus
                self.navigationController?.push(viewController: bojoDashVC)
            default:
                print("out of index")
            }
        
        default:
            print("out of index")
        }
    }
    
    private func selectedSettingsMenu(index: IndexPath) {
        switch index.section {
        case SUB_MENU_CELL_SETTINGS:
            switch index.row {
            case SUB_MENU_ALL_SETTINGS: // 전체 설정
                let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                self.navigationController?.push(viewController: settingsVC)
            
            case SUB_MENU_SERVICE_GUIDE:
                let guideVC = self.storyboard?.instantiateViewController(withIdentifier: "ServiceGuideViewController") as! ServiceGuideViewController
                self.navigationController?.push(viewController: guideVC)

            default:
                print("out of index")
            }

        default:
            print("out of index")
        }
    }
    
    private func setNewBadge(cell: SideMenuTableViewCell, index: IndexPath) {
        cell.newBadge.isHidden = true
        let latestIds = NewArticleChecker.sharedInstance.latestBoardIds
        
        switch menuIndex {
        case MENU_BOARD:
            if index.section == SUB_MENU_CELL_BOARD {
                switch index.row {
                case SUB_MENU_NOTICE:
                    if let latestNoticeId = latestIds[NewArticleChecker.KEY_NOTICE] {
                        let noticeId = UserDefault().readInt(key: UserDefault.Key.LAST_NOTICE_ID)
                        if noticeId < latestNoticeId {
                            cell.newBadge.isHidden = false
                        }
                    }
                case SUB_MENU_FREE_BOARD:
                    if let latestFreeBoardId = latestIds[NewArticleChecker.KEY_FREE_BOARD] {
                        let freeId = UserDefault().readInt(key: UserDefault.Key.LAST_FREE_ID)
                        if freeId < latestFreeBoardId {
                            cell.newBadge.isHidden = false
                        }
                    }
                case SUB_MENU_CHARGER_BOARD:
                    if let latestChargerBoardId = latestIds[NewArticleChecker.KEY_CHARGER_BOARD] {
                        let chargerId = UserDefault().readInt(key: UserDefault.Key.LAST_CHARGER_ID)
                        if chargerId < latestChargerBoardId {
                            cell.newBadge.isHidden = false
                        }
                    }
                default:
                    cell.newBadge.isHidden = true
                }
            }
        case MENU_EVENT:
            if index.section == SUB_MENU_CELL_EVENT {
                switch index.row {
                case SUB_MENU_EVENT:
                    if let latestEventId = latestIds[NewArticleChecker.KEY_EVENT] {
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
    
    private func newBadgeInMenu() {
        if NewArticleChecker.sharedInstance.hasNewBoard() {
            if let image = UIImage(named: "menu_board_badge") {
                boardBtn.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "menu_board") {
                boardBtn.setImage(image, for: .normal)
            }
        }
        
        // refresh new badge in sub menu
        sideTableView.reloadData()
    }
}
