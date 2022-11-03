// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Icons {
  internal static let iconBattery = ImageAsset(name: "icon_battery")
  internal static let iconCalendarLg = ImageAsset(name: "icon_calendar_lg")
  internal static let iconCalendarMd = ImageAsset(name: "icon_calendar_md")
  internal static let iconCalendarSm = ImageAsset(name: "icon_calendar_sm")
  internal static let iconCalendarXs = ImageAsset(name: "icon_calendar_xs")
  internal static let iconBallonTriangle = ImageAsset(name: "icon_ballon_triangle")
  internal static let iconCarEmpty = ImageAsset(name: "icon_car_empty")
  internal static let iconMypageCarEmpty = ImageAsset(name: "icon_mypage_car_empty")
  internal static let iconCheckLg = ImageAsset(name: "icon_check_lg")
  internal static let iconCheckMd = ImageAsset(name: "icon_check_md")
  internal static let iconCheckOff = ImageAsset(name: "icon_check_off")
  internal static let iconCheckOn = ImageAsset(name: "icon_check_on")
  internal static let iconCheckSm = ImageAsset(name: "icon_check_sm")
  internal static let iconCheckXs = ImageAsset(name: "icon_check_xs")
  internal static let coinFillLg = ImageAsset(name: "coin_fill_lg")
  internal static let coinFillMd = ImageAsset(name: "coin_fill_md")
  internal static let coinFillSm = ImageAsset(name: "coin_fill_sm")
  internal static let coinFillXs = ImageAsset(name: "coin_fill_xs")
  internal static let iconCommentLg = ImageAsset(name: "icon_comment_lg")
  internal static let iconCommentMd = ImageAsset(name: "icon_comment_md")
  internal static let iconCommentSm = ImageAsset(name: "icon_comment_sm")
  internal static let iconCommentXs = ImageAsset(name: "icon_comment_xs")
  internal static let iconCompassLg = ImageAsset(name: "icon_compass_lg")
  internal static let iconCompassMd = ImageAsset(name: "icon_compass_md")
  internal static let iconCompassSm = ImageAsset(name: "icon_compass_sm")
  internal static let iconCompassXs = ImageAsset(name: "icon_compass_xs")
  internal static let iconCurrentLocationLg = ImageAsset(name: "icon_current_location_lg")
  internal static let iconCurrentLocationMd = ImageAsset(name: "icon_current_location_md")
  internal static let iconCurrentLocationSm = ImageAsset(name: "icon_current_location_sm")
  internal static let iconCurrentLocationXs = ImageAsset(name: "icon_current_location_xs")
  internal static let iconEditLg = ImageAsset(name: "icon_edit_lg")
  internal static let iconEditMd = ImageAsset(name: "icon_edit_md")
  internal static let iconEditSm = ImageAsset(name: "icon_edit_sm")
  internal static let iconEditXs = ImageAsset(name: "icon_edit_xs")
  internal static let iconElectricFillLg = ImageAsset(name: "icon_electric_fill_lg")
  internal static let iconElectricFillMd = ImageAsset(name: "icon_electric_fill_md")
  internal static let iconElectricFillSm = ImageAsset(name: "icon_electric_fill_sm")
  internal static let iconElectricFillXs = ImageAsset(name: "icon_electric_fill_xs")
  internal static let iconElectricLg = ImageAsset(name: "icon_electric_lg")
  internal static let iconElectricMd = ImageAsset(name: "icon_electric_md")
  internal static let iconElectricSm = ImageAsset(name: "icon_electric_sm")
  internal static let iconElectricXs = ImageAsset(name: "icon_electric_xs")
  internal static let iconEvLg = ImageAsset(name: "icon_ev_lg")
  internal static let iconEvMd = ImageAsset(name: "icon_ev_md")
  internal static let iconEvSm = ImageAsset(name: "icon_ev_sm")
  internal static let iconEvXs = ImageAsset(name: "icon_ev_xs")
  internal static let iconCategoryFilter = ImageAsset(name: "icon_category_filter")
  internal static let iconGiftLg = ImageAsset(name: "icon_gift_lg")
  internal static let iconGiftMd = ImageAsset(name: "icon_gift_md")
  internal static let iconGiftSm = ImageAsset(name: "icon_gift_sm")
  internal static let iconGiftXs = ImageAsset(name: "icon_gift_xs")
  internal static let iconInfoLg = ImageAsset(name: "icon_info_lg")
  internal static let iconInfoMd = ImageAsset(name: "icon_info_md")
  internal static let iconInfoSm = ImageAsset(name: "icon_info_sm")
  internal static let iconInfoXs = ImageAsset(name: "icon_info_xs")
  internal static let iconLockLg = ImageAsset(name: "icon_lock_lg")
  internal static let iconLockMd = ImageAsset(name: "icon_lock_md")
  internal static let iconLockSm = ImageAsset(name: "icon_lock_sm")
  internal static let iconLockXs = ImageAsset(name: "icon_lock_xs")
  internal static let iconMapCourseLg = ImageAsset(name: "icon_map-course_lg")
  internal static let iconMapCourseMd = ImageAsset(name: "icon_map-course_md")
  internal static let iconMapCourseSm = ImageAsset(name: "icon_map-course_sm")
  internal static let iconMapCourseXs = ImageAsset(name: "icon_map-course_xs")
  internal static let iconMapLg = ImageAsset(name: "icon_map_lg")
  internal static let iconMapMd = ImageAsset(name: "icon_map_md")
  internal static let iconMapSm = ImageAsset(name: "icon_map_sm")
  internal static let iconMapXs = ImageAsset(name: "icon_map_xs")
  internal static let iconMenuBadge = ImageAsset(name: "icon_menu_badge")
  internal static let iconMenuMd = ImageAsset(name: "icon_menu_md")
  internal static let iconSearchMd = ImageAsset(name: "icon_search_md")
  internal static let iconProfileEmpty = ImageAsset(name: "icon_profile_empty")
  internal static let iconQr = ImageAsset(name: "icon_qr")
  internal static let iconRadioSelected = ImageAsset(name: "iconRadioSelected")
  internal static let iconRadioUnselected = ImageAsset(name: "iconRadioUnselected")
  internal static let iconRefreshLg = ImageAsset(name: "icon_refresh_lg")
  internal static let iconRefreshMd = ImageAsset(name: "icon_refresh_md")
  internal static let iconRefreshSm = ImageAsset(name: "icon_refresh_sm")
  internal static let iconRefreshXs = ImageAsset(name: "icon_refresh_xs")
  internal static let iconSettingLg = ImageAsset(name: "icon_setting_lg")
  internal static let iconSettingMd = ImageAsset(name: "icon_setting_md")
  internal static let iconSettingSm = ImageAsset(name: "icon_setting_sm")
  internal static let iconSettingXs = ImageAsset(name: "icon_setting_xs")
  internal static let iconStarFillLg = ImageAsset(name: "icon_star_fill_lg")
  internal static let iconStarFillMd = ImageAsset(name: "icon_star_fill_md")
  internal static let iconStarFillSm = ImageAsset(name: "icon_star_fill_sm")
  internal static let iconStarFillXs = ImageAsset(name: "icon_star_fill_xs")
  internal static let iconStarHalfFillLg = ImageAsset(name: "icon_star_half_fill_lg")
  internal static let iconStarHalfFillMd = ImageAsset(name: "icon_star_half_fill_md")
  internal static let iconStarHalfFillSm = ImageAsset(name: "icon_star_half_fill_sm")
  internal static let iconStarHalfFillXs = ImageAsset(name: "icon_star_half_fill_xs")
  internal static let iconStarLg = ImageAsset(name: "icon_star_lg")
  internal static let iconStarMd = ImageAsset(name: "icon_star_md")
  internal static let iconStarSm = ImageAsset(name: "icon_star_sm")
  internal static let iconStarXs = ImageAsset(name: "icon_star_xs")
  internal static let iconUserBadge = ImageAsset(name: "icon_user_badge")
  internal static let iconUserLg = ImageAsset(name: "icon_user_lg")
  internal static let iconUserMd = ImageAsset(name: "icon_user_md")
  internal static let iconUserSm = ImageAsset(name: "icon_user_sm")
  internal static let iconUserXs = ImageAsset(name: "icon_user_xs")
  internal static let carAddEmptyBorder = ImageAsset(name: "car_add_empty_border")
  internal static let carEmptyBorder = ImageAsset(name: "car_empty_border")
  internal static let iconArrowDownLg = ImageAsset(name: "icon_arrow_down_lg")
  internal static let iconArrowDownMd = ImageAsset(name: "icon_arrow_down_md")
  internal static let iconArrowDownSm = ImageAsset(name: "icon_arrow_down_sm")
  internal static let iconArrowDownXs = ImageAsset(name: "icon_arrow_down_xs")
  internal static let iconArrowLeftLg = ImageAsset(name: "icon_arrow_left_lg")
  internal static let iconArrowLeftMd = ImageAsset(name: "icon_arrow_left_md")
  internal static let iconArrowLeftSm = ImageAsset(name: "icon_arrow_left_sm")
  internal static let iconArrowLeftXs = ImageAsset(name: "icon_arrow_left_xs")
  internal static let iconArrowRightLg = ImageAsset(name: "icon_arrow_right_lg")
  internal static let iconArrowRightMd = ImageAsset(name: "icon_arrow_right_md")
  internal static let iconArrowRightSm = ImageAsset(name: "icon_arrow_right_sm")
  internal static let iconArrowRightXs = ImageAsset(name: "icon_arrow_right_xs")
  internal static let iconArrowUpLg = ImageAsset(name: "icon_arrow_up_lg")
  internal static let iconArrowUpMd = ImageAsset(name: "icon_arrow_up_md")
  internal static let iconArrowUpSm = ImageAsset(name: "icon_arrow_up_sm")
  internal static let iconArrowUpXs = ImageAsset(name: "icon_arrow_up_xs")
  internal static let iconChevronDownLg = ImageAsset(name: "icon_chevron_down_lg")
  internal static let iconChevronDownMd = ImageAsset(name: "icon_chevron_down_md")
  internal static let iconChevronDownSm = ImageAsset(name: "icon_chevron_down_sm")
  internal static let iconChevronDownXs = ImageAsset(name: "icon_chevron_down_xs")
  internal static let iconChevronLeftLg = ImageAsset(name: "icon_chevron_left_lg")
  internal static let iconChevronLeftMd = ImageAsset(name: "icon_chevron_left_md")
  internal static let iconChevronLeftSm = ImageAsset(name: "icon_chevron_left_sm")
  internal static let iconChevronLeftXs = ImageAsset(name: "icon_chevron_left_xs")
  internal static let iconChevronRightLg = ImageAsset(name: "icon_chevron_right_lg")
  internal static let iconChevronRightMd = ImageAsset(name: "icon_chevron_right_md")
  internal static let iconChevronRightSm = ImageAsset(name: "icon_chevron_right_sm")
  internal static let iconChevronRightXs = ImageAsset(name: "icon_chevron_right_xs")
  internal static let iconChevronUpLg = ImageAsset(name: "icon_chevron_up_lg")
  internal static let iconChevronUpMd = ImageAsset(name: "icon_chevron_up_md")
  internal static let iconChevronUpSm = ImageAsset(name: "icon_chevron_up_sm")
  internal static let iconChevronUpXs = ImageAsset(name: "icon_chevron_up_xs")
  internal static let iconCloseLg = ImageAsset(name: "icon_close_lg")
  internal static let iconCloseMd = ImageAsset(name: "icon_close_md")
  internal static let iconCloseSm = ImageAsset(name: "icon_close_sm")
  internal static let iconCloseXs = ImageAsset(name: "icon_close_xs")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
