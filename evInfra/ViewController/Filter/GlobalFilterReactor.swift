//
//  FilterReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class GlobalFilterReactor: ViewModel, Reactor {
    typealias SelectedFilterType = (filterTagType: FilterTagType, isSelected: Bool)
    typealias SelectedSpeedFilter = (minSpeed: Int, maxSpeed: Int)
    typealias SelectedPlaceFilter = (placeType: PlaceType, isSelected: Bool)
    typealias SelectedRoadFilter = (roadType: RoadType, isSelected: Bool)
    typealias SelectedChargerTypeFilter = (chargerTypeKey: Int, isSelected: Bool)
    typealias SelectedAccessFilter = (accessType: AccessType, isSelected: Bool)
    typealias SelectedCompanyFilter = (groups: [NewCompanyGroup], groupIndex: Int, companyIndex: Int, isSelected: Bool)
    
    enum Action {
        case loadCompanies
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case setEvPayFilter(Bool)
        case setFavoriteFilter(Bool)
        case setSelectedFilterType(SelectedFilterType)
        case changedAccessFilter(SelectedAccessFilter)
        case setAccessFilter(SelectedAccessFilter)
        case changedRoadFilter(SelectedRoadFilter)
        case setRoadFilter(SelectedRoadFilter)
        case changedPlaceFilter(SelectedPlaceFilter)
        case setPlaceFilter(SelectedPlaceFilter)
        case changedSpeedFilter(SelectedSpeedFilter)
        case setSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
        case setChargerTypeFilter([NewTag])
    }
    
    enum Mutation {
        case loadCompanies([Company])
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case updateBarTitle(Bool)
        case setEvPayFilter(Bool)
        case setFavoriteFilter(Bool, Int)
        case setSelectedFilterType(SelectedFilterType)
        case changedAccessFilter(SelectedAccessFilter)
        case changedRoadFilter(SelectedRoadFilter)
        case changedPlaceFilter(SelectedPlaceFilter)
        case changedSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes([NewTag])
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
    }

    struct State {
        var loadedCompanies: [Company]? = []
        var isSelectedAllCompanies: Bool? = true
        var isChangedFilter: Bool? = false
        var selectedFilterType: SelectedFilterType?
        var selectedAccessFilter: SelectedAccessFilter?
        var changedChargerTypeFilter: SelectedChargerTypeFilter?
        var selectedChargerTypes: [ChargerType]?
        var chargerTypes: [NewTag]? = []
        var isUpdateFilterBarTitle: Bool?
        var isPublic: Bool = FilterManager.sharedInstance.filter.isPublic
        var isNonPublic: Bool = FilterManager.sharedInstance.filter.isNonPublic
        var isGeneralRoad: Bool = FilterManager.sharedInstance.filter.isGeneralWay
        var isHighwayDown: Bool = FilterManager.sharedInstance.filter.isHighwayDown
        var isHighwayUp: Bool = FilterManager.sharedInstance.filter.isHighwayUp
        var isIndoor: Bool = FilterManager.sharedInstance.filter.isIndoor
        var isOutdoor: Bool = FilterManager.sharedInstance.filter.isOutdoor
        var isCanopy: Bool = FilterManager.sharedInstance.filter.isCanopy
        var minSpeed: Int = FilterManager.sharedInstance.filter.minSpeed
        var maxSpeed: Int = FilterManager.sharedInstance.filter.maxSpeed
        var isEvPayFilter: Bool? = FilterManager.sharedInstance.getIsMembershipCardChecked()
        var favoriteFilter: (Bool, Int) = (FilterManager.sharedInstance.getIsFavoriteChecked(), 0)
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
            
        case .setEvPayFilter(let isEvPayFilter):
            return .just(.setEvPayFilter(isEvPayFilter))
            
        case .setFavoriteFilter(let isFavoriteFilter):
            let favoriteChargers = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }
            return .just(.setFavoriteFilter(isFavoriteFilter, favoriteChargers.count))
            
        case .setSelectedFilterType(let selectedFiltertype):
            return .just(.setSelectedFilterType(selectedFiltertype))
            
        case .changedAccessFilter(let selectedAccessFilter):
            return .just(.changedAccessFilter(selectedAccessFilter))
            
        case .setAccessFilter(let accessFilter):
            accessFilter.accessType == .publicCharger ? FilterManager.sharedInstance.savePublic(with: accessFilter.isSelected) : FilterManager.sharedInstance.saveNonPublic(with: accessFilter.isSelected)
            return .just(.updateBarTitle(true))
            
        case .changedRoadFilter(let selectedRoadFilter):
            return .just(.changedRoadFilter(selectedRoadFilter))
            
        case .setRoadFilter(let roadFilter):
            switch roadFilter.roadType {
            case .general:
                FilterManager.sharedInstance.saveGeneralRoad(with: roadFilter.isSelected)
            case .highwayUp:
                FilterManager.sharedInstance.saveHighwayUp(with: roadFilter.isSelected)
            case .highwayDown:
                FilterManager.sharedInstance.saveHighwayDown(with: roadFilter.isSelected)
            }
            return .just(.updateBarTitle(true))
            
        case .changedPlaceFilter(let selectedPlaceFilter):
            return .just(.changedPlaceFilter(selectedPlaceFilter))
            
        case .setPlaceFilter(let placeFilter):
            switch placeFilter.placeType {
            case .indoor:
                FilterManager.sharedInstance.saveIndoor(with: placeFilter.isSelected)
            case .outdoor:
                FilterManager.sharedInstance.saveOutdoor(with: placeFilter.isSelected)
            case .canopy:
                FilterManager.sharedInstance.saveCanopy(with: placeFilter.isSelected)
            }
            return .just(.updateBarTitle(true))
            
        case .changedSpeedFilter(let selectedSpeedFilter):
            return .just(.changedSpeedFilter(selectedSpeedFilter))
            
        case .setSpeedFilter(let speedFilter):
            FilterManager.sharedInstance.saveSpeedFilter(min: speedFilter.minSpeed, max: speedFilter.maxSpeed)
            return .just(.updateBarTitle(true))
            
        case .loadChargerTypes:
            var tags: [NewTag] = [NewTag]()
            for type in ChargerType.allCases {
                tags.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
            }
            return .just(.loadChargerTypes(tags))
            
        case .changedChargerTypeFilter(let selectedChargerType):
            return .just(.changedChargerTypeFilter(selectedChargerType))
            
        case .setChargerTypeFilter(let tags):
            for tag in tags {
                FilterManager.sharedInstance.saveChargerType(index: tag.uniqueKey, selected: tag.selected)
            }
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.loadedCompanies = nil
        newState.chargerTypes = nil
        
        switch mutation {
        case .loadCompanies(let companies):
            newState.loadedCompanies = companies
        case .setAllCompanies(let isSelect):
            newState.isSelectedAllCompanies = isSelect
        case .changedFilter(let isChanged):
            newState.isChangedFilter = isChanged
        case .updateBarTitle(let isUpdate):
            newState.isUpdateFilterBarTitle = isUpdate
            
        case .setEvPayFilter(let isEvPayFilter):
            newState.isEvPayFilter = isEvPayFilter
            
        case .setFavoriteFilter(let isFavoriteFilter, let numberOfFavorites):
            newState.favoriteFilter = (isFavoriteFilter, numberOfFavorites)
//            newState.isFavoriteFilter = isFavoriteFilter
            
        case .setSelectedFilterType(let selectedFilterType):
            newState.selectedFilterType = selectedFilterType
            newState.isUpdateFilterBarTitle = true
            
        case .changedAccessFilter(let selectedAccessFilter):
            switch selectedAccessFilter.accessType {
            case .publicCharger:
                newState.isPublic = selectedAccessFilter.isSelected
            case .nonePublicCharger:
                newState.isNonPublic = selectedAccessFilter.isSelected
            }
        case .changedRoadFilter(let selectedRoadFilter):
            switch selectedRoadFilter.roadType {
            case .general:
                newState.isGeneralRoad = selectedRoadFilter.isSelected
            case .highwayDown:
                newState.isHighwayDown = selectedRoadFilter.isSelected
            case .highwayUp:
                newState.isHighwayUp = selectedRoadFilter.isSelected
            }
        case .changedPlaceFilter(let selectedPlaceFilter):
            switch selectedPlaceFilter.placeType {
            case .indoor:
                newState.isIndoor = selectedPlaceFilter.isSelected
            case .outdoor:
                newState.isOutdoor = selectedPlaceFilter.isSelected
            case .canopy:
                newState.isCanopy = selectedPlaceFilter.isSelected
            }
        case .changedSpeedFilter(let selectedSpeedFilter):
            newState.minSpeed = selectedSpeedFilter.minSpeed
            newState.maxSpeed = selectedSpeedFilter.maxSpeed
            
        case .loadChargerTypes(let tags):
            newState.chargerTypes = tags
            
        case .changedChargerTypeFilter(let selectedChargerTypeFilter):
            newState.changedChargerTypeFilter = selectedChargerTypeFilter
        }
        
        return newState
    }
}

// Filter에서 update 후 main에서 표현해야할때
//enum FilterEvent {
//
//}
