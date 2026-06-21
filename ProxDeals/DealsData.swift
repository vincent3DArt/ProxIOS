//
//  DealsData.swift
//  ProxDeals
//
//  Provides the mock grocery data and a tiny "mock API" that
//  simulates async loading so the Deals screen can show real
//  loading / empty / error states.
//

import Foundation

/// The result handed back by the mock API.
enum DealsLoadResult {
    case success([Deal])
    case empty            // request worked but returned nothing
    case failure(String)  // an error message to display
}

/// A stand-in for a real network/data layer.
/// Everything is local, but it runs on a delay and can be told
/// to return empty / error so the UI states are demonstrable.
enum DealsData {

    /// Mock JSON. In a real app this would come from an API response body.
    /// Kept as a raw string so it shows real JSON decoding end-to-end.
    static let mockJSON = """
    [
      {"id":"d1","name":"Whole Milk","store":"Ralphs","price":3.49,"originalPrice":4.99,"size":"1 gal","imageName":"deal_milk","dealType":"Discount","category":"Dairy","distanceMiles":0.8,"dealDescription":"Grade A whole milk. Limit 2 per customer with card."},
      {"id":"d2","name":"Large Eggs (Dozen)","store":"Vons","price":2.99,"originalPrice":5.49,"size":"12 ct","imageName":"deal_eggs","dealType":"Clearance","category":"Dairy","distanceMiles":1.4,"dealDescription":"Cage-free large brown eggs. While supplies last."},
      {"id":"d3","name":"Bananas","store":"Trader Joe's","price":0.49,"originalPrice":0.69,"size":"per lb","imageName":"deal_bananas","dealType":"Discount","category":"Produce","distanceMiles":2.1,"dealDescription":"Fresh organic bananas, sold by the pound."},
      {"id":"d4","name":"Sourdough Loaf","store":"Sprouts","price":3.99,"originalPrice":3.99,"size":"24 oz","imageName":"deal_bread","dealType":"Buy One Get One","category":"Bakery","distanceMiles":3.0,"dealDescription":"Buy one get one free on fresh-baked sourdough."},
      {"id":"d5","name":"Chicken Breast","store":"Ralphs","price":6.49,"originalPrice":9.99,"size":"2 lb","imageName":"deal_chicken","dealType":"Member Only","category":"Meat & Seafood","distanceMiles":0.8,"dealDescription":"Boneless skinless chicken breast. Member price with card."},
      {"id":"d6","name":"Pasta Sauce","store":"Vons","price":1.99,"originalPrice":3.49,"size":"24 oz","imageName":"deal_sauce","dealType":"Coupon","category":"Pantry","distanceMiles":1.4,"dealDescription":"Marinara pasta sauce. Clip coupon to redeem."},
      {"id":"d7","name":"Orange Juice","store":"Trader Joe's","price":2.49,"originalPrice":3.99,"size":"52 oz","imageName":"deal_oj","dealType":"Discount","category":"Beverages","distanceMiles":2.1,"dealDescription":"100% Florida orange juice, no pulp."},
      {"id":"d8","name":"Frozen Pizza","store":"Sprouts","price":4.99,"originalPrice":7.99,"size":"18 oz","imageName":"deal_pizza","dealType":"Clearance","category":"Frozen","distanceMiles":3.0,"dealDescription":"Wood-fired margherita frozen pizza."},
      {"id":"d9","name":"Potato Chips","store":"Ralphs","price":2.50,"originalPrice":4.29,"size":"8 oz","imageName":"deal_chips","dealType":"Buy One Get One","category":"Snacks","distanceMiles":0.8,"dealDescription":"Kettle-cooked sea salt chips. BOGO this week."},
      {"id":"d10","name":"Greek Yogurt","store":"Vons","price":0.89,"originalPrice":1.49,"size":"5.3 oz","imageName":"deal_yogurt","dealType":"Discount","category":"Dairy","distanceMiles":1.4,"dealDescription":"Nonfat plain Greek yogurt, single cup."},
      {"id":"d11","name":"Strawberries","store":"Sprouts","price":2.99,"originalPrice":4.99,"size":"1 lb","imageName":"deal_strawberries","dealType":"Discount","category":"Produce","distanceMiles":3.0,"dealDescription":"Sweet California strawberries, 1 lb clamshell."},
      {"id":"d12","name":"Ground Coffee","store":"Trader Joe's","price":5.99,"originalPrice":8.99,"size":"12 oz","imageName":"deal_coffee","dealType":"Member Only","category":"Beverages","distanceMiles":2.1,"dealDescription":"Medium roast ground coffee. Member exclusive."},
      {"id":"d13","name":"Cheddar Cheese Block","store":"Whole Foods","price":4.49,"originalPrice":6.99,"size":"8 oz","imageName":"deal_cheese","dealType":"Discount","category":"Dairy","distanceMiles":4.2,"dealDescription":"Sharp cheddar cheese block, aged 9 months."},
      {"id":"d14","name":"Avocados","store":"Albertsons","price":0.99,"originalPrice":1.99,"size":"each","imageName":"deal_avocado","dealType":"Discount","category":"Produce","distanceMiles":1.9,"dealDescription":"Large Hass avocados, ripe and ready."},
      {"id":"d15","name":"Bagels (6 ct)","store":"Ralphs","price":2.99,"originalPrice":4.49,"size":"6 ct","imageName":"deal_bagels","dealType":"Coupon","category":"Bakery","distanceMiles":0.8,"dealDescription":"Fresh plain bagels. Clip coupon for the deal."},
      {"id":"d16","name":"Ground Beef 80/20","store":"Vons","price":4.99,"originalPrice":7.49,"size":"1 lb","imageName":"deal_beef","dealType":"Clearance","category":"Meat & Seafood","distanceMiles":1.4,"dealDescription":"Fresh 80/20 ground beef, sold by the pound."},
      {"id":"d17","name":"Olive Oil","store":"Trader Joe's","price":6.99,"originalPrice":10.99,"size":"16.9 oz","imageName":"deal_oil","dealType":"Discount","category":"Pantry","distanceMiles":2.1,"dealDescription":"Cold-pressed extra virgin olive oil."},
      {"id":"d18","name":"Sparkling Water (12 pk)","store":"Sprouts","price":3.49,"originalPrice":5.99,"size":"12 ct","imageName":"deal_water","dealType":"Buy One Get One","category":"Beverages","distanceMiles":3.0,"dealDescription":"Assorted flavor sparkling water. BOGO this week."},
      {"id":"d19","name":"Frozen Berries","store":"Whole Foods","price":3.99,"originalPrice":6.49,"size":"16 oz","imageName":"deal_berries","dealType":"Discount","category":"Frozen","distanceMiles":4.2,"dealDescription":"Mixed frozen berries, no added sugar."},
      {"id":"d20","name":"Tortilla Chips","store":"Albertsons","price":1.99,"originalPrice":3.49,"size":"11 oz","imageName":"deal_tortilla","dealType":"Coupon","category":"Snacks","distanceMiles":1.9,"dealDescription":"Restaurant-style tortilla chips."},
      {"id":"d21","name":"Butter (4 sticks)","store":"Ralphs","price":3.49,"originalPrice":5.49,"size":"16 oz","imageName":"deal_butter","dealType":"Member Only","category":"Dairy","distanceMiles":0.8,"dealDescription":"Salted sweet cream butter, 4 sticks."},
      {"id":"d22","name":"Roma Tomatoes","store":"Vons","price":0.79,"originalPrice":1.29,"size":"per lb","imageName":"deal_tomato","dealType":"Discount","category":"Produce","distanceMiles":1.4,"dealDescription":"Vine-ripened Roma tomatoes, sold by the pound."},
      {"id":"d23","name":"Croissants (4 ct)","store":"Whole Foods","price":3.99,"originalPrice":5.99,"size":"4 ct","imageName":"deal_croissant","dealType":"Clearance","category":"Bakery","distanceMiles":4.2,"dealDescription":"All-butter croissants, baked fresh daily."},
      {"id":"d24","name":"Atlantic Salmon","store":"Sprouts","price":8.99,"originalPrice":12.99,"size":"1 lb","imageName":"deal_salmon","dealType":"Member Only","category":"Meat & Seafood","distanceMiles":3.0,"dealDescription":"Fresh Atlantic salmon fillet. Member price."},
      {"id":"d25","name":"Peanut Butter","store":"Albertsons","price":2.49,"originalPrice":3.99,"size":"16 oz","imageName":"deal_pb","dealType":"Discount","category":"Pantry","distanceMiles":1.9,"dealDescription":"Creamy peanut butter, no stir needed."},
      {"id":"d26","name":"Cola (12 pk)","store":"Ralphs","price":4.99,"originalPrice":7.99,"size":"12 ct","imageName":"deal_cola","dealType":"Buy One Get One","category":"Beverages","distanceMiles":0.8,"dealDescription":"Classic cola, 12-pack cans. BOGO this week."},
      {"id":"d27","name":"Frozen Waffles","store":"Vons","price":2.49,"originalPrice":3.99,"size":"10 ct","imageName":"deal_waffles","dealType":"Coupon","category":"Frozen","distanceMiles":1.4,"dealDescription":"Homestyle frozen waffles, 10 count."},
      {"id":"d28","name":"Trail Mix","store":"Trader Joe's","price":3.99,"originalPrice":5.49,"size":"14 oz","imageName":"deal_trailmix","dealType":"Discount","category":"Snacks","distanceMiles":2.1,"dealDescription":"Sweet and salty trail mix with chocolate."},
      {"id":"d29","name":"Almond Milk","store":"Whole Foods","price":2.99,"originalPrice":4.49,"size":"64 oz","imageName":"deal_almondmilk","dealType":"Discount","category":"Dairy","distanceMiles":4.2,"dealDescription":"Unsweetened almond milk, half gallon."},
      {"id":"d30","name":"Baby Spinach","store":"Albertsons","price":2.49,"originalPrice":3.99,"size":"10 oz","imageName":"deal_spinach","dealType":"Clearance","category":"Produce","distanceMiles":1.9,"dealDescription":"Triple-washed organic baby spinach."}
    ]
    """

