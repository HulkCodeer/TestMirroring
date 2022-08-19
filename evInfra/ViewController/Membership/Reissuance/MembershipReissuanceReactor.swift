//
//  MembershipReissuanceReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal final class MembershipReissuanceReactor: ViewModel, Reactor {
    enum Action {
        case getCheckPassword(String)
    }
    
    enum Mutation {
        case setAddressInfo(AddressInfo)
        case none
    }
    
    struct State {
        var addressInfo: AddressInfo?
    }
    
    internal var initialState: State
    internal var cardNo: String = ""
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    struct AddressInfo {
        let code:Int
        let info: Info
        let msg: String
        
        init(_ json: JSON) {
            self.code = json["code"].intValue
            self.info = Info(json["info"])
            self.msg = json["msg"].stringValue
        }
                
        struct Info: Codable {
            let zipCode: String
            let phoneNo: String
            let mbName: String
            let addr: String
            let addrDetail: String
            
            init(_ json: JSON) {
                self.zipCode = json["mb_zip_code"].stringValue
                self.phoneNo = json["mb_callnumber"].stringValue
                self.mbName = json["mb_name"].stringValue
                self.addr = json["mb_addr"].stringValue
                self.addrDetail = json["mb_addr_detail"].stringValue
            }
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getCheckPassword(let password):
            return self.provider.getCheckPassword(password: password, cardNo: self.cardNo)
                .convertData()
                .compactMap(convertToDataModel)
                .map { addressInfo in .setAddressInfo(addressInfo) }                        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.addressInfo = nil
        
        switch mutation {
        case .setAddressInfo(let adrressInfo):
            newState.addressInfo = adrressInfo
            
        case .none: break
        }
        return newState
    }
    
    private func convertToDataModel(with result: ApiResult<Data, ApiError> ) -> AddressInfo? {
        switch result {
        case .success(let data):
            let jsonData = JSON(data)
            printLog(out: "JsonData : \(jsonData)")
            return AddressInfo(jsonData)
            
        case .failure(let errorMessage):
            printLog(out: "Error Message : \(errorMessage)")
            return nil
        }
    }
}
