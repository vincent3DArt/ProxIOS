//
//  SaveStore.swift
//  ProxDeals
//
//  A single shared place that remembers which deals the user saved.
//  Every screen (Deals list, Detail, Cart, and the tab badge) reads
//  from here and listens for changes, so a save made anywhere shows
//  up everywhere instantly.
//

import Foundation

final class SaveStore {

    /// One shared instance for the whole app.
    static let shared = SaveStore()
    private init() {}

    /// Posted whenever the set of saved deals changes.
    /// Any screen can observe this to refresh itself.
    static let didChangeNotification = Notification.Name("SaveStoreDidChange")

    /// The ids of deals the user has saved. Private so all writes
    /// go through the methods below (which post the notification).
    private(set) var savedIDs: Set<String> = []

    /// The full Deal objects that are currently saved.
    /// Cart uses this to build its list.
    private(set) var savedDeals: [Deal] = []

    /// True if the given deal is currently saved.
    func isSaved(_ deal: Deal) -> Bool {
        savedIDs.contains(deal.id)
    }

    func isSaved(id: String) -> Bool {
        savedIDs.contains(id)
    }

    /// How many items are saved (drives the cart badge).
    var count: Int { savedIDs.count }

    /// Flips a deal between saved and unsaved, then notifies listeners.
    func toggle(_ deal: Deal) {
        if savedIDs.contains(deal.id) {
            savedIDs.remove(deal.id)
            savedDeals.removeAll { $0.id == deal.id }
        } else {
            savedIDs.insert(deal.id)
            savedDeals.append(deal)
        }
        notifyChange()
    }

    /// Explicit set/unset (used by the detail screen if needed).
    func setSaved(_ saved: Bool, for deal: Deal) {
        let already = savedIDs.contains(deal.id)
        if saved && !already {
            savedIDs.insert(deal.id)
            savedDeals.append(deal)
            notifyChange()
        } else if !saved && already {
            savedIDs.remove(deal.id)
            savedDeals.removeAll { $0.id == deal.id }
            notifyChange()
        }
    }

    private func notifyChange() {
        NotificationCenter.default.post(name: SaveStore.didChangeNotification, object: nil)
    }
}
