//
//  FilterReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class GlobalFilterReactor: ViewModel, Reactor {
    typealias SelectedAccessFilter = (accessType: AccessType, isSelected: Bool)
    
    enum Action {
        case loadCompanies
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case changedAccessFilter(SelectedAccessFilter)
        case setAccessFilter(SelectedAccessFilter)
    }
    
    enum Mutation {
        case loadCompanies([Company])
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case changedAccessFilter(SelectedAccessFilter)
    }

    struct State {
        var loadedCompanies: [Company] = []
        var isSelectedAllCompanies: Bool = true
        var isChangedFilter: Bool = false
        var selectedAccessFilter: SelectedAccessFilter?
        var isPublic: Bool = FilterManager.sharedInstance.filter.isPublic
        var isNonPublic: Bool = FilterManager.sharedInstance.filter.isNonPublic
    }
    
    internal var initialState: State
    static let sharedInstance: GlobalFilterReactor = GlobalFilterReactor(provider: RestApi())
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadCompanies:
            let companyValues: [CompanyInfoDto] = FilterManager.sharedInstance.filter.companyDictionary.map { $0.1 }
            
            let wholeList = companyValues.sorted { $0.name ?? "".lowercased() < $1.name ?? "".lowercased() }.compactMap {
                Company(title: $0.name!, img: ImageMarker.companyImg(company: $0.icon_name!) ?? UIImage(named: "icon_building_sm")!, selected: $0.is_visible, isRecommaned: $0.recommend ?? false)
            }
            return .just(.loadCompanies(wholeList))
        case .setAllCompanies(let isSelect):
            return .just(.setAllCompanies(isSelect))
        case .changedFilter(let isChanged):
            return .just(.changedFilter(isChanged))
        case .changedAccessFilter(let selectedAccessFilter):
            return .just(.changedAccessFilter(selectedAccessFilter))
        case .setAccessFilter(let accessFilter):
            accessFilter.accessType == .publicCharger ? FilterManager.sharedInstance.savePublic(with: accessFilter.isSelected) : FilterManager.sharedInstance.saveNonPublic(with: accessFilter.isSelected)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadCompanies(let companies):
            newState.loadedCompanies = companies
        case .setAllCompanies(let isSelect):
            newState.isSelectedAllCompanies = isSelect
        case .changedFilter(let isChanged):
            newState.isChangedFilter = isChanged
        case .changedAccessFilter(let selectedAccessFilter):
            switch selectedAccessFilter.accessType {
            case .publicCharger:
                newState.isPublic = selectedAccessFilter.isSelected
            case .nonePublicCharger:
                newState.isNonPublic = selectedAccessFilter.isSelected
            }
        }
        
        return newState
    }
}

// Filter에서 update 후 main에서 표현해야할때
//enum FilterEvent {
//
//}
