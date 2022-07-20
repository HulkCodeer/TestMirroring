//
//  NetWorker.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxAlamofire
import Alamofire
import SwiftyJSON

internal final class NetworkWorker {
    internal static var shared = NetworkWorker()
        
    func rxRequest(url: String, httpMethod: Alamofire.HTTPMethod, parameters: [String: Any]?, headers: HTTPHeaders?) -> Observable<(HTTPURLResponse, Data)> {
        
        #if DEBUG
            let debugDesc = """
            <URL: \(httpMethod.rawValue)> \(url)
            parameter: \(parameters ?? [:])
            """
            printLog(out: debugDesc)
        #endif
        
        return RxAlamofire.request(httpMethod, url,
                                   parameters: parameters,
                                   encoding: JSONEncoding.default,
                                   headers: headers).responseData()
    }
}

extension Observable where Element == (HTTPURLResponse, Data){
    internal func convertData() -> Observable<ApiResult<Data, ApiErrorMessage>>{
        return self.map { (httpURLResponse, data) -> ApiResult<Data, ApiErrorMessage> in
            #if DEBUG
                var strResponse: String?
                if let str = String(data: data, encoding: .utf8) {
                    strResponse = str
                }
                let debugDesc = """
                code: \(httpURLResponse.statusCode)
                ========== Response DATA ==========
                
                \(strResponse ?? String(decoding: data, as: UTF8.self))
                
                ========== Response END ==========
                """
                printLog(out: debugDesc)
            #endif
            
            switch httpURLResponse.statusCode{
            case 200 ... 299:                
                printLog(out: "Request URL : \(String(describing: httpURLResponse.url?.description ?? ""))")
                return .success(data)
                                
            default:
                printLog(out: "Request URL : \(String(describing: httpURLResponse.url?.description ?? ""))")
                let apiErrorMessage: ApiErrorMessage
                do{
                    apiErrorMessage = try JSONDecoder().decode(ApiErrorMessage.self, from: data)
                } catch _ {
                    apiErrorMessage = ApiErrorMessage(errorMessage: "\(String(decoding: data, as: UTF8.self))")
                }
                return .failure(apiErrorMessage)
            }
        }
    }
}

enum ApiResult<Data, Error>{
    case success(Data)
    case failure(Error)
    
    init(value: Data){
        self = .success(value)
    }
    
    init(error: Error){
        self = .failure(error)
    }
}

struct ApiErrorMessage: Codable{
    var errorMessage: String
}
