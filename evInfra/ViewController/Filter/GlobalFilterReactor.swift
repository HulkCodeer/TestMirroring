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
        case updateSpeedFilter(SelectedSpeedFilter)
        case loadChargerTypes([NewTag])
        case updateSlowTypeOn(Bool)
        case updateMinMaxSpeedOn(Bool, Bool)
        case changedChargerTypeFilter(SelectedChargerTypeFilter)
        case updateChargerTypeFilter([NewTag])
        case changedCompanyFilter(SelectedCompanyFilter)
    }

    struct State {
        var loadedCompanies: [Company]? = []
        var isSelectedAllCompanies: Bool? = true
        var isChangedFilter: Bool? = false
        var selectedFilterType: SelectedFilterType?
        var selectedAccessFilter: SelectedAccessFilter?
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
        var isSlowTypeOn: Bool = false
        var minMaxSpeedOn: (Bool, Bool) = (false, false)
        var filterModel: FilterModel = FilterModel()
        var resetFilterModel: FilterModel = FilterModel(isPublic: true, isNonPublic: true,
                                                        isGeneralRoad: true, isHighwayDown: true,
                                                        isHighwayUp: true, isIndoor: true,
                                                        isOutdoor: true, isCanopy: true,
                                                        minSpeed: 50, maxSpeed: 350,
                                                        isEvPayFilter: false, isFavoriteFilter: false,
                                                        isRepresentCarFilter: false,
                                                        chargerTypes: ChargerType.allCases.compactMap {
            if $0.uniqueKey == Const.CHARGER_TYPE_DCCOMBO || $0.uniqueKey == Const.CHARGER_TYPE_DCDEMO || $0.uniqueKey == Const.CHARGER_TYPE_AC || $0.uniqueKey == Const.CHARGER_TYPE_SUPER_CHARGER {
                return NewTag(title: $0.typeTitle, selected: true, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            } else {
                return NewTag(title: $0.typeTitle, selected: false, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            }
        })
        var shouldChanged: Bool = false
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
        var chargerTypes: [NewTag] = ChargerType.allCases.compactMap {
            if $0.uniqueKey == Const.CHARGER_TYPE_DCCOMBO || $0.uniqueKey == Const.CHARGER_TYPE_DCDEMO || $0.uniqueKey == Const.CHARGER_TYPE_AC || $0.uniqueKey == Const.CHARGER_TYPE_SUPER_CHARGER {
                return NewTag(title: $0.typeTitle, selected: true, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            } else {
                return NewTag(title: $0.typeTitle, selected: false, uniqueKey: $0.uniqueKey, image: $0.typeImageProperty?.image)
            }
        }
        
        init() {
            
        }
        
        init(isPublic: Bool, isNonPublic: Bool, isGeneralRoad: Bool, isHighwayDown: Bool, isHighwayUp: Bool, isIndoor: Bool, isOutdoor: Bool, isCanopy: Bool, minSpeed: Int, maxSpeed: Int, isEvPayFilter: Bool? = nil, isFavoriteFilter: Bool? = nil, numberOfFavorites: Int? = nil, isRepresentCarFilter: Bool, chargerTypes: [NewTag]) {
            self.isPublic = isPublic
            self.isNonPublic = isNonPublic
            self.isGeneralRoad = isGeneralRoad
            self.isHighwayDown = isHighwayDown
            self.isHighwayUp = isHighwayUp
            self.isIndoor = isIndoor
            self.isOutdoor = isOutdoor
            self.isCanopy = isCanopy
            self.minSpeed = minSpeed
            self.maxSpeed = maxSpeed
            self.isEvPayFilter = isEvPayFilter
            self.isFavoriteFilter = isFavoriteFilter
            self.numberOfFavorites = numberOfFavorites
            self.isRepresentCarFilter = isRepresentCarFilter
            self.chargerTypes = chargerTypes
        }
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
            let isEvPaFilter = self.currentState.filterModel.isEvPayFilter ?? false

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
            FilterManager.sharedInstance.saveSpeedFilter(min: filterModel.minSpeed, max: filterModel.maxSpeed)
            
            let chargerTypes = filterModel.chargerTypes
            for tag in chargerTypes {
                FilterManager.sharedInstance.saveChargerType(index: tag.uniqueKey, selected: tag.selected)
            }
            
            return Observable.concat([
                .just(.saveFilter(filterModel)),
                .just(.shouldChanged)
            ])

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
            let isRepresentCarFilter = self.currentState.isRepresentCarFilter
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
        
        switch mutation {
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
            
        case .updateSpeedFilter(let selectedSpeedFilter):
            newState.filterModel.minSpeed = selectedSpeedFilter.minSpeed
            newState.filterModel.maxSpeed = selectedSpeedFilter.maxSpeed
            newState.isUpdateFilterBarTitle = true
            
        case .loadChargerTypes(let tags):
            newState.filterModel.chargerTypes = tags
            
        case .updateSlowTypeOn(let isOn):
            newState.isSlowTypeOn = isOn
            
        case .updateMinMaxSpeedOn(let isFastSpeedOn, let isSlowSpeedOn):
            newState.minMaxSpeedOn = (isFastSpeedOn, isSlowSpeedOn)
            
        case .changedChargerTypeFilter(let selectedChargerTypeFilter):
            newState.changedChargerTypeFilter = selectedChargerTypeFilter
            
        case .updateChargerTypeFilter(let tags):
            newState.filterModel.chargerTypes = tags
            
        case .changedCompanyFilter(let selectedCompanyFilter):
            newState.changedCompanyFilter = selectedCompanyFilter
        }
        
        return newState
    }
}
