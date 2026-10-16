//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit

final class CatalogViewController: UIViewController, CatalogView, LoadingView, ErrorView {

    private let presenter: CatalogPresenter
    private let servicesAssembly: ServicesAssembly
    private let tableView = UITableView()
    private var collections: [NftCollection] = []

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .ypBlackUniversal
        return indicator
    }()

    init(presenter: CatalogPresenter, servicesAssembly: ServicesAssembly) {
        self.presenter = presenter
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonDisplayMode = .minimal
        title = nil
        navigationItem.title = ""
        navigationItem.rightBarButtonItem = sortButton
        overrideUserInterfaceStyle = .light
        navigationController?.overrideUserInterfaceStyle = .light
        view.backgroundColor = .ypWhiteUniversal
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CatalogCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 187
        tableView.backgroundColor = .ypWhiteUniversal
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.constraintEdges(to: view)
        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)

        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    private var sortButton: UIBarButtonItem {
        let image = UIImage(systemName: "line.3.horizontal", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(sortButtonTapped))
        button.tintColor = .ypBlackUniversal
        return button
    }

    @objc private func sortButtonTapped() {
        let sheet = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.presenter.sortByName()
        })
        sheet.addAction(UIAlertAction(title: "По количеству NFT", style: .default) { [weak self] _ in
            self?.presenter.sortByNftCount()
        })
        sheet.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(sheet, animated: true)
    }

    func setInteractionEnabled(_ isEnabled: Bool) {
        tableView.isUserInteractionEnabled = isEnabled
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }

    func showCollections(_ collections: [NftCollection]) {
        self.collections = collections
        tableView.reloadData()
    }

    func openCollection(_ collection: NftCollection, nfts: [Nft]) {
        let viewController = CollectionAssembly(servicesAssembly: servicesAssembly).build(with: collection, nfts: nfts)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CatalogCell = tableView.dequeueReusableCell()
        cell.configure(with: collections[indexPath.row])
        return cell
    }
}

extension CatalogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectCollection(at: indexPath.row)
    }
}
