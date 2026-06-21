//
//  ProxDealsTests.swift
//  ProxDealsTests
//
//  Unit tests for the pure logic that powers the app:
//  JSON decoding, savings math, filtering, and save toggling.
//

import Testing
@testable import ProxDeals

struct ProxDealsTests {

    // A small helper deal for tests.
    private func makeDeal(id: String = "t1",
                          price: Double = 3.0,
                          original: Double = 6.0,
                          store: String = "Ralphs",
                          type: DealType = .discount,
                          category: Category = .dairy,
                          distance: Double = 1.0) -> Deal {
        Deal(id: id, name: "Test Item", store: store, price: price,
             originalPrice: original, size: "1 ct", imageName: "x",
             dealType: type, category: category, distanceMiles: distance,
             dealDescription: "desc")
    }

    // MARK: Decoding

    @Test func mockJSONDecodesAllDeals() async throws {
        let deals = DealsData.decodedDeals()
        #expect(deals.count == 30)            // all rows decode (catches enum raw-value mismatches)
        #expect(deals.first?.id == "d1")
    }

    // MARK: Savings math

    @Test func savingsPercentIsCorrect() async throws {
        let deal = makeDeal(price: 3.0, original: 6.0)
        #expect(deal.savingsPercent == 50)
        #expect(deal.savingsText == "Save 50%")
    }

    @Test func savingsPercentIsZeroWhenNoDiscount() async throws {
        let deal = makeDeal(price: 6.0, original: 6.0)
        #expect(deal.savingsPercent == 0)
        #expect(deal.savingsText == "")
    }

    @Test func priceFormatting() async throws {
        let deal = makeDeal(price: 3.5, original: 4.99)
        #expect(deal.priceText == "$3.50")
        #expect(deal.originalPriceText == "$4.99")
    }

    // MARK: Filtering

    @Test func emptyFilterReturnsEverything() async throws {
        let deals = DealsData.decodedDeals()
        let filtered = FilterOptions().apply(to: deals)
        #expect(filtered.count == deals.count)
    }

    @Test func storeFilterWorks() async throws {
        let deals = DealsData.decodedDeals()
        var f = FilterOptions()
        f.stores = ["Ralphs"]
        let filtered = f.apply(to: deals)
        #expect(!filtered.isEmpty)
        #expect(filtered.allSatisfy { $0.store == "Ralphs" })
    }

    @Test func maxPriceFilterWorks() async throws {
        let deals = DealsData.decodedDeals()
        var f = FilterOptions()
        f.maxPrice = 3.0
        let filtered = f.apply(to: deals)
        #expect(filtered.allSatisfy { $0.price <= 3.0 })
    }

    @Test func combinedFiltersAreAndedTogether() async throws {
        let deals = DealsData.decodedDeals()
        var f = FilterOptions()
        f.categories = [.dairy]
        f.maxPrice = 3.0
        let filtered = f.apply(to: deals)
        #expect(filtered.allSatisfy { $0.category == .dairy && $0.price <= 3.0 })
    }

    // MARK: Save store

    @MainActor
    @Test func toggleSaveAddsAndRemoves() async throws {
        let store = SaveStore.shared
        // Start from a known empty state for the test deal.
        let deal = makeDeal(id: "save-test-1")
        if store.isSaved(deal) { store.toggle(deal) }

        #expect(store.isSaved(deal) == false)
        store.toggle(deal)
        #expect(store.isSaved(deal) == true)
        #expect(store.savedDeals.contains(where: { $0.id == "save-test-1" }))
        store.toggle(deal)
        #expect(store.isSaved(deal) == false)
    }
}
