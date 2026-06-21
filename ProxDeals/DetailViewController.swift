//
//  DetailViewController.swift
//  ProxDeals
//
//  The Product / Deal detail screen, shown when a deal row is tapped.
//  Backs the existing "Item" scene in the storyboard. Its save button
//  stays in sync with the Deals list and Cart via SaveStore.
//

import UIKit

class DetailViewController: UIViewController {

    /// The deal to display. Set by the Deals screen before presenting.
    var deal: Deal!

    // MARK: Outlets YOU will connect in the storyboard (Item scene)
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Deal Details"
        view.backgroundColor = .systemBackground

        // A Close button so the presented screen can be dismissed.
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeTapped))

        populate()

        // Keep the save button in sync if the state changes elsewhere.
        NotificationCenter.default.addObserver(
            self, selector: #selector(savesChanged),
            name: SaveStore.didChangeNotification, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func populate() {
        guard deal != nil else { return }
        // Large category-tinted SF Symbol as the product image.
        let config = UIImage.SymbolConfiguration(pointSize: 96, weight: .semibold)
        productImage?.image = UIImage(systemName: deal.symbolName, withConfiguration: config)
            ?? UIImage(systemName: "bag.fill", withConfiguration: config)
        productImage?.tintColor = DealIcon.tint(for: deal)
        productImage?.contentMode = .center
        productImage?.backgroundColor = DealIcon.tint(for: deal).withAlphaComponent(0.12)
        productImage?.layer.cornerRadius = 16
        productImage?.clipsToBounds = true

        nameLabel?.text = deal.name
        storeLabel?.text = deal.store
        priceLabel?.text = deal.priceText
        sizeLabel?.text = deal.size
        descriptionLabel?.text = deal.dealDescription
        descriptionLabel?.numberOfLines = 0

        let struck = NSAttributedString(
            string: deal.originalPriceText,
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                         .foregroundColor: UIColor.secondaryLabel])
        originalPriceLabel?.attributedText = struck

        savingsLabel?.text = deal.savingsText
        savingsLabel?.textColor = .systemGreen

        updateSaveButton()
    }

    private func updateSaveButton() {
        let saved = SaveStore.shared.isSaved(deal)
        saveButton?.setTitle(saved ? "★ Saved" : "☆ Save", for: .normal)
    }

    // MARK: Actions
    /// Connect the detail screen's save button here.
    @IBAction func toggleSave(_ sender: Any) {
        SaveStore.shared.toggle(deal)   // posts notification -> everyone updates
        updateSaveButton()
    }

    @objc private func savesChanged() { updateSaveButton() }

    @objc private func closeTapped() { dismiss(animated: true) }
}
