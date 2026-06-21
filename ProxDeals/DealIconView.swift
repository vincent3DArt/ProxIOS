//
//  DealIconView.swift
//  ProxDeals
//
//  A small helper that renders a deal's SF Symbol into an existing
//  UIImageView, with a soft tinted circular background so each item
//  reads like a real product thumbnail. No image assets required.
//

import UIKit

enum DealIcon {

    /// The tint color for a deal, based on its category.
    static func tint(for deal: Deal) -> UIColor {
        let palette: [UIColor] = [
            .systemBlue,      // dairy
            .systemGreen,     // produce
            .systemOrange,    // bakery
            .systemRed,       // meat & seafood
            .systemBrown,     // pantry
            .systemPurple,    // beverages
            .systemTeal,      // frozen
            .systemYellow     // snacks
        ]
        let i = deal.categoryColorIndex
        return (i >= 0 && i < palette.count) ? palette[i] : .systemGray
    }

    /// Fills `imageView` with the deal's SF Symbol on a soft circular
    /// background tinted by category. Safe to call from cell `configure`.
    static func apply(to imageView: UIImageView?, for deal: Deal) {
        guard let imageView = imageView else { return }
        let color = tint(for: deal)

        // Configure the symbol at a readable weight/size.
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        let symbol = UIImage(systemName: deal.symbolName, withConfiguration: config)
            ?? UIImage(systemName: "bag.fill", withConfiguration: config)

        imageView.image = symbol
        imageView.tintColor = color
        imageView.contentMode = .center

        // Soft tinted circular background.
        imageView.backgroundColor = color.withAlphaComponent(0.15)
        imageView.layer.cornerRadius = min(imageView.bounds.width, imageView.bounds.height) / 2
        imageView.clipsToBounds = true
    }
}
