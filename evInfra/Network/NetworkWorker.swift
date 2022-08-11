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
    
    func rxRequest(url: String, httpMethod: Alamofire.HTTPMethod, parameters: [String: Any]?, headers: HTTPHeaders?) -> Disposable {
        
        #if DEBUG
            let debugDesc = """
            <URL: \(httpMethod.rawValue)> \(url)
            parameter: \(parameters ?? [:])
            """
            printLog(out: debugDesc)
        #endif
        
        
        _ = RxAlamofire.request(httpMethod, url,
                                   parameters: parameters,
                                   encoding: JSONEncoding.default,
                                   headers: headers)
        
        return Disposables.create {}
    }
}

extension Observable where Element == (HTTPURLResponse, Data){
    internal func convertData() -> Observable<ApiResult<Data, ApiError>>{
        return self.map { (httpURLResponse, data) -> ApiResult<Data, ApiError> in
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
                let apiError: ApiError
                apiError = ApiError(JSON(data))
                
                switch apiError.body.code {
                case 5001...5020: // 입력값 관련(앱/웹 쪽 처리 포함)
                    return .failure(apiError)
                    
                case 5021...5060, 5071...5099: // 서버 처리 관련(비지니스 로직 포함), gateway 관련(AWS API G/W)
                    GlobalDefine.shared.mainNavi?.pop()
                    return .failure(apiError)
                    
                case 5061...5070 : // 외부 API 연동 관련, DB 관련 에러 ,시스템 관련, 기타 / 예비
                    return .failure(apiError)
                                                        
                default:
                    return .failure(apiError)
                }
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

struct ApiError {
    var errorMessage: String
    var message: String
    var body: ApiErrorBody
    
    init(_ json: JSON) {
        self.errorMessage = json["errorMessage"].stringValue
        self.message = json["message"].stringValue
        self.body = ApiErrorBody(json)
    }
}

struct ApiErrorBody {
    var code: Int
    var msg: String
    
    init(_ json: JSON) {
        self.code = json["code"].intValue
        self.msg = json["msg"].stringValue
    }
}
