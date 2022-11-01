// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Colors {
  internal static let backgroundAlwaysDark = ColorAsset(name: "background-always-dark")
  internal static let backgroundAlwaysLight = ColorAsset(name: "background-always-light")
  internal static let backgroundDisabled = ColorAsset(name: "background-disabled")
  internal static let backgroundNegativeLight = ColorAsset(name: "background-negative-light")
  internal static let backgroundNegative = ColorAsset(name: "background-negative")
  internal static let backgroundOverlayDark = ColorAsset(name: "background-overlay-dark")
  internal static let backgroundOverlayLight = ColorAsset(name: "background-overlay-light")
  internal static let backgroundPositiveLight = ColorAsset(name: "background-positive-light")
  internal static let backgroundPositive = ColorAsset(name: "background-positive")
  internal static let backgroundPrimaryTransparency = ColorAsset(name: "background-primary-transparency")
  internal static let backgroundPrimary = ColorAsset(name: "background-primary")
  internal static let backgroundSecondary = ColorAsset(name: "background-secondary")
  internal static let backgroundTertiary = ColorAsset(name: "background-tertiary")
  internal static let backgroundWarningLight = ColorAsset(name: "background-warning-light")
  internal static let backgroundWarning = ColorAsset(name: "background-warning")
  internal static let borderDisabled = ColorAsset(name: "border-disabled")
  internal static let borderNegative = ColorAsset(name: "border-negative")
  internal static let borderOpaque = ColorAsset(name: "border-opaque")
  internal static let borderPositive = ColorAsset(name: "border-positive")
  internal static let borderSelected = ColorAsset(name: "border-selected")
  internal static let borderWarning = ColorAsset(name: "border-warning")
  internal static let contentDisabled = ColorAsset(name: "content-disabled")
  internal static let contentNegative = ColorAsset(name: "content-negative")
  internal static let contentOnColor = ColorAsset(name: "content-on-color")
  internal static let contentPositive = ColorAsset(name: "content-positive")
  internal static let contentPrimary = ColorAsset(name: "content-primary")
  internal static let contentSecondary = ColorAsset(name: "content-secondary")
  internal static let contentTertiary = ColorAsset(name: "content-tertiary")
  internal static let contentWarning = ColorAsset(name: "content-warning")
  internal static let gr1 = ColorAsset(name: "gr-1")
  internal static let gr2 = ColorAsset(name: "gr-2")
  internal static let gr3 = ColorAsset(name: "gr-3")
  internal static let gr4 = ColorAsset(name: "gr-4")
  internal static let gr5 = ColorAsset(name: "gr-5")
  internal static let gr6 = ColorAsset(name: "gr-6")
  internal static let gr7 = ColorAsset(name: "gr-7")
  internal static let gr8 = ColorAsset(name: "gr-8")
  internal static let gr9 = ColorAsset(name: "gr-9")
  internal static let mt1 = ColorAsset(name: "mt-1")
  internal static let mt2 = ColorAsset(name: "mt-2")
  internal static let mt3 = ColorAsset(name: "mt-3")
  internal static let mt4 = ColorAsset(name: "mt-4")
  internal static let mt5 = ColorAsset(name: "mt-5")
  internal static let nt0 = ColorAsset(name: "nt-0")
  internal static let nt1 = ColorAsset(name: "nt-1")
  internal static let nt2 = ColorAsset(name: "nt-2")
  internal static let nt3 = ColorAsset(name: "nt-3")
  internal static let nt4 = ColorAsset(name: "nt-4")
  internal static let nt5 = ColorAsset(name: "nt-5")
  internal static let nt6 = ColorAsset(name: "nt-6")
  internal static let nt7 = ColorAsset(name: "nt-7")
  internal static let nt8 = ColorAsset(name: "nt-8")
  internal static let nt9 = ColorAsset(name: "nt-9")
  internal static let ntBlack = ColorAsset(name: "nt-black")
  internal static let ntWhite = ColorAsset(name: "nt-white")
  internal static let rd1 = ColorAsset(name: "rd-1")
  internal static let rd2 = ColorAsset(name: "rd-2")
  internal static let rd3 = ColorAsset(name: "rd-3")
  internal static let rd4 = ColorAsset(name: "rd-4")
  internal static let rd5 = ColorAsset(name: "rd-5")
  internal static let rd6 = ColorAsset(name: "rd-6")
  internal static let rd7 = ColorAsset(name: "rd-7")
  internal static let rd8 = ColorAsset(name: "rd-8")
  internal static let rd9 = ColorAsset(name: "rd-9")
  internal static let yl1 = ColorAsset(name: "yl-1")
  internal static let yl10 = ColorAsset(name: "yl-10")
  internal static let yl2 = ColorAsset(name: "yl-2")
  internal static let yl3 = ColorAsset(name: "yl-3")
  internal static let yl4 = ColorAsset(name: "yl-4")
  internal static let yl5 = ColorAsset(name: "yl-5")
  internal static let yl6 = ColorAsset(name: "yl-6")
  internal static let yl7 = ColorAsset(name: "yl-7")
  internal static let yl8 = ColorAsset(name: "yl-8")
  internal static let yl9 = ColorAsset(name: "yl-9")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

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
