//
//  CartCell.swift
//  ProxDeals
//
//  One row in the Cart table. Shows a saved deal and a star button
//  that removes it from the cart (unsaves it) when tapped.
//

import UIKit

class CartCell: UITableViewCell {

    /// Reuse identifier (also set on the prototype in the storyboard).
    static let reuseID = "CartCell"

    // MARK: Outlets (already connected in the storyboard)
    @IBOutlet weak var itemCartImage: UIImageView!
    @IBOutlet weak var itemCartName: UILabel!
    @IBOutlet weak var storeCartName: UILabel!
    @IBOutlet weak var itemCartWeight: UILabel!
    @IBOutlet weak var itemCartPrice: UILabel!
    @IBOutlet weak var itemCartOrignialPrice: UILabel!
    @IBOutlet weak var savingCartPer: UILabel!
    @IBOutlet weak var saveButtonUI: UIButton!

    private var deal: Deal?

    func configure(with deal: Deal) {
        self.deal = deal
        itemCartName.text = deal.name
        storeCartName.text = deal.store
        itemCartWeight.text = deal.size
        itemCartPrice.text = deal.priceText

        let struck = NSAttributedString(
            string: deal.originalPriceText,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                         .foregroundColor: UIColor.secondaryLabel]
        )
        itemCartOrignialPrice.attributedText = struck

        savingCartPer.text = deal.savingsText
        savingCartPer.textColor = .systemGreen

        // Render a category-tinted SF Symbol as the product thumbnail.
        DealIcon.apply(to: itemCartImage, for: deal)

        // Items in the cart are always saved, so always show the filled star.
        if var config = saveButtonUI?.configuration {
            config.title = "★"
            saveButtonUI?.configuration = config
        } else {
            saveButtonUI?.setTitle("★", for: .normal)
        }
    }

    // Keep the icon's circular background correct after Auto Layout sizes the cell.
    override func layoutSubviews() {
        super.layoutSubviews()
        if let deal = deal { DealIcon.apply(to: itemCartImage, for: deal) }
    }

    // MARK: Save
    @IBAction func savedButton(_ sender: Any) {
        guard let deal = deal else { return }
        // Unsave -> the cart list and badge update via the notification.
        SaveStore.shared.toggle(deal)
    }
}
