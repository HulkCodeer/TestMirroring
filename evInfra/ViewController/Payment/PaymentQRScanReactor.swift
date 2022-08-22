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
        case setQRReaderView
        case loadPaymentStatus
        case loadChargingQR(String)
        case loadTestChargingQR(String)
    }
    
    enum Mutation {
        case setPaymentStatus(Bool)
        case setChargingStatus(Bool)
    }
    
    struct State {
        var isPaymentFineUser: Bool?
        var isChargingStatus: Bool?
    }
    
    internal var initialState: State

    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setQRReaderView:
            return .just(.setPaymentStatus(false))
            
        case .loadPaymentStatus:
            return self.provider.postPaymentStatus()
                .convertData()
                .compactMap(convertToDataModel)
                .compactMap { isPaymentFineUser in
                    return .setPaymentStatus(isPaymentFineUser)
                }
            
        case .loadChargingQR(let qrCode):
            return self.provider.postChargingQR(qrCode: qrCode)
                .convertData()
                .compactMap(convertToChargingSuccess)
                .compactMap { isChargingStatus in
                    return .setChargingStatus(isChargingStatus)
                }
            
        case .loadTestChargingQR(let tc):
            return self.provider.postChargingQR(qrCode: "", tc: tc)
                .convertData()
                .compactMap(convertToChargingSuccess)
                .compactMap { isChargingStatus in
                    return .setChargingStatus(isChargingStatus)
                }
                                
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.isPaymentFineUser = nil
        newState.isChargingStatus = nil
        
        switch mutation {
        case .setPaymentStatus(let isPaymentFineuser):
            newState.isPaymentFineUser = isPaymentFineuser
            
        case .setChargingStatus(let isChargingStatus):
            newState.isChargingStatus = isChargingStatus
            
        }
        
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiError>) -> Bool? {
        switch result {
        case .success(let data):
            let json = JSON(data)
//                let payCode = json["pay_code"].intValue
            let payCode = 8800
            
            switch PaymentStatus(rawValue: payCode) {
            case .PAY_FINE_USER :
                return true
                
            case .PAY_NO_USER, .PAY_NO_CARD_USER:
                self.showRegisterCardDialog()
                return false
                
            case .PAY_DEBTOR_USER:
                let viewcon = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(ofType: RepayListViewController.self)
//                viewcon.delegate = self
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
            
            guard code == 1000 else { return nil }
            return true
            
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

extension PaymentQRScanReactor {
    func readerComplete(status: ReaderStatus) {
        switch status {
        case .success(let qrStr):
            guard let _qrStr = qrStr else {
                return
            }
            self.onResultScan(scanInfo: _qrStr)
            
        case .fail:
            printLog(out: "QR코드 or 바코드를 인식하지 못했습니다.\n다시 시도해주세요.")
            
        case .stop: break
        }
    }
    
    func onResultScan(scanInfo: String?) {
//        var cpId = ""
//        self.connectorId = nil
//
//        if let resultQR = scanInfo {
//            if resultQR.count > 0 {
//                let qrJson = JSON.init(parseJSON: resultQR)
//                cpId = qrJson["cp_id"].stringValue
//                self.connectorId = qrJson["connector_id"].stringValue
//            }
//        }
//
//        if !cpId.isEmpty {
//            Server.getChargerInfo(cpId: cpId, completion: {(isSuccess, value) in
//                if isSuccess {
//                    self.responseGetChargerInfo(response: value)
//                } else {
//                    self.showUnsupportedChargerDialog()
//                }
//            })
//        } else {
//            self.showUnsupportedChargerDialog()
//        }
    }
}
