//
//  FilterReactor.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/10/30.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import ReactorKit

internal final class FilterReactor: ViewModel, Reactor {
    typealias SelectedFilterType = (filterTagType: FilterTagType, isSelected: Bool)
    typealias SelectedSpeedFilter = (minSpeed: Int, maxSpeed: Int)
    typealias SelectedPlaceFilter = (placeType: PlaceType, isSelected: Bool)
    typealias SelectedRoadFilter = (roadType: RoadType, isSelected: Bool)
    typealias SelectedChargerTypeFilter = (chargerTypeKey: Int, isSelected: Bool)
    typealias SelectedCompanyFilter = (group: NewCompanyGroup, groupIndex: Int, companyIndex: Int, isSelected: Bool)
    
    enum Action {
        case loadCompanies
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case saveEvPayFilter(Bool)
//        case updateFavoriteFilter(Bool)
        case saveFavoriteFilter(Bool)
//        case numberOfFavorits
        case saveRepresentCarFilter(Bool)
        case setSelectedFilterType(SelectedFilterType)
        case shouldChanged
        case updateSpeedFilter(SelectedSpeedFilter)
        case setSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes
        case updateSlowTypeOn(Bool)
        case updateMinMaxSpeedOn(Bool, Bool)
        case updateChargerTypeFilter([NewTag])
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
        case setChargerTypeFilter([NewTag])
        case changedCompanyFilter(SelectedCompanyFilter)
        case setCompanyFilter([NewCompanyGroup])
//        case testLoadRoadType
        case setAcessTypeFilter(any Filter)
        case setRoadTypeFilter(any Filter)
        case resetFilter
    }
    
    enum Mutation {
        case loadCompanies([Company])
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case updateBarTitle(Bool)
//        case updateFavoriteFilter(Bool, Int)
//        case numberOfFavorits(Int)
//        case updateRepresentCarFilter(Bool)
        case setSelectedFilterType(SelectedFilterType)
        case shouldChanged
        case updateSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes([NewTag])
        case updateSlowTypeOn(Bool)
        case updateMinMaxSpeedOn(Bool, Bool)
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
        case updateChargerTypeFilter([NewTag])
        case changedCompanyFilter(SelectedCompanyFilter)
        case setAccessType(any Filter)
        case setRoadType(any Filter)
        case resetFilter
    }

    struct State {
        var loadedCompanies: [Company]? = []
        var isSelectedAllCompanies: Bool? = true
        var isChangedFilter: Bool? = false
        var selectedFilterType: SelectedFilterType?        
        var changedChargerTypeFilter: SelectedChargerTypeFilter?
        var selectedChargerTypes: [ChargerType]?
        var changedCompanyFilter: SelectedCompanyFilter?
        var chargerTypes: [NewTag]? = []
        var isUpdateFilterBarTitle: Bool?
        var isSlowTypeOn: Bool = false
        var minMaxSpeedOn: (Bool, Bool) = (false, false)
        var shouldChanged: Bool = false
        
        var tempFilterModel: FilterConfigModel = FilterConfigModel(isConvert: true)
        var filterType: (any Filter)?
    }
            
    internal var initialState: State
    
    internal var originalFilterModel: FilterConfigModel = FilterConfigModel(isConvert: true)
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .resetFilter:
            return .just(.resetFilter)
            
        case .setRoadTypeFilter(let filter):
            self.currentState.tempFilterModel.roadFilters = self.currentState.tempFilterModel.roadFilters.map { test in
                if test.isEqual(filter) {
                    return filter
                }
                return test
            }
                                                            
            return .just(.setRoadType(filter))
            
        case .setAcessTypeFilter(let filter):
            self.currentState.tempFilterModel.accessibilityFilters = self.currentState.tempFilterModel.accessibilityFilters.map { test in
                if test.isEqual(filter) {
                    return filter
                }
                return test
            }
                                                            
            return .just(.setAccessType(filter))
            
//        case .testLoadRoadType:
//            return .just(.setTestRoadType)
            
        case .loadCompanies:
            let companyValues: [CompanyInfoDto] = FilterManager.sharedInstance.filter.companyDictionary.map { $0.1 }
            let isEvPaFilter = self.currentState.tempFilterModel.isEvPayFilter ?? false

            let wholeList = companyValues.sorted { $0.name ?? "".lowercased() < $1.name ?? "".lowercased() }
                .compactMap { Company(title: $0.name!, companyId: $0.company_id ?? "", img: ImageMarker.companyImg(company: $0.icon_name!) ?? UIImage(named: "icon_building_sm")!, selected: isEvPaFilter ? $0.card_setting ?? false : $0.is_visible, isRecommaned: $0.recommend ?? false, isEvPayAvailable: false) }
            return .just(.loadCompanies(wholeList))
            
        case .setAllCompanies(let isSelect):
            return .just(.setAllCompanies(isSelect))
            
        case .changedFilter(let isChanged):
            return .just(.changedFilter(isChanged))
                                
        case .saveEvPayFilter(let isEvPayFilter):
            self.currentState.tempFilterModel.isEvPayFilter = isEvPayFilter
            return .empty()
            
//        case .updateFavoriteFilter(let isFavoriteFilter):
//            let favoriteChargers = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }
//            return .just(.updateFavoriteFilter(isFavoriteFilter, favoriteChargers.count))
            
//        case .numberOfFavorits:
//            let numberOfFavorites = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }.count
//            return .just(.numberOfFavorits(numberOfFavorites))
                    
        case .saveRepresentCarFilter(let isRepresentCarFilter):
            FilterManager.sharedInstance.saveIsRepresentCarChecked(isRepresentCarFilter)
            return .empty()
            
        case .saveFavoriteFilter(let isFavoriteFilter):
            FilterManager.sharedInstance.saveIsFavoriteChecked(isFavoriteFilter)
            return .empty()
            
