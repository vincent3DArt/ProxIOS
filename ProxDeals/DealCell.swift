//
//  DealCell.swift
//  ProxDeals
//
//  One row in the Deals table. Displays the product info and a
//  star save button that stays in sync with the shared SaveStore.
//

import UIKit

class DealCell: UITableViewCell {

    /// Reuse identifier (also set on the prototype in the storyboard).
    static let reuseID = "DealCell"

    // MARK: Outlets (already connected in the storyboard)
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var itemWeight: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemOriginalPrice: UILabel!
    @IBOutlet weak var savingPer: UILabel!
    @IBOutlet weak var saveButtonUI: UIButton!

    /// The deal this cell is currently showing.
    private var deal: Deal?

    /// Called by the table view controller to fill in the row.
    func configure(with deal: Deal) {
        self.deal = deal
        itemName.text = deal.name
        storeName.text = deal.store
        itemWeight.text = deal.size
        itemPrice.text = deal.priceText

        // Show the original price with a strike-through to signal the saving.
        let struck = NSAttributedString(
            string: deal.originalPriceText,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                         .foregroundColor: UIColor.secondaryLabel]
        )
        itemOriginalPrice.attributedText = struck

        savingPer.text = deal.savingsText
        savingPer.textColor = .systemGreen

        // Render a category-tinted SF Symbol as the product thumbnail.
        DealIcon.apply(to: itemImage, for: deal)

        updateSaveButton()
    }

    // Keep the icon's circular background correct after Auto Layout sizes the cell.
    override func layoutSubviews() {
        super.layoutSubviews()
        if let deal = deal { DealIcon.apply(to: itemImage, for: deal) }
    }

    /// Refreshes just the star to match the shared save state.
    func updateSaveButton() {
        guard let deal = deal else { return }
        let saved = SaveStore.shared.isSaved(deal)
        let star = saved ? "★" : "☆"
        // The storyboard button uses a UIButton.Configuration, so update the
        // configuration's title (setTitle alone is ignored when a config exists).
        if var config = saveButtonUI.configuration {
            config.title = star
            saveButtonUI.configuration = config
        } else {
            saveButtonUI.setTitle(star, for: .normal)
        }
        saveButtonUI.accessibilityLabel = saved ? "Saved" : "Save"
    }

    // MARK: Save
    @IBAction func saveButton(_ sender: Any) {
        guard let deal = deal else { return }
        // Toggling posts a notification; the cell, detail, cart and badge
        // all listen and refresh themselves.
        SaveStore.shared.toggle(deal)
        updateSaveButton()
    }
}
