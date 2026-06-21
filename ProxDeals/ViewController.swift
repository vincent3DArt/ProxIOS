//
//  ViewController.swift
//  ProxDeals
//
//  The Deals screen. Keeps your existing map + sliding panel layout
//  and adds: mock data loading, loading/empty/error states, search,
//  a draggable expandable panel, filtering, and navigation to detail.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,
                      UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // Var
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dealsView: UIView!          // the sliding panel
    @IBOutlet weak var dealsTableView: UITableView!

    // MARK: New outlets YOU will connect in the storyboard
    /// The top constraint of dealsView (panel) to the safe-area top.
    /// We animate its constant to expand/collapse the panel.
    @IBOutlet weak var panelTopConstraint: NSLayoutConstraint!
    /// The little grab handle at the top of the panel.
    @IBOutlet weak var panelHandle: UIView!
    /// The Filter button in the panel header.
    @IBOutlet weak var filterButton: UIButton!

    // MARK: Data
    private var allDeals: [Deal] = []      // everything loaded
    private var visibleDeals: [Deal] = []  // after search + filters
    private var searchText: String = ""
    private var filters = FilterOptions()

    // MARK: UI state
    private enum State { case loading, error(String), empty, loaded }
    private var state: State = .loading { didSet { renderState() } }

    /// Spinner shown while the mock API is "fetching".
    private let spinner = UIActivityIndicatorView(style: .large)
    /// A reusable message view for empty + error states.
    private let messageView = MessageView()

    // MARK: Panel drag positions (set in viewDidLayoutSubviews)
    private var collapsedTop: CGFloat = 300   // matches your storyboard constant
    private var expandedTop: CGFloat = 160    // just below the logo
    private var panelStartTop: CGFloat = 0    // used during a drag

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dealsTableView.dataSource = self
        dealsTableView.delegate = self
        dealsTableView.rowHeight = 131
        // Hide separators behind the overlay states for a cleaner look.
        dealsTableView.keyboardDismissMode = .onDrag

        // Find the search bar inside the panel (it has a delegate outlet to us
        // in the storyboard, but we also set it here defensively).
        if let search = findSearchBar(in: dealsView) { search.delegate = self }

        setupPanelHandle()
        setupOverlays()

        // Listen for save changes so the visible star buttons refresh
        // if a save happens on the detail screen.
        NotificationCenter.default.addObserver(
            self, selector: #selector(savesChanged),
            name: SaveStore.didChangeNotification, object: nil)

        loadDeals()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logo.layer.cornerRadius = logo.frame.width / 2
        logo.clipsToBounds = true
        logo.contentMode = .scaleAspectFill

        // Expanded = just below the logo.
        let logoBottom = logo.frame.maxY + 12
        if logoBottom > 0 { expandedTop = max(120, logoBottom) }

        // Collapsed = panel pulled down so only a short strip shows just above
        // the tab bar. The panel's top constraint is measured from the safe-area
        // top, so we take the safe-area height and leave a small visible strip.
        let safeHeight = view.bounds.height
            - view.safeAreaInsets.top
            - view.safeAreaInsets.bottom
        let visibleStrip: CGFloat = 90   // how much of the panel peeks above the tab bar
        let computedCollapsed = safeHeight - visibleStrip
        if computedCollapsed > expandedTop { collapsedTop = computedCollapsed }

        // Set the panel to its collapsed resting position once on first layout.
        if !didCaptureCollapsed, let c = panelTopConstraint {
            c.constant = collapsedTop
            didCaptureCollapsed = true
        }
    }
    private var didCaptureCollapsed = false

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: Loading
    private func loadDeals() {
        state = .loading
        DealsData.fetchDeals { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let deals):
                self.allDeals = deals
                self.applyFiltersAndSearch()
            case .empty:
                self.allDeals = []
                self.visibleDeals = []
                self.state = .empty
            case .failure(let message):
                self.state = .error(message)
            }
        }
    }

    /// Recomputes the visible list from search text + filters and
    /// chooses the right state (empty vs loaded).
    private func applyFiltersAndSearch() {
        var result = filters.apply(to: allDeals)
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.store.localizedCaseInsensitiveContains(searchText)
            }
        }
        visibleDeals = result
        state = visibleDeals.isEmpty ? .empty : .loaded
        dealsTableView.reloadData()
        updateFilterButtonTitle()
    }

    // MARK: State rendering
    //
    // We show loading / empty / error using the table's own `backgroundView`
    // instead of a separately-pinned overlay. The background view fills the
    // table automatically, so there are no extra Auto Layout constraints to
    // conflict when the list is empty. (Same pattern used on the Cart screen.)
    private func renderState() {
        switch state {
        case .loading:
            spinner.startAnimating()
            dealsTableView.backgroundView = spinner
            dealsTableView.separatorStyle = .none
        case .loaded:
            spinner.stopAnimating()
            dealsTableView.backgroundView = nil
            dealsTableView.separatorStyle = .singleLine
        case .empty:
            spinner.stopAnimating()
            messageView.configure(
                title: "No deals found",
                message: searchText.isEmpty && filters.isEmpty
                    ? "There are no deals to show right now."
                    : "Try clearing your search or filters.",
                buttonTitle: filters.isEmpty ? nil : "Clear filters"
            ) { [weak self] in
                self?.filters = FilterOptions()
                self?.applyFiltersAndSearch()
            }
            dealsTableView.backgroundView = messageView
            dealsTableView.separatorStyle = .none
        case .error(let msg):
            spinner.stopAnimating()
            messageView.configure(title: "Something went wrong",
                                  message: msg,
                                  buttonTitle: "Retry") { [weak self] in
                self?.loadDeals()
            }
            dealsTableView.backgroundView = messageView
            dealsTableView.separatorStyle = .none
        }
    }

    private func setupOverlays() {
        // The spinner is centered automatically when used as a backgroundView.
        spinner.hidesWhenStopped = true
        // No manual constraints needed; backgroundView handles sizing/centering.
    }

    // MARK: Table data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleDeals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseID,
                                                 for: indexPath) as! DealCell
        cell.configure(with: visibleDeals[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let deal = visibleDeals[indexPath.row]
        // Push the detail screen from the storyboard (Storyboard ID: "DetailViewController").
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let detail = sb.instantiateViewController(withIdentifier: "DetailViewController")
            as? DetailViewController {
            detail.deal = deal
            detail.modalPresentationStyle = .automatic
            present(UINavigationController(rootViewController: detail), animated: true)
        }
    }

    // MARK: Search
    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        searchText = text
        applyFiltersAndSearch()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    @IBAction func enterButton(_ sender: Any) {
        if let s = findSearchBar(in: dealsView) {
            searchText = s.text ?? ""
            s.resignFirstResponder()
            applyFiltersAndSearch()
        }
    }

    // Locate button intentionally left as a no-op for now (per the brief).
    @IBAction func locateButton(_ sender: Any) { }

    // MARK: Filter
    /// Connect the Filter button's Touch Up Inside to this.
    @IBAction func openFilter(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let filterVC = sb.instantiateViewController(withIdentifier: "FilterViewController")
            as? FilterViewController else { return }
        filterVC.allDeals = allDeals
        filterVC.current = filters
        filterVC.onApply = { [weak self] newFilters in
            self?.filters = newFilters
            self?.applyFiltersAndSearch()
        }
        present(UINavigationController(rootViewController: filterVC), animated: true)
    }

    private func updateFilterButtonTitle() {
        // Show a count badge in the button title when filters are active.
        let activeCount = filters.stores.count + filters.dealTypes.count
            + filters.categories.count
            + (filters.maxPrice != nil ? 1 : 0)
            + (filters.maxDistance != nil ? 1 : 0)
        let title = activeCount > 0 ? "Filter (\(activeCount))" : "Filter"
        filterButton?.setTitle(title, for: .normal)
    }

    // MARK: Saves changed
    @objc private func savesChanged() {
        // Refresh visible star buttons without a full reload flicker.
        for case let cell as DealCell in dealsTableView.visibleCells {
            cell.updateSaveButton()
        }
    }

    // MARK: Expandable panel
    private func setupPanelHandle() {
        // If the handle outlet is connected, give it a rounded pill look.
        panelHandle?.backgroundColor = .systemGray3
        panelHandle?.layer.cornerRadius = 3

        // Attach the pan gesture to the handle if present, else the panel top.
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        (panelHandle ?? dealsView)?.addGestureRecognizer(pan)
        (panelHandle ?? dealsView)?.isUserInteractionEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Panel positions are computed in viewDidLayoutSubviews once the
        // logo and panel have real frames.
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let top = panelTopConstraint else { return }
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began:
            panelStartTop = top.constant
        case .changed:
            // Dragging up (negative y) decreases the top constant (panel grows);
            // dragging down increases it (panel shrinks toward the tab bar).
            var newTop = panelStartTop + translation.y
            newTop = min(max(newTop, expandedTop), collapsedTop)   // clamp to range
            top.constant = newTop
        case .ended, .cancelled:
            // No snapping: leave the panel wherever the user released it,
            // just keep it within the allowed range.
            top.constant = min(max(top.constant, expandedTop), collapsedTop)
        default: break
        }
    }

    // MARK: Helpers
    /// Recursively finds the first UISearchBar inside a view tree.
    private func findSearchBar(in root: UIView?) -> UISearchBar? {
        guard let root = root else { return nil }
        if let sb = root as? UISearchBar { return sb }
        for sub in root.subviews {
            if let found = findSearchBar(in: sub) { return found }
        }
        return nil
    }
}
