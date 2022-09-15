//
//  NoticeReactor.swift
//  evInfra
//
//  Created by youjin kim on 2022/08/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

import ReactorKit
import RxSwift

final class NoticeReactor: ViewModel, Reactor {
    enum Action {
        case loadNotices
    }
    
    enum Mutation {
        case setNotices([NoticeCellItem])
    }
    
    struct State {
        var noticeList: [NoticeSectionModel] = []
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadNotices:
            return provider.getNoticeList()
                .convertData()
                .compactMap(convertToNoticeItems)
                .map (convertToCellItem)
                .map { return .setNotices($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNotices(let item):
            newState.noticeList = [NoticeSectionModel(items: item)]
        }
        
        return newState
    }
    
    private func convertToNoticeItems(with result: ApiResult<Data, ApiError>) -> [NoticeItem]? {
        switch result {
        case .success(let data):
            let noticeList = try? JSONDecoder().decode(NoticeList.self, from: data)
            guard 1000 == noticeList?.code else { return nil }
            
            return noticeList?.list
            
        case .failure(let error):
            printLog(out: "Error Message : \(error.errorMessage)")
            Snackbar().show(message: "오류가 발생했습니다. 잠시 후 다시 시도해주세요.")
            return nil
        }
    }
    
    private func convertToCellItem(items: [NoticeItem]) -> [NoticeCellItem] {
        return items.compactMap { item in
            guard let date = item.dateTime.toDate() else { return nil }
            
            let reactor = NoticeCellReactor(title: item.title, date: date.toString(dateFormat: .yyyyMMddD))
            
            reactor.state.compactMap { $0.isMoveDetail }
                .asDriver(onErrorJustReturn: false)
                .filter { $0 == true }
                .drive { _ in
                    let noticeID = Int(item.id) ?? -1
                    let noticeDetailReactor = NoticeDetailReactor(provider: RestApi(), noticeID: noticeID)
                    let noticeDetailVC = NewNoticeDetailViewController(reactor: noticeDetailReactor)
                    GlobalDefine.shared.mainNavi?.push(viewController: noticeDetailVC)
                }
                .disposed(by: self.disposeBag)
            
            return NoticeCellItem(reactor: reactor)
        }
    }
}
