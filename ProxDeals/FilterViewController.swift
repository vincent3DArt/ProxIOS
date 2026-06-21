//
//  FilterViewController.swift
//  ProxDeals
//
//  A filter screen presented as a modal. The UI is built in code
//  (a grouped table), so the storyboard scene only needs an empty
//  view controller with this class + a Storyboard ID set.
//
//  Filters: stores, deal type, category, max price, max distance.
//  Includes Apply and a Clear/Reset option.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// Provided by the Deals screen so we can list the real stores.
    var allDeals: [Deal] = []
    /// The currently-applied filters (so the screen opens pre-checked).
    var current = FilterOptions()
    /// Called when the user taps Apply.
    var onApply: ((FilterOptions) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // A working copy edited as the user toggles things.
    private var working = FilterOptions()
    private var stores: [String] = []

    // Price / distance choices presented as simple options.
    private let priceChoices: [Double] = [2, 3, 5, 7]
    private let distanceChoices: [Double] = [1, 2, 3, 5]

    private enum Section: Int, CaseIterable {
        case store, dealType, category, price, distance
        var title: String {
            switch self {
            case .store: return "Stores"
            case .dealType: return "Deal Type"
            case .category: return "Category"
            case .price: return "Max Price"
            case .distance: return "Max Distance"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filters"
        view.backgroundColor = .systemBackground
        working = current
        stores = FilterOptions.allStores(in: allDeals)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Clear", style: .plain, target: self, action: #selector(clearTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Apply", style: .done, target: self, action: #selector(applyTapped))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Table
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .store: return stores.count
        case .dealType: return DealType.allCases.count
        case .category: return Category.allCases.count
        case .price: return priceChoices.count
        case .distance: return distanceChoices.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "filterCell")
        var checked = false
        switch Section(rawValue: indexPath.section)! {
        case .store:
            let s = stores[indexPath.row]
            cell.textLabel?.text = s
            checked = working.stores.contains(s)
        case .dealType:
            let t = DealType.allCases[indexPath.row]
            cell.textLabel?.text = t.rawValue
            checked = working.dealTypes.contains(t)
        case .category:
            let c = Category.allCases[indexPath.row]
            cell.textLabel?.text = c.rawValue
            checked = working.categories.contains(c)
        case .price:
            let p = priceChoices[indexPath.row]
            cell.textLabel?.text = String(format: "Under $%.0f", p)
            checked = working.maxPrice == p
        case .distance:
            let d = distanceChoices[indexPath.row]
            cell.textLabel?.text = String(format: "Within %.0f mi", d)
            checked = working.maxDistance == d
        }
        cell.accessoryType = checked ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .store:
            let s = stores[indexPath.row]
            if working.stores.contains(s) { working.stores.remove(s) }
            else { working.stores.insert(s) }
        case .dealType:
            let t = DealType.allCases[indexPath.row]
            if working.dealTypes.contains(t) { working.dealTypes.remove(t) }
            else { working.dealTypes.insert(t) }
        case .category:
            let c = Category.allCases[indexPath.row]
            if working.categories.contains(c) { working.categories.remove(c) }
            else { working.categories.insert(c) }
        case .price:
            let p = priceChoices[indexPath.row]
            working.maxPrice = (working.maxPrice == p) ? nil : p   // tap again to clear
        case .distance:
            let d = distanceChoices[indexPath.row]
            working.maxDistance = (working.maxDistance == d) ? nil : d
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }

    // MARK: Actions
    @objc private func clearTapped() {
        working = FilterOptions()
        tableView.reloadData()
    }

    @objc private func applyTapped() {
        onApply?(working)
        dismiss(animated: true)
    }
}
