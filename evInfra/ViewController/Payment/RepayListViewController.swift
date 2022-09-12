//
//  RepayListViewController.swift
//  evInfra
//
//  Created by SH on 2021/11/18.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import SwiftyJSON
import Material
import M13Checkbox

protocol RepaymentListDelegate: class {
    func onRepaySuccess()
    func onRepayFail()
}
class RepayListViewController: UIViewController, MyPayRegisterViewDelegate, RepaymentResultDelegate {
    @IBOutlet weak var lbCardInfo: UILabel!
    @IBOutlet weak var lbCardStatus: UILabel!
    @IBOutlet weak var lbFailedListCnt: UILabel!
    @IBOutlet weak var lbTotalAmount: UILabel!
    @IBOutlet weak var tableFailedList: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lbOtherCnt: UILabel!
    @IBOutlet weak var viewCardInfo: UIView!
    @IBOutlet weak var viewCardInfoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFailedInfo: UIView!
    
    @IBOutlet weak var cbUsePoint: M13Checkbox!
    @IBOutlet weak var lbUsePoint: UILabel!
    @IBOutlet weak var viewUsePoint: UIView!
    
    @IBOutlet weak var btnRetry: UIButton!
    @IBOutlet weak var btnChangeCard: UIButton!
    
    @IBOutlet weak var viewProcessing: UIView!
    weak var delegate: RepaymentListDelegate?
    var paymentList: Array<ChargingStatus> = Array<ChargingStatus>()
    var payRegisterResult: JSON?
    
    private var totalPoint = 0
    private var totalAmount = 0
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        prepareActionBar()
        prepareView()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemberManager.shared.tryToLoginCheck {[weak self] isLogin in
            guard let self = self else { return }
            if isLogin {
                if let resultJson = self.payRegisterResult { // 카드 변경 완료
                    let payCode = resultJson["pay_code"].intValue
                    if payCode == PaymentCard.PAY_REGISTER_SUCCESS {
                        self.lbCardInfo.text = "\(resultJson["card_co"].stringValue) \(resultJson["card_nm"].stringValue)"
                        self.lbCardStatus.textColor = UIColor(named: "content-positive")
                        self.lbCardInfo.text = "카드 정상 등록 완료"                        
                        AmplitudeManager.shared.createEventType(type: PaymentEvent.completePaymentCard)
                            .logEvent()
                        
                        if self.totalPoint > self.totalAmount {
                            // dialog
                            let dialogMessage = UIAlertController(title: "변경된 카드로 결제가 진행됩니다", message: "베리로 미수금 결제를 원하시는 경우, 취소를 누른 뒤 결제 재시도를 눌러주세요.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "결제", style: .default, handler: {(ACTION) -> Void in
                                self.requestRepay(byPoint: false)
                            })
                            let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
                                self.dismiss(animated: true, completion: nil)
                            })
                            
                            dialogMessage.addAction(ok)
                            dialogMessage.addAction(cancel)
                            self.present(dialogMessage, animated: true, completion: nil)
                        } else {
                            self.requestRepay(byPoint: false)
                        }
                    }
                } else { // login done
                    self.requestFailedPayList()
                }
                self.payRegisterResult = nil
            } else {
                MemberManager.shared.showLoginAlert()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        cbUsePoint.boxType = .square
        viewCardInfo.layer.cornerRadius = 10
        viewFailedInfo.layer.cornerRadius = 10
        btnRetry.layer.cornerRadius = 6
        btnChangeCard.layer.cornerRadius = 6
    }
    
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        navigationItem.hidesBackButton = true
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "미수금 안내"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func prepareView() {
        let tapTouch = UITapGestureRecognizer(target: self, action: #selector(self.onTouchUsePoint))
        viewUsePoint.addGestureRecognizer(tapTouch)
        cbUsePoint.tintColor = UIColor(named: "content-primary")
    }
    
    @objc
    fileprivate func handleBackButton() {
        guard let _navi = navigationController else { return }
        for vc in _navi.viewControllers {
            if vc is MembershipCardViewController {
                _navi.popToRootViewController(animated: true)
                return
            } else {
                _navi.pop()
            }
        }
        if let del = self.delegate {
            del.onRepayFail()
        }// result code false
    }
    
    func requestFailedPayList() {
        Server.getFailedPayList() {
            (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                self.responseFailedPayList(response: json)
            }
        }
    }
    
    func responseFailedPayList(response: JSON) {
        if response.isEmpty || response["code"] != 1000 {
            Snackbar().show(message: response["msg"].stringValue)
        }
    
        lbCardInfo.text = "\(response["pay_card_co"].stringValue) \(response["pay_card_nm"].stringValue)"
        
        if response["pay_card_msg"].exists() {
            showCardStatus()
            lbCardStatus.text = response["pay_card_msg"].stringValue
        }
        
        totalPoint = response["total_point"].intValue
        lbUsePoint.text = "베리로 결제하기 (현재 베리 : \(totalPoint)베리)"
        
        if response["history"].exists() {
            let jsonData = try! JSONSerialization.data(withJSONObject: response["history"].rawValue, options: [])
            let history = try! JSONDecoder().decode(ChargingHistoryList.self, from: jsonData)
            totalAmount = Int(history.total_pay! as String)!
            lbTotalAmount.text = "\(totalAmount)"
            
            if totalPoint < totalAmount {
                viewUsePoint.isUserInteractionEnabled = false
                cbUsePoint.checkState = .unchecked
                cbUsePoint.tintColor = UIColor(named: "content-disabled")
                lbUsePoint.textColor = UIColor(named: "content-disabled")
            }
            
            if let failedList = history.list {
                paymentList.removeAll()
                lbFailedListCnt.text = "\(failedList.count)"
                let otherCnt = failedList.count - 5
                if otherCnt > 0 {
                    lbOtherCnt.text = "외 미수금 발생 \(otherCnt)건"
                    paymentList = failedList.slice(start: 0, end: 4)
                } else {
                    paymentList = failedList
                    lbOtherCnt.visiblity(gone: true)
                }
                tableFailedList.reloadData()
                tableViewHeight.constant = tableFailedList.contentSize.height
                tableFailedList.layoutIfNeeded()
            }
        }
    }
    
    func showCardStatus() {
        lbCardStatus.isHidden = false
        viewCardInfoHeight.constant = 72
        viewCardInfo.sizeToFit()
    }
    
    @objc
    fileprivate func onTouchUsePoint(recognizer: UITapGestureRecognizer) {
        let checked = self.cbUsePoint.checkState
        if checked == .checked {
            self.cbUsePoint.checkState = .unchecked
        } else {
            self.cbUsePoint.checkState = .checked
        }
    }
    
    @IBAction func onClickRetry(_ sender: Any) {
        requestRepay(byPoint: self.cbUsePoint.checkState == .checked)
    }
    
    @IBAction func onClickChangeCard(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "카드를 변경하시겠습니까?", message: "카드 변경 진행 시, 변경 완료 후 기존에 등록된 카드는 삭제됩니다. ", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            let memberStoryboard = UIStoryboard(name : "Member", bundle: nil)
            let payRegistVC = memberStoryboard.instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
            payRegistVC.myPayRegisterViewDelegate = self
            self.navigationController?.push(viewController: payRegistVC)
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func finishRegisterResult(json: JSON) {
        payRegisterResult = json
    }
    
    func onCancelRegister() {
        Snackbar().show(message: "결제 카드 변경을 취소했습니다.")
    }
    
    func onConfirmBtnPressed() {
        self.navigationController?.pop()
        if let del = self.delegate {
            del.onRepaySuccess()
        }
    }
    
    func requestRepay(byPoint: Bool) {
        var point = 0
        if byPoint {
            point = totalPoint
        }
        viewProcessing.isHidden = false
        Server.repayCharge(usePoint: point) {(isSuccess, responseData) in
            if isSuccess {
                if let data = responseData {
                    let paymentStatus = try! JSONDecoder().decode(ChargingStatus.self, from: data)
                    let resultVC = self.storyboard!.instantiateViewController(withIdentifier: "RepayResultViewController") as! RepayResultViewController
                    resultVC.delegate = self
                    resultVC.payResult = paymentStatus
                    self.navigationController?.push(viewController: resultVC)
                    
                }
            } else {
                Snackbar().show(message: "오류가 발생했습니다. 다시 시도해 주세요.")
            }
            self.viewProcessing.isHidden = true
        }
    }
}

extension RepayListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
        cell.reloadPaymentData(payment: self.paymentList[indexPath.row])
        return cell
    }
    
    func prepareTableView() {
        self.tableFailedList.delegate = self
        self.tableFailedList.dataSource = self
        self.tableFailedList.estimatedRowHeight = 71.5
    }
}