        case .setSelectedFilterType(let selectedFiltertype):
            return .just(.setSelectedFilterType(selectedFiltertype))
                                                                                                                
        case .updateSpeedFilter(let selectedSpeedFilter):
            return .just(.updateSpeedFilter(selectedSpeedFilter))
            
        case .setSpeedFilter(let speedFilter):
            FilterManager.sharedInstance.saveSpeedFilter(min: speedFilter.minSpeed, max: speedFilter.maxSpeed)
            return .just(.updateBarTitle(true))
            
        case .shouldChanged:
            return .just(.shouldChanged)
            
        case .loadChargerTypes:
            var tags: [NewTag] = [NewTag]()
            let myCarType: Int = UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE)
            let hasMyCar: Bool = UserDefault().readInt(key: UserDefault.Key.MB_CAR_ID) != 0
            let isRepresentCarFilter = self.currentState.tempFilterModel.isRepresentCarFilter
            let isSlowTypeOn: Bool = self.currentState.isSlowTypeOn
            
            if isRepresentCarFilter {
                if hasMyCar {
                    for type in ChargerType.allCases {
                        tags.append(NewTag(title: type.typeTitle, selected: myCarType == type.uniqueKey, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                    }
                } else {
                    for type in ChargerType.allCases {
                        tags.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                    }
                }
            } else {
                if isSlowTypeOn {
                    for type in ChargerType.allCases {
                        if type == .slow || type == .destination {
                            tags.append(NewTag(title: type.typeTitle, selected: true, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                        } else {
                            tags.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                        }
                    }
                } else {
                    for type in ChargerType.allCases {
                        tags.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                    }
                }
            }
            return .just(.loadChargerTypes(tags))
            
        case .updateSlowTypeOn(let isOn):
            return .just(.updateSlowTypeOn(isOn))
            
        case .updateMinMaxSpeedOn(let isFastSpeedOn, let isSlowSpeedOn):
            return .just(.updateMinMaxSpeedOn(isFastSpeedOn, isSlowSpeedOn))
            
        case .changedChargerTypeFilter(let selectedChargerType):
            return .just(.changedChargerTypeFilter(selectedChargerType))
            
        case .updateChargerTypeFilter(let tags):
            return .just(.updateChargerTypeFilter(tags))
            
        case .setChargerTypeFilter(let tags):
            for tag in tags {
                FilterManager.sharedInstance.saveChargerType(index: tag.uniqueKey, selected: tag.selected)
            }
            return .empty()
            
        case .changedCompanyFilter(let selectedCompanyFilter):
            return .just(.changedCompanyFilter(selectedCompanyFilter))
            
        case .setCompanyFilter(let groups):
            let originalCompanyList = Array(FilterManager.sharedInstance.filter.companyDictionary.values)
            for company in originalCompanyList {
                for group in groups {
                    for tag in group.companies {
                        if company.name == tag.title {
                            ChargerManager.sharedInstance.updateCompanyVisibility(isVisible: tag.selected, companyID: tag.companyId)
                            continue
                        }
                    }
                }
            }
            
            FilterManager.sharedInstance.updateCompanyFilter()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        newState.loadedCompanies = nil
        newState.chargerTypes = nil
        newState.filterType = nil
        
        switch mutation {
        case .resetFilter:
            newState.
            
        case .setRoadType(let filter):
            newState.filterType = filter
            
        case .setAccessType(let filter):
            newState.filterType = filter
            
        case .loadCompanies(let companies):
            newState.loadedCompanies = companies
        case .setAllCompanies(let isSelect):
            newState.isSelectedAllCompanies = isSelect
        case .changedFilter(let isChanged):
            newState.isChangedFilter = isChanged
        case .updateBarTitle(let isUpdate):
            newState.isUpdateFilterBarTitle = isUpdate
                                
//        case .updateFavoriteFilter(let isFavoriteFilter, let numberOfFavorites):
//            newState.numberOfFavorites = numberOfFavorites
//
//        case .numberOfFavorits(let numberOfFavorites):
//            newState.numberOfFavorites = numberOfFavorites
                                
        case .setSelectedFilterType(let selectedFilterType):
            newState.selectedFilterType = selectedFilterType
            newState.isUpdateFilterBarTitle = true
                       
//        case .saveAccessFilter(let filterModel):
//            newState.isUpdateFilterBarTitle = true
//
//        case .savePlaceFilter(let filterModel):
//            newState.isUpdateFilterBarTitle = true
//
//        case .saveFilter(let filterModel):
//            newState.shouldChanged = false
//            newState.isUpdateFilterBarTitle = true
            
        case .shouldChanged:
//            let shouldChanged = self.initialState.filterModel != self.currentState.filterModel
            newState.shouldChanged = true
            
        case .updateSpeedFilter(let selectedSpeedFilter):
            newState.isUpdateFilterBarTitle = true
            
        case .loadChargerTypes(let tags): break
//            newState.filterModel.chargerTypes = tags
            
        case .updateSlowTypeOn(let isOn):
            newState.isSlowTypeOn = isOn
            
        case .updateMinMaxSpeedOn(let isFastSpeedOn, let isSlowSpeedOn):
            newState.minMaxSpeedOn = (isFastSpeedOn, isSlowSpeedOn)
            
        case .changedChargerTypeFilter(let selectedChargerTypeFilter):
            newState.changedChargerTypeFilter = selectedChargerTypeFilter
            
        case .updateChargerTypeFilter(let tags): break
//            newState.filterModel.chargerTypes = tags
            
        case .changedCompanyFilter(let selectedCompanyFilter):
            newState.changedCompanyFilter = selectedCompanyFilter

        }
        
        return newState
    }
}
