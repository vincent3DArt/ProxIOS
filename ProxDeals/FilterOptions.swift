//
//  FilterOptions.swift
//  ProxDeals
//
//  Holds the user's current filter selections and knows how to
//  apply them to a list of deals.
//

import Foundation

struct FilterOptions {
    /// Selected stores. Empty == "all stores".
    var stores: Set<String> = []
    /// Selected deal types. Empty == "all types".
    var dealTypes: Set<DealType> = []
    /// Selected categories. Empty == "all categories".
    var categories: Set<Category> = []
    /// Maximum price the user will accept. nil == no cap.
    var maxPrice: Double? = nil
    /// Maximum distance in miles. nil == no limit.
    var maxDistance: Double? = nil

    /// True when nothing is selected (so the list shows everything).
    var isEmpty: Bool {
        stores.isEmpty && dealTypes.isEmpty && categories.isEmpty
            && maxPrice == nil && maxDistance == nil
    }

    /// Returns only the deals that pass every active filter.
    func apply(to deals: [Deal]) -> [Deal] {
        deals.filter { deal in
            if !stores.isEmpty && !stores.contains(deal.store) { return false }
            if !dealTypes.isEmpty && !dealTypes.contains(deal.dealType) { return false }
            if !categories.isEmpty && !categories.contains(deal.category) { return false }
            if let maxPrice = maxPrice, deal.price > maxPrice { return false }
            if let maxDistance = maxDistance, deal.distanceMiles > maxDistance { return false }
            return true
        }
    }

    /// All store names present in the data (for building the filter UI).
    static func allStores(in deals: [Deal]) -> [String] {
        Array(Set(deals.map { $0.store })).sorted()
    }
}
