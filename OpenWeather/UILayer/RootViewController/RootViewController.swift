import UIKit

typealias Day = [CellModel]
typealias SourceSnapshot = NSDiffableDataSourceSnapshot<Int, CellModel>
typealias DataSource = UICollectionViewDiffableDataSource<Int, CellModel>

final class RootViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectYourCityLabel: UILabel!

    private var dataSource: DataSource?
    private(set) var viewModel: RootViewModeling

    // MARK: Init
    /// Initialization RootViewController
    /// - Parameter viewModel: RootViewModeling uses as part of MVVM
    init(viewModel: RootViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions
    /// This is UI button action which is presenting cities list view controller
    /// Action delegate to viewModel
    @objc
    func selectCity(_ sender: Any) {
        viewModel.presentCityPicker()
    }

    // MARK: View lifesircle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: Setup UI

    private func setupUI() {
        let selectCityButton = UIBarButtonItem(title: Consts.kCity, style: .plain, target: self, action: #selector(selectCity(_:)))

        navigationItem.rightBarButtonItem = selectCityButton

        configureSegmntedControl()
        configureCollectionView()
        configureDataSource()
    }

    private func configureSegmntedControl() {
        let segmentedControl = UISegmentedControl(items: [Consts.kOnline, Consts.kOffline])
        segmentedControl.addTarget(self, action: #selector(segmentedControlAction(sender:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentedControl
    }

    // MARK: Collection View

    private func configureCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        let nib = UINib(nibName: WeatherCell.reusableIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: WeatherCell.reusableIdentifier)
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5.0, bottom: 5.0, trailing: 5.0)

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .absolute(300)), subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5.0, leading: 5.0, bottom: 5.0, trailing: 5.0)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        return layout
    }

    private func configureDataSource() {
      dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, model: CellModel) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCell.reusableIdentifier, for: indexPath) as? WeatherCell else { fatalError("Could not create new cell") }

            cell.update(model: model)
            return cell
      }
    }

    func makeSnapshot(sections: [Day]) -> NSDiffableDataSourceSnapshot<Int, CellModel> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellModel>()
        let sectionsIndexes = Array(0..<sections.count)
        snapshot.appendSections(sectionsIndexes)
        for sectionIndex in sectionsIndexes {
            snapshot.appendItems(sections[sectionIndex], toSection: sectionIndex)
        }
        return snapshot
    }

    // MARK: Segmented Action
    /// Segmnted action which is calling switch state online/offline from view model
    /// - Parameters sender: UISegmentedControl
    @objc
    private func segmentedControlAction(sender: UISegmentedControl) {
        viewModel.switchState()
    }
}

// MARK: RootViewModelDelegate

extension RootViewController: RootViewModelDelegate {
    func forecastDidLoad(items: [Day]) {
        let snapshot = makeSnapshot(sections: items)
        dataSource?.apply(snapshot)
    }

    /// depends on data collection data source label is hiding or showing
    func welcomeLabel(isHidden: Bool) {
        selectYourCityLabel.isHidden = isHidden
    }

    /// presenting loader
    func loading(isPresented: Bool) {
        if isPresented {
            let loadingViewController = LoadingViewController()
            loadingViewController.modalPresentationStyle = .overCurrentContext
            navigationController?.present(loadingViewController, animated: false)
        } else {
            navigationController?.dismiss(animated: false)
        }
    }

    /// changes city button title to selected city name
    func updateCityButton(city: City?) {
        guard let city = city else {
            return
        }
        self.navigationItem.rightBarButtonItem?.title = city.name
    }

    /// presents error alert if some thing heppend in fetching process 
    func show(error: FetcherError) {
        let title: String?
        let message: String?

        switch error {
        case .sessionError(let sessionError):
            title = sessionError.title
            message = sessionError.errorDescription
        case .URLWasNotBuild:
            title = NSLocalizedString(Consts.Error, comment: "")
            message = NSLocalizedString(Consts.Alert.URLErrorMessage, comment: "")
        case .decoderError:
            title = NSLocalizedString(Consts.Error, comment: "")
            message = NSLocalizedString(Consts.Alert.decoderErrorMessage, comment: "")
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(Consts.Alert.Ok, comment: ""), style: .default, handler: {_ in
            alert.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }


    /// This is uses for checking if collection datasource is empty to show or hide welcome label on center screen
    var isCollectionEmpty: Bool {
        guard let count = dataSource?.snapshot().numberOfItems, count > 0 else {
            return true
        }
        return false
    }

    /// For offline state select city is disabled on UI for online state button is anabling
    func cityButton(isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
}
