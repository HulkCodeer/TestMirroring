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
        case updateEvPayFilter(Bool)
        case saveEvPayFilter(Bool)
        case updateFavoriteFilter(Bool)
        case saveFavoriteFilter(Bool)
        case numberOfFavorits
        case updateRepresentCarFilter(Bool)
        case saveRepresentCarFilter(Bool)
        case setSelectedFilterType(SelectedFilterType)
        case saveAccessFilter(FilterModel)
        case updatePublicFilter(Bool)
        case updateNonPublicFilter(Bool)
        case updateGeneralFilter(Bool)
        case updateHighwayUpFilter(Bool)
        case updateHigywayDownFilter(Bool)
        case savePlaceFilter(FilterModel)
        case updateIndoorPlaceFilter(Bool)
        case updateOutdoorPlaceFilter(Bool)
        case updateCanopyPlaceFilter(Bool)
        case saveFilter(FilterModel)
        case shouldChanged
        case changedSpeedFilter(SelectedSpeedFilter)
        case setSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
        case setChargerTypeFilter([NewTag])
        case changedCompanyFilter(SelectedCompanyFilter)
        case setCompanyFilter([NewCompanyGroup])
//        case testLoadRoadType
        case setAcessTypeFilter(any Filter)
    }
    
    enum Mutation {
        case loadCompanies([Company])
        case setAllCompanies(Bool)
        case changedFilter(Bool)
        case updateBarTitle(Bool)
        case updateEvPayFilter(Bool)
        case updateFavoriteFilter(Bool, Int)
        case numberOfFavorits(Int)
        case updateRepresentCarFilter(Bool)
        case setSelectedFilterType(SelectedFilterType)
        case saveAccessFilter(FilterModel)
        case updatePublicFilter(Bool)
        case updateNonPublicFilter(Bool)
        case updateGeneralRoadFilter(Bool)
        case updateHighwayUpRoadFilter(Bool)
        case updateHigywayDownRoadFilter(Bool)
        case savePlaceFilter(FilterModel)
        case updateIndoorPlaceFilter(Bool)
        case updateOutdoorFilter(Bool)
        case updateCanopyFilter(Bool)
        case saveFilter(FilterModel)
        case shouldChanged
        case changedSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes([NewTag])
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
        case changedCompanyFilter(SelectedCompanyFilter)
        case setTestRoadType(any Filter)
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
        var isEvPayFilter: Bool = FilterManager.sharedInstance.isMembershipCardChecked()
        var isFavoriteFilter: Bool = FilterManager.sharedInstance.filter.isFavoriteChecked
        var numberOfFavorites: Int? = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }.count
        var isRepresentCarFilter: Bool = FilterManager.sharedInstance.filter.isRepresentCarChecked
        var filterModel: FilterModel = FilterModel()
        var resetFilterModel: FilterModel = FilterModel(isPublic: true, isNonPublic: true, isGeneralRoad: true, isHighwayDown: true, isHighwayUp: true, isIndoor: true, isOutdoor: true, isCanopy: true, minSpeed: 50, maxSpeed: 350, isEvPayFilter: false, isFavoriteFilter: false, isRepresentCarFilter: false)
        var shouldChanged: Bool = false
        
        var testModel: FilterConfigModel = FilterConfigModel()
        var accessType: (any Filter)?
    }
    
    struct FilterModel: Equatable {
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
        var isEvPayFilter: Bool? = FilterManager.sharedInstance.isMembershipCardChecked()
        var isFavoriteFilter: Bool? = FilterManager.sharedInstance.filter.isFavoriteChecked
        var numberOfFavorites: Int? = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }.count
        var isRepresentCarFilter: Bool = FilterManager.sharedInstance.filter.isRepresentCarChecked
    }
    
    internal var initialState: State    
    
    override init(provider: SoftberryAPI) {
        self.initialState = State()
        super.init(provider: provider)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setAcessTypeFilter(let filter):
            self.currentState.testModel.accessibilityFilters = self.currentState.testModel.accessibilityFilters.map { test in
                if test.isEqual(filter) {
                    return filter
                }
                return test
            }
            
            printLog(out: "PARK TEST state : \(self.currentState.testModel.accessibilityFilters[0].isSelected)")
            
            printLog(out: "PARK TEST state : \(self.currentState.testModel.accessibilityFilters[1].isSelected)")
                                    
            return .just(.setTestRoadType(filter))
            
//        case .testLoadRoadType:
//            return .just(.setTestRoadType)
            
        case .loadCompanies:
            let companyValues: [CompanyInfoDto] = FilterManager.sharedInstance.filter.companyDictionary.map { $0.1 }
            let isEvPaFilter = self.currentState.isEvPayFilter ?? false

            let wholeList = companyValues.sorted { $0.name ?? "".lowercased() < $1.name ?? "".lowercased() }
                .compactMap { Company(title: $0.name!, companyId: $0.company_id ?? "", img: ImageMarker.companyImg(company: $0.icon_name!) ?? UIImage(named: "icon_building_sm")!, selected: isEvPaFilter ? $0.card_setting ?? false : $0.is_visible, isRecommaned: $0.recommend ?? false, isEvPayAvailable: false) }
            return .just(.loadCompanies(wholeList))
            
        case .setAllCompanies(let isSelect):
            return .just(.setAllCompanies(isSelect))
            
        case .changedFilter(let isChanged):
            return .just(.changedFilter(isChanged))
            
        case .updateEvPayFilter(let isEvPayFilter):
            return .just(.updateEvPayFilter(isEvPayFilter))
            
        case .saveEvPayFilter(let isEvPayFilter):
            FilterManager.sharedInstance.saveIsMembershipCardChecked(isEvPayFilter)
            return .just(.updateEvPayFilter(isEvPayFilter))
            
        case .updateFavoriteFilter(let isFavoriteFilter):
            let favoriteChargers = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }
            return .just(.updateFavoriteFilter(isFavoriteFilter, favoriteChargers.count))
            
        case .numberOfFavorits:
            let numberOfFavorites = ChargerManager.sharedInstance.getChargerStationInfoList().filter { $0.mFavorite }.count
            return .just(.numberOfFavorits(numberOfFavorites))
            
        case .updateRepresentCarFilter(let isRepresentCarFilter):
            return .just(.updateRepresentCarFilter(isRepresentCarFilter))
            
        case .saveRepresentCarFilter(let isRepresentCarFilter):
            FilterManager.sharedInstance.saveIsRepresentCarChecked(isRepresentCarFilter)
            return .empty()
            
        case .saveFavoriteFilter(let isFavoriteFilter):
            FilterManager.sharedInstance.saveIsFavoriteChecked(isFavoriteFilter)
            return .empty()
            
        case .setSelectedFilterType(let selectedFiltertype):
            return .just(.setSelectedFilterType(selectedFiltertype))
            
        case .updatePublicFilter(let isSelected):
            return .just(.updatePublicFilter(isSelected))
            
        case .updateNonPublicFilter(let isSelected):
            return .just(.updateNonPublicFilter(isSelected))
            
        case .saveAccessFilter(let filterModel):
            FilterManager.sharedInstance.savePublic(with: filterModel.isPublic)
            FilterManager.sharedInstance.saveNonPublic(with: filterModel.isNonPublic)
            return .just(.saveAccessFilter(filterModel))
            
        case .updateGeneralFilter(let isSelcted):
            return .just(.updateGeneralRoadFilter(isSelcted))
            
        case .updateHighwayUpFilter(let isSelected):
            return .just(.updateHighwayUpRoadFilter(isSelected))
            
        case .updateHigywayDownFilter(let isSelected):
            return .just(.updateHigywayDownRoadFilter(isSelected))
            
        case .savePlaceFilter(let filterModel):
            FilterManager.sharedInstance.saveIndoor(with: filterModel.isIndoor)
            FilterManager.sharedInstance.saveOutdoor(with: filterModel.isOutdoor)
            FilterManager.sharedInstance.saveCanopy(with: filterModel.isCanopy)
            return .just(.savePlaceFilter(filterModel))
            
        case .updateIndoorPlaceFilter(let isSelected):
            return .just(.updateIndoorPlaceFilter(isSelected))

        case .updateOutdoorPlaceFilter(let isSelected):
            return .just(.updateOutdoorFilter(isSelected))
            
        case .updateCanopyPlaceFilter(let isSelected):
            return .just(.updateCanopyFilter(isSelected))
            
        case .saveFilter(let filterModel):
            FilterManager.sharedInstance.saveIsMembershipCardChecked(filterModel.isEvPayFilter ?? false)
            FilterManager.sharedInstance.saveIsFavoriteChecked(filterModel.isFavoriteFilter ?? false)
            FilterManager.sharedInstance.saveIsRepresentCarChecked(filterModel.isRepresentCarFilter)
            FilterManager.sharedInstance.savePublic(with: filterModel.isPublic)
            FilterManager.sharedInstance.saveNonPublic(with: filterModel.isNonPublic)
            FilterManager.sharedInstance.saveGeneralRoad(with: filterModel.isGeneralRoad)
            FilterManager.sharedInstance.saveHighwayUp(with: filterModel.isHighwayUp)
            FilterManager.sharedInstance.saveHighwayDown(with: filterModel.isHighwayDown)
            FilterManager.sharedInstance.saveIndoor(with: filterModel.isIndoor)
            FilterManager.sharedInstance.saveOutdoor(with: filterModel.isOutdoor)
            FilterManager.sharedInstance.saveCanopy(with: filterModel.isCanopy)
            
            return Observable.concat([
                .just(.saveFilter(filterModel)),
                .just(.shouldChanged)
            ])

        case .changedSpeedFilter(let selectedSpeedFilter):
            return .just(.changedSpeedFilter(selectedSpeedFilter))
            
        case .setSpeedFilter(let speedFilter):
            FilterManager.sharedInstance.saveSpeedFilter(min: speedFilter.minSpeed, max: speedFilter.maxSpeed)
            return .just(.updateBarTitle(true))
            
        case .shouldChanged:
            return .just(.shouldChanged)
            
        case .loadChargerTypes:
            var tags: [NewTag] = [NewTag]()
            let myCarType: Int = UserDefault().readInt(key: UserDefault.Key.MB_CAR_TYPE)
            let hasMyCar: Bool = UserDefault().readInt(key: UserDefault.Key.MB_CAR_ID) != 0
            let isRepresentCarFilter = self.currentState.isRepresentCarFilter ?? false
            printLog(out: "//// GlobalFilterReactor ////")
            printLog(out: "myCarType : \(myCarType)")
            printLog(out: "hasMyCar : \(hasMyCar)")
            
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
                for type in ChargerType.allCases {
                    tags.append(NewTag(title: type.typeTitle, selected: type.selected, uniqueKey: type.uniqueKey, image: type.typeImageProperty?.image))
                    
                }
            }
            return .just(.loadChargerTypes(tags))
            
        case .changedChargerTypeFilter(let selectedChargerType):
            return .just(.changedChargerTypeFilter(selectedChargerType))
            
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
        newState.accessType = nil
        
        switch mutation {
        case .setTestRoadType(let filter):
            newState.accessType = filter
            
        case .loadCompanies(let companies):
            newState.loadedCompanies = companies
        case .setAllCompanies(let isSelect):
            newState.isSelectedAllCompanies = isSelect
        case .changedFilter(let isChanged):
            newState.isChangedFilter = isChanged
        case .updateBarTitle(let isUpdate):
            newState.isUpdateFilterBarTitle = isUpdate
            
        case .updateEvPayFilter(let isEvPayFilter):
            newState.filterModel.isEvPayFilter = isEvPayFilter
            
        case .updateFavoriteFilter(let isFavoriteFilter, let numberOfFavorites):
            newState.filterModel.isFavoriteFilter = isFavoriteFilter
            newState.numberOfFavorites = numberOfFavorites
            
        case .numberOfFavorits(let numberOfFavorites):
            newState.numberOfFavorites = numberOfFavorites
            
        case .updateRepresentCarFilter(let isRepresentCarFilter):
            newState.filterModel.isRepresentCarFilter = isRepresentCarFilter
            
        case .setSelectedFilterType(let selectedFilterType):
            newState.selectedFilterType = selectedFilterType
            newState.isUpdateFilterBarTitle = true
   
        case .updatePublicFilter(let isSelected):
            newState.filterModel.isPublic = isSelected
            
        case .updateNonPublicFilter(let isSelected):
            newState.filterModel.isNonPublic = isSelected
            
        case .saveAccessFilter(let filterModel):
            newState.filterModel = filterModel
            newState.isUpdateFilterBarTitle = true
            
        case .updateGeneralRoadFilter(let isSelcted):
            newState.filterModel.isGeneralRoad = isSelcted
            
        case .updateHighwayUpRoadFilter(let isSelected):
            newState.filterModel.isHighwayUp = isSelected
            
        case .updateHigywayDownRoadFilter(let isSelected):
            newState.filterModel.isHighwayDown = isSelected
    
        case .updateIndoorPlaceFilter(let isSelected):
            newState.filterModel.isIndoor = isSelected
            
        case .updateOutdoorFilter(let isSelcted):
            newState.filterModel.isOutdoor = isSelcted
            
        case .updateCanopyFilter(let isSelected):
            newState.filterModel.isCanopy = isSelected
            
        case .savePlaceFilter(let filterModel):
            newState.filterModel = filterModel
            newState.isUpdateFilterBarTitle = true
            
        case .saveFilter(let filterModel):
            initialState.filterModel = filterModel
            newState.filterModel = filterModel
            newState.shouldChanged = false
            newState.isUpdateFilterBarTitle = true
            
        case .shouldChanged:
            let shouldChanged = self.initialState.filterModel != self.currentState.filterModel
            newState.shouldChanged = shouldChanged
            
        case .changedSpeedFilter(let selectedSpeedFilter):
            newState.minSpeed = selectedSpeedFilter.minSpeed
            newState.maxSpeed = selectedSpeedFilter.maxSpeed
            
        case .loadChargerTypes(let tags):
            newState.chargerTypes = tags
            
        case .changedChargerTypeFilter(let selectedChargerTypeFilter):
            newState.changedChargerTypeFilter = selectedChargerTypeFilter
            
        case .changedCompanyFilter(let selectedCompanyFilter):
            newState.changedCompanyFilter = selectedCompanyFilter
        }
        
        return newState
    }
}
