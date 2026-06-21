//
//  CartViewController.swift
//  ProxDeals
//
//  The Cart tab. Shows all saved deals, a clean empty state when
//  nothing is saved, and keeps the tab-bar badge count up to date.
//

import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Var
    @IBOutlet weak var cartLogo: UIImageView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var totalSaving: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        cartLogo.layer.cornerRadius = cartLogo.frame.width / 2
        cartLogo.clipsToBounds = true
    }

    // TableView
    @IBOutlet weak var cartTableView: UITableView!

    // Empty
    private let emptyView = MessageView()

    private var deals: [Deal] { SaveStore.shared.savedDeals }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartTableView?.dataSource = self
        cartTableView?.delegate = self
        cartTableView?.rowHeight = 131
        

        emptyView.configure(title: "Your cart is empty",
                            message: "Tap the star on a deal to save it here.",
                            buttonTitle: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(savesChanged),
            name: SaveStore.didChangeNotification,
            object: nil
        )

        refresh()
        updateBadge()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func savesChanged() {
        refresh()
        updateBadge()
    }

    private func refresh() {
        let isEmpty = deals.isEmpty

        cartTableView?.backgroundView = isEmpty ? emptyView : nil
        cartTableView?.separatorStyle = isEmpty ? .none : .singleLine
        cartTableView?.reloadData()

        updateTotals()
    }

    /// Updates the price summary labels.
    private func updateTotals() {
        let subtotal = deals.reduce(0) { $0 + $1.price }
        let saved = deals.reduce(0) { $0 + ($1.originalPrice - $1.price) }
        let estTax = subtotal * 0.0975   // ~CA sales tax for a realistic preview
        totalPrice?.text = String(format: "Total Price: $%.2f", subtotal + estTax)
        tax?.text = String(format: "Tax: $%.2f", estTax)
        totalSaving?.text = String(format: "Total Saving: $%.2f", saved)
    }

    /// Sets (or hides) the badge on the Cart tab.
    private func updateBadge() {
        let count = SaveStore.shared.count
        tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }

    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.reuseID,
                                                 for: indexPath) as! CartCell
        cell.configure(with: deals[indexPath.row])
        return cell
    }
}
