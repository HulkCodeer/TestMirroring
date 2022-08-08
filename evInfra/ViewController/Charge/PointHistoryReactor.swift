//
//  PointViewReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/05.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift
import SwiftyJSON

internal class PointHistoryReactor: ViewModel, Reactor {
    
    enum Action {
        case loadHistoryDate(startDate: Date, endDate: Date) //베리 내역 불러올 날짜 선택하다.
        case loadPointHistory(PointHistoryViewController.PointType)
    }
    
    enum Mutation {
        case setPointHistory(PointHistory)
        
    }
    
    struct State {
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadHistoryDate(startDate, endDate):
            return Observable.empty()  // 나중에 추가.
        case .loadPointHistory(let type):
            return Observable.empty()
        }
        
        // 두개 같이 묶어서 하나라도 바뀌면 바뀌는 걸로!
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
//        switch mutation {
//
//        }
        return State()
    }
    
    /*
     1. 로그인 여부 판단
        1-1: 로그인 Ok ->
        1-2: 로그인 no -> 로그인 alert 보여주기. MemberManager.shared.showLoginAlert()
     
     2. pointHistory 불러오기: Server.getPointHistory
        - 성공시
     
     */
    
    // 2. pointHistory 불러오기
    private func loadPointHistory() {
        // 최초에는 오늘
        // 그뒤 선택날짜 기준.
        // 얘도 수정해야될듯..ㅅㅂ
        
//        Server.getPointHistory(isAllDate: false, sDate: <#T##String#>, eDate: <#T##String#>, completion: <#T##(Bool, Data?) -> Void#>)
    }
}
