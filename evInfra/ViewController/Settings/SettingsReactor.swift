//
//  SettingsReactor.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/06/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import ReactorKit

internal final class SettingsReactor: ViewModel, Reactor {
    enum Action {
        case none
    }
    
    enum Mutation {
        case none
    }
    
    struct State {
        var ga360 = ""
    }
    
    internal var initialState: State
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .none:
            return .just(.none)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .none: break
        }
        return newState
    }
    
//    private func convertToItem(with model: ProductZzimDataModel) -> [ProductZzimListItem] {
//        guard !model.productWishStoreList.isEmpty else {
//            return []
//        }
//        return model.productWishStoreList.compactMap { [weak self] data -> ProductZzimListItem? in
//            guard let self = self else { return nil }
//            let reactor = ProductZzimListUserItemReactor(model: data, service: self.service)
//            reactor.state.map { $0.sellerCategoryItem }
//                .filterNil()
//                .subscribe(onNext: { [weak self] data in
//                    guard let self = self else { return }
//                    self.provider.setFollower(storeSeq: data.storeSeq, method: data.followingYn == 1 ? .delete : .post)
//                        .trackError(self.error)
//                        .materialize()
//                        .map { (event: $0, item: data, setFollow: data.followingYn == 1 ? 0 : 1) }
//                        .compactMap(self.convertTpFollowAction)
//                        .bind(to: reactor.action)
//                        .disposed(by: self.disposeBag)
//                })
//                .disposed(by: self.disposeBag)
//
//            reactor.state.map { $0.selectedStoreData }
//                .asDriver(onErrorJustReturn: nil)
//                .filterNil()
//                .drive(onNext: { data in
//                    GlobalFunctionSwift.openStore(storeSeq: data.storeSeq, reactorData: reactor)
//                })
//                .disposed(by: self.disposeBag)
//
//            return .productZzimListUserItem(reactor: reactor, viewModel: ProductZzimEmptyViewModel())
//        }
//    }
    
//    private func convertTpFollowAction(with data: (event: Event<Data>, item: ProductZzimDataModel.StoreDataModel, setFollow: Int)) -> ProductZzimListUserItemReactor<ProductZzimDataModel.StoreDataModel>.Action? {
//        switch data.event {
//        case .next:
//            let followStr = data.setFollow == 0 ? "해제" : "추가"
//            GlobalFunctionSwift.sharedInstance.showSimpleToast("이 가게를 단골 \(followStr)합니다.")
//            let eventModel = GA360QueryModel.EventModel(ec: "찜한사람 리스트", ea: "단골 \(followStr)", el: "\(data.item.nickName)_단골\(followStr)")
//            GA360.trackingGA360(pName: "\(GA360.trackingGA360PageNameForEventStr)",
//                                eventModel: eventModel,
//                                vc: "\(GA360.trackingGA360ViewControllerForEventStr)")
//            var _data = data.item
//            _data.followingYn = data.setFollow
//            return ProductZzimListUserItemReactor.Action.changeFollow(_data)
//
//        case .error(let error):
//            if let errorResponse = error as? ApiError {
//                errorResponse.taskError("\(type(of: self))")
//            }
//            return nil
//
//        default:
//            return nil
//        }
//    }
    
//    private func convertToDataModel(with event: Event<Data>) -> ProductZzimDataModel? {
//        switch event {
//        case .next(let data):
//            let jsonData = JSON(data)["data"]
//            let model = ProductZzimDataModel(jsonData)
//            if self.paramModel.startIndex == 0 {
//                Observable.just(Action.fetchProductInfo(ProductInfoModel(productTitle: model.product.productTitle, productImage: model.product.productImage, productPrice: model.product.productPrice, platformType: model.product.platformType, totalSize: model.total)))
//                    .observeOn(MainScheduler.asyncInstance)
//                    .bind(to: self.action)
//                    .disposed(by: self.disposeBag)
//            }
//            if model.productWishStoreList.count >= 20 {
//                self.paramModel.startIndex += 1
//            } else {
//                self.paramModel.startIndex = -1
//            }
//            return model
//
//        case .error(let error):
//            if let errorResponse = error as? ApiError {
//                errorResponse.taskError("\(type(of: self))")
//            }
//            return nil
//
//        default:
//            return nil
//        }
//    }
}
