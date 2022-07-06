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
  internal static let iconInfoLg = ImageAsset(name: "icon_info_lg")
  internal static let iconInfoMd = ImageAsset(name: "icon_info_md")
  internal static let iconInfoSm = ImageAsset(name: "icon_info_sm")
  internal static let iconInfoXs = ImageAsset(name: "icon_info_xs")
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