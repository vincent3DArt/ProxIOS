//
//  Deal.swift
//  ProxDeals
//
//  The data model for a single grocery deal.
//  Codable so it can be decoded straight from the mock JSON.
//

import Foundation

/// The kind of promotion attached to a deal. Used by the filter screen.
/// Raw values are the human-readable labels shown in the UI.
enum DealType: String, Codable, CaseIterable {
    case discount   = "Discount"
    case bogo       = "Buy One Get One"
    case clearance  = "Clearance"
    case coupon     = "Coupon"
    case memberOnly = "Member Only"
}

/// A product category. Used by the filter screen.
enum Category: String, Codable, CaseIterable {
    case dairy     = "Dairy"
    case produce   = "Produce"
    case bakery    = "Bakery"
    case meat      = "Meat & Seafood"
    case pantry    = "Pantry"
    case beverages = "Beverages"
    case frozen    = "Frozen"
    case snacks    = "Snacks"
}

/// One grocery deal shown in the Deals list / Detail screen / Cart.
struct Deal: Codable, Equatable {
    let id: String          // stable unique id (used for save syncing)
    let name: String        // product name, e.g. "Whole Milk"
    let store: String       // retailer, e.g. "Ralphs"
    let price: Double       // sale price
    let originalPrice: Double
    let size: String        // e.g. "1 gal" / "12 oz"
    let imageName: String   // asset name; falls back to the prox logo if missing
    let dealType: DealType
    let category: Category
    let distanceMiles: Double  // distance to the store
    let dealDescription: String

    /// Percent saved vs the original price, rounded to a whole number.
    /// Returns 0 when there is no real discount.
    var savingsPercent: Int {
        guard originalPrice > 0, originalPrice > price else { return 0 }
        let pct = (1.0 - (price / originalPrice)) * 100.0
        return Int(pct.rounded())
    }

    /// "$3.49" style string for the sale price.
    var priceText: String { String(format: "$%.2f", price) }

    /// "$4.99" style string for the original (struck-through) price.
    var originalPriceText: String { String(format: "$%.2f", originalPrice) }

    /// "Save 30%" badge text.
    var savingsText: String { savingsPercent > 0 ? "Save \(savingsPercent)%" : "" }

    // MARK: - Icon

    /// An SF Symbol that represents this product. Chosen per-item where a good
    /// match exists, otherwise it falls back to a sensible per-category symbol.
    /// SF Symbols are built into iOS, so no image assets are needed.
    var symbolName: String {
        // Per-item matches first (keyed off the product name).
        let n = name.lowercased()
        if n.contains("milk") && n.contains("almond") { return "leaf.fill" }
        if n.contains("milk")        { return "drop.fill" }
        if n.contains("egg")         { return "oval.portrait.fill" }
        if n.contains("banana")      { return "leaf.fill" }
        if n.contains("bread") || n.contains("sourdough") || n.contains("bagel") { return "birthday.cake.fill" }
        if n.contains("croissant")   { return "birthday.cake.fill" }
        if n.contains("chicken") || n.contains("beef") || n.contains("salmon") { return "fish.fill" }
        if n.contains("sauce")       { return "takeoutbag.and.cup.and.straw.fill" }
        if n.contains("juice") || n.contains("orange juice") { return "waterbottle.fill" }
        if n.contains("coffee")      { return "cup.and.saucer.fill" }
        if n.contains("pizza")       { return "circle.grid.cross.fill" }
        if n.contains("chip") || n.contains("tortilla") { return "bag.fill" }
        if n.contains("yogurt")      { return "cup.and.saucer.fill" }
        if n.contains("strawberr") || n.contains("berr") { return "leaf.fill" }
        if n.contains("cheese")      { return "triangle.fill" }
        if n.contains("avocado")     { return "leaf.fill" }
        if n.contains("oil")         { return "drop.fill" }
        if n.contains("water")       { return "waterbottle.fill" }
        if n.contains("butter")      { return "square.fill" }
        if n.contains("tomato")      { return "circle.fill" }
        if n.contains("peanut")      { return "takeoutbag.and.cup.and.straw.fill" }
        if n.contains("cola")        { return "waterbottle.fill" }
        if n.contains("waffle")      { return "square.grid.3x3.fill" }
        if n.contains("trail mix")   { return "bag.fill" }
        if n.contains("spinach")     { return "leaf.fill" }
        // Fall back to a per-category symbol.
        switch category {
        case .dairy:     return "drop.fill"
        case .produce:   return "leaf.fill"
        case .bakery:    return "birthday.cake.fill"
        case .meat:      return "fish.fill"
        case .pantry:    return "shippingbox.fill"
        case .beverages: return "cup.and.saucer.fill"
        case .frozen:    return "snowflake"
        case .snacks:    return "bag.fill"
        }
    }

    /// A category index used to pick a tint color. Kept as a simple Int so the
    /// UI layer can map it to a UIColor without importing UIKit into the model.
    var categoryColorIndex: Int {
        switch category {
        case .dairy:     return 0
        case .produce:   return 1
        case .bakery:    return 2
        case .meat:      return 3
        case .pantry:    return 4
        case .beverages: return 5
        case .frozen:    return 6
        case .snacks:    return 7
        }
    }
}
