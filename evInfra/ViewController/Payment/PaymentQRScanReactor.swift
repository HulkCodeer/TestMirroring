//
//  File.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/20.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit
import SwiftyJSON

internal final class PaymentQRScanReactor: ViewModel, Reactor {
    enum Action {
        case runningQRReaderView
        case loadPaymentStatus
        case loadFirstChargingQR(String)
        case loadChargingQR(String, Int)
        case loadTestChargingQR(String)
        case startQRReaderView(Bool)
        case qrOutletType([QROutletTypeModel])
    }
    
    enum Mutation {
        case setPaymentStatus(Bool)
        case setChargingStatus(Bool)
        case setRunnigQRReaderView(Bool)
        case setQROutletType([QROutletTypeModel])
    }
    
    struct State {
        var isPaymentFineUser: Bool?        
        var isQRScanRunning: Bool = false
        var qrOutletTypeModel: [QROutletTypeModel]?
    }
    
    internal var initialState: State
    internal var qrCode: String = ""

    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {                        
        case .runningQRReaderView:
            return .just(.setPaymentStatus(false))
            
        case .loadPaymentStatus:
            return self.provider.postPaymentStatus()
                .convertData()
                .compactMap(convertToDataModel)
                .compactMap { isPaymentFineUser in
                    return .setPaymentStatus(isPaymentFineUser)
                }
            
        case .loadFirstChargingQR(let qrCode):
            self.qrCode = qrCode
            return self.provider.postChargingQR(qrCode: qrCode, typeId: 0)
                .convertData()
                .compactMap(convertToChargingSuccess)
                .compactMap { isChargingStatus in
                    return .setChargingStatus(isChargingStatus)
                }
            
        case .loadChargingQR(let qrCode, let typeId):
            return self.provider.postChargingQR(qrCode: qrCode, typeId: typeId)
                .convertData()
                .compactMap(convertToChargingSuccess)
                .compactMap { isChargingStatus in
                    return .setChargingStatus(isChargingStatus)
                }
            
        case .loadTestChargingQR(let tc):
            return self.provider.postChargingQR(qrCode: "", typeId: 0, tc: tc)
                .convertData()
                .compactMap(convertToChargingSuccess)
                .compactMap { isChargingStatus in
                    return .setChargingStatus(isChargingStatus)
                }
            
        case .startQRReaderView(let isRunning):
            return .just(.setRunnigQRReaderView(isRunning))
            
        case .qrOutletType(let outletType):
            return .just(.setQROutletType(outletType))
                                
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isPaymentFineUser = nil
        newState.qrOutletTypeModel = nil
        
        switch mutation {
        case .setPaymentStatus(let isPaymentFineuser):
            newState.isPaymentFineUser = isPaymentFineuser
            newState.isQRScanRunning = isPaymentFineuser
            
        case .setChargingStatus(let isChargingStatus):
            newState.isQRScanRunning = isChargingStatus
            
        case .setRunnigQRReaderView(let isRunning):
            newState.isQRScanRunning = isRunning
            
        case .setQROutletType(let outletType):
            newState.qrOutletTypeModel = outletType
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiError>) -> Bool? {
        switch result {
        case .success(let data):
            let json = JSON(data)
                        
            let payCode = json["pay_code"].intValue
//            let payCode = 8800
            
            switch PaymentStatus(rawValue: payCode) {
            case .PAY_FINE_USER :
                return true
                
            case .PAY_NO_USER, .PAY_NO_CARD_USER:
                let popupModel = PopupModel(title: "결제정보를 등록해야 해요",
                                            message: "회원카드를 발급 해야 한국전력, GS칼텍스의 QR 충전을 이용할 수 있어요.",
                                            confirmBtnTitle: "회원카드 발급하기", cancelBtnTitle: "닫기",
                                            confirmBtnAction: {
                    let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: MyPayinfoViewController.self)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                }, textAlignment: .center)
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                return false
                
            case .PAY_DEBTOR_USER:
                let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                viewcon.delegate = self
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                return false
                
            case .PAY_NO_VERIFY_USER, .PAY_DELETE_FAIL_USER:
                let resultMessage = json["ResultMsg"].stringValue
                let message = resultMessage.replacingOccurrences(of: "\\n", with: "\n")
                self.showAlertDialogByMessage(message: message)
                return false
                
            case .PAY_REGISTER_FAIL_PG:
                self.showAlertDialogByMessage(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
                return false
                
            default: return false
            }
            
        case .failure(let errorMessage):
            printLog(out: "error: \(errorMessage)")
            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            return false
        }
    }
    
    private func convertToChargingSuccess(with result: ApiResult<Data, ApiError>) -> Bool? {
        switch result {
        case .success(let data):
            let json = JSON(data)
            let code = json["code"].intValue
            let title = json["title"].stringValue
            let msg = json["msg"].stringValue
                     
            // 에러 코드 참고 https://docs.google.com/spreadsheets/d/1Zr-Xh92HCQ5AKXxsCK-c7PY1J2jt_QnHxZIuUfYjyek/edit#gid=0
            switch code {
            case 1000: // 정상 유저
                let chargingId = json["charging_id"].stringValue
                let reactor = PaymentStatusReactor(provider: RestApi())
                let viewcon = NewPaymentStatusViewController(reactor: reactor)
                viewcon.chargingId = chargingId
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                return true
                                                
            case 8801: // 결제 정보 등록 안된 회원
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "회원카드 발급하기", cancelBtnTitle: "닫기",
                                            confirmBtnAction: {
                    let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: MyPayinfoViewController.self)
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                }, cancelBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                }, textAlignment: .center)
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                
                
            case 8802: // 카드 등록 안된 멤버
                let popupModel = PopupModel(title: "\(title)",
                                           message: "\(msg)",
                                            confirmBtnTitle: "나가기", confirmBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                }, textAlignment: .center, dimmedBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                })
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                
            case 8803: // 카드삭제했으나 DB 쿼리 실패로 안지워짐
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "결제정보 등록하기",
                                            cancelBtnTitle: "나가기",
                                            confirmBtnAction: {                    
                    let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(withIdentifier: "MyPayRegisterViewController") as! MyPayRegisterViewController
                    viewcon.myPayRegisterViewDelegate = self
                    GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                },
                                            cancelBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                },
                                            textAlignment: .center, dimmedBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                })
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                
            case 8804: // 미수금
                let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                
            case 8145: // PG사 기타 오류
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "결제정보 등록하기", cancelBtnTitle: "나가기",
                                            confirmBtnAction: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let viewcon = MembershipGuideViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    })
                }, cancelBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                } , textAlignment: .center, dimmedBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                })
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                
            case 1101: // 회원카드 없는 멤버
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "회원카드 발급하기", cancelBtnTitle: "나중에 하기",
                                            confirmBtnAction: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let viewcon = MembershipGuideViewController()
                        GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
                    })
                }, textAlignment: .center)
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                                            
            case 2005: // cp id에 해당하는 충전기가 db에 없음
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "나가기",
                                            confirmBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                }, textAlignment: .center)
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                                            
            case 2007: // 시범 운영중
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "나가기",
                                            confirmBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                },
                                            textAlignment: .center)
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                
            case 2008: // 충전기 상태가 충전 가능이 아님
                let popupModel = PopupModel(title: "\(title)",
                                            message: "\(msg)",
                                            confirmBtnTitle: "나가기",
                                            confirmBtnAction: {
                    GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
                },textAlignment: .center)
                
                let popup = VerticalConfirmPopupViewController(model: popupModel)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
                })
                              
            case 2004, 2006, 2009, 2010, 9000: // 서버 에러
                Snackbar().show(message: "\(msg)")
                
            case 2012: // 한전 충전 타입 선택 해야 하는 충전기
                let model = json["type_id"].arrayValue.map { QROutletTypeModel($0) }
                Observable.just(PaymentQRScanReactor.Action.qrOutletType(model))
                    .bind(to: self.action)
                    .disposed(by: self.disposeBag)
                                                                
                
            default:
                GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
            }
            
            return false
            
        case .failure(let errorMessage):
            printLog(out: "error: \(errorMessage)")
            Snackbar().show(message: "서버와 통신이 원활하지 않습니다. 결제정보관리 페이지 종료후 재시도 바랍니다.")
            return false
        }
    }
    
    private func showUnsupportedChargerDialog() {
        let dialogMessage = UIAlertController(title: "미지원 충전기", message: "결제 가능 충전소가 아니거나, 등록 되지않은 QR 코드입니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            GlobalDefine.shared.mainNavi?.pop()
        })
        
        dialogMessage.addAction(ok)
        GlobalDefine.shared.mainNavi?.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func showAlertDialogByMessage(message: String) {
        let dialogMessage = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            GlobalDefine.shared.mainNavi?.pop()
        })
        
        dialogMessage.addAction(ok)
        GlobalDefine.shared.mainNavi?.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func showRegisterCardDialog() {
        let dialogMessage = UIAlertController(title: "카드 등록 필요", message: "결제카드 등록 후 사용 가능합니다. \n카드를 등록하시려면 확인 버튼을 누르세요.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default, handler: {(ACTION) -> Void in
            let viewcon = UIStoryboard(name : "Member", bundle: nil).instantiateViewController(ofType: MyPayinfoViewController.self)
            GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            GlobalDefine.shared.mainNavi?.pop()
        })
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        GlobalDefine.shared.mainNavi?.present(dialogMessage, animated: true, completion: nil)
    }    
}

extension PaymentQRScanReactor: RepaymentListDelegate {
    func onRepaySuccess() {
        Observable.just(PaymentQRScanReactor.Action.startQRReaderView(true))
            .bind(to: self.action)
            .disposed(by: self.disposeBag)
    }
    
    func onRepayFail(){
        GlobalDefine.shared.mainNavi?.popToRootViewController(animated: true)
    }
}

extension PaymentQRScanReactor: MyPayRegisterViewDelegate {
    func onCancelRegister() {
    }
    
    func finishRegisterResult(json: JSON) {
        if (json["pay_code"].intValue == PaymentCard.PAY_REGISTER_SUCCESS) {
            Observable.just(PaymentQRScanReactor.Action.startQRReaderView(true))
                .bind(to: self.action)
                .disposed(by: self.disposeBag)
        } else {
            if json["resultMsg"].stringValue.isEmpty {
                Snackbar().show(message: "카드 등록을 실패하였습니다. 다시 시도해 주세요.")
            } else {
                Snackbar().show(message: json["resultMsg"].stringValue)
            }            
        }
    }
}
