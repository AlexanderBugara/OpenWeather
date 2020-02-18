import UIKit

final class CitiesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private let viewModel: CitiesListViewModeling
    private var cities = [City]()

    // MARK: Init

    init(viewModel: CitiesListViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecircle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        searchBar.becomeFirstResponder()
    }

    // MARK: Setup

    private func setupUI() {
        navigationItem.title = NSLocalizedString(Consts.kSelectYourCity, comment: "")

        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = closeButton

        let submitButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = submitButton

        disableDoneButton(flag: true)

        tableView.register(UINib(nibName: CityCell.reusableIdentifier, bundle: nil), forCellReuseIdentifier: CityCell.reusableIdentifier)
    }

    // MARK: Actions

    @objc
    private func close() {
        viewModel.close()
    }

    @objc
    private func done() {
        viewModel.done()
    }
}

// MARK: Extension UISearchBarDelegate

extension CitiesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(cityName: searchText)
    }
}

// MARK: Extension UITableViewDataSource

extension CitiesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.reusableIdentifier, for: indexPath) as? CityCell else { return UITableViewCell() }
        let city = cities[indexPath.row]
        cell.update(model: city)
        return cell
    }
}

// MARK: Extension UITableViewDelegate

extension CitiesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.select(city: cities[indexPath.row])
    }
}

// MARK: Extension CitiesListViewModelDelegate

extension CitiesListViewController: CitiesListViewModelDelegate {
    func show(error: Error) {
        let alert = UIAlertController(title: Consts.Error, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(Consts.Alert.Ok, comment: ""), style: .default, handler: {_ in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }

    func update(cities: [City]) {
        self.cities = cities
        tableView.reloadData()
    }

    func clean() {
        cities.removeAll()
        tableView.reloadData()
    }

    func disableDoneButton(flag: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = !flag
    }
}