    /// Decodes the mock JSON into Deal objects.
    /// Returns an empty array if decoding fails (handled upstream).
    static func decodedDeals() -> [Deal] {
        guard let data = mockJSON.data(using: .utf8) else { return [] }
        do {
            return try JSONDecoder().decode([Deal].self, from: data)
        } catch {
            print("Deal decode error: \(error)")
            return []
        }
    }

    // MARK: - Mock API

    /// Forces the next load to return a specific outcome.
    /// Leave as `.normal` for the real (successful) data.
    /// Flip this in code if you want to demo empty/error states quickly.
    enum DemoMode { case normal, forceEmpty, forceError }
    static var demoMode: DemoMode = .normal

    /// Simulates an async fetch with a short delay, then calls back
    /// on the main thread with a result. This is what lets the UI
    /// show a spinner first, then content / empty / error.
    static func fetchDeals(completion: @escaping (DealsLoadResult) -> Void) {
        let delay: TimeInterval = 1.2
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            let result: DealsLoadResult
            switch demoMode {
            case .forceError:
                result = .failure("Couldn't load deals. Check your connection and try again.")
            case .forceEmpty:
                result = .empty
            case .normal:
                let deals = decodedDeals()
                result = deals.isEmpty ? .empty : .success(deals)
            }
            DispatchQueue.main.async { completion(result) }
        }
    }
}
