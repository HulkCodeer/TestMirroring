//
//  GlobalFunction.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/08/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

internal final class GlobalFunctionSwift {
    internal static let sharedInstance = GlobalFunctionSwift()
    private init() {}
        
    // 버튼 한개, 버튼 초록색
    class func showPopup(title: String, message: String, confirmBtnTitle: String) {
        let popupModel = PopupModel(title: "\(title)",
                                    message: "\(message)",
                                    confirmBtnTitle: "\(confirmBtnTitle)",
                                    textAlignment: .center)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    // 버튼 한개, 버튼 초록색, 액션 있을때
    class func showPopup(title: String, message: String, confirmBtnTitle: String, confirmBtnAction: (() -> Void)? = nil) {
        let popupModel = PopupModel(title: "\(title)",
                                    message: "\(message)",
                                    cancelBtnTitle: "\(confirmBtnTitle)",
                                    cancelBtnAction: confirmBtnAction,
                                    textAlignment: .center)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    // 버튼 한개, 버튼 초록색, 액션 있을때, 딤드 터치 못하게
    class func showPopup(title: String, message: String,
                         confirmBtnTitle: String, confirmBtnAction: (() -> Void)? = nil, dimmedBtnAction: (() -> Void)? = nil) {
        let popupModel = PopupModel(title: "\(title)",
                                    message: "\(message)",
                                    confirmBtnTitle: "\(confirmBtnTitle)",
                                    confirmBtnAction: confirmBtnAction,
                                    textAlignment: .center, dimmedBtnAction: dimmedBtnAction)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    // 버튼 한개, 버튼 흰색
    class func showPopup(title: String, message: String, cancelBtnTitle: String) {
        let popupModel = PopupModel(title: "\(title)",
                                    message: "\(message)",
                                    cancelBtnTitle: "\(cancelBtnTitle)",
                                    textAlignment: .center)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    // 버튼 한개, 버튼 흰색, 액션 있을때
    class func showPopup(title: String, message: String, cancelBtnTitle: String, cancelBtnAction: (() -> Void)? = nil) {
        let popupModel = PopupModel(title: "\(title)",
                                    message: "\(message)",
                                    cancelBtnTitle: "\(cancelBtnTitle)",
                                    cancelBtnAction: cancelBtnAction,
                                    textAlignment: .center)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
            
    // 버튼 두개, 초록색 버튼 액션 있을때
    class func showPopup(title: String, message: String, confirmBtnTitle: String, confirmBtnAction: (() -> Void)? = nil, cancelBtnTitle: String) {
        let popupModel = PopupModel(title: "\(title)",
                                    message: "\(message)",
                                    confirmBtnTitle: "\(confirmBtnTitle)",
                                    cancelBtnTitle: "\(cancelBtnTitle)",
                                    confirmBtnAction: confirmBtnAction,
                                    textAlignment: .center)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    // 버튼 두개, 버튼 둘다 액션 있을때
    class func showPopup(title: String, message: String, confirmBtnTitle: String, confirmBtnAction: (() -> Void)? = nil,
                         cancelBtnTitle: String, cancelBtnAction: (() -> Void)? = nil) {
        let popupModel = PopupModel(title: "\(title)",
                                        message: "\(message)",
                                    confirmBtnTitle: "\(confirmBtnTitle)",
                                    cancelBtnTitle: "\(cancelBtnTitle)",
                                    confirmBtnAction: confirmBtnAction,
                                    cancelBtnAction: cancelBtnAction,
                                    textAlignment: .center)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    // 버튼 두개, 버튼 둘다 액션 있을때, 딤드 터치 따로 처리 하고 싶을때
    class func showPopup(title: String, message: String, confirmBtnTitle: String, confirmBtnAction: (() -> Void)? = nil,
                         cancelBtnTitle: String, cancelBtnAction: (() -> Void)? = nil, dimmedBtnAction: (() -> Void)? = nil) {
        let popupModel = PopupModel(title: "\(title)",
                                        message: "\(message)",
                                    confirmBtnTitle: "\(confirmBtnTitle)",
                                    cancelBtnTitle: "\(cancelBtnTitle)",
                                    confirmBtnAction: confirmBtnAction,
                                    cancelBtnAction: cancelBtnAction,
                                    textAlignment: .center,
                                    dimmedBtnAction: dimmedBtnAction)
        
        let popup = VerticalConfirmPopupViewController(model: popupModel)
        GlobalDefine.shared.mainNavi?.present(popup, animated: false, completion: nil)
    }
    
    class func getLastPushVC() -> UIViewController? {
        if let _vc = GlobalDefine.shared.mainNavi?.viewControllers.last {
            return _vc
        }
        return nil
    }
}
