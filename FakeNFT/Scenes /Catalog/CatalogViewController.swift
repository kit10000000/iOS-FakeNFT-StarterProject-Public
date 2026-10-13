//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit

final class CatalogViewController: UIViewController, CatalogView {
    
    private let presenter: CatalogPresenter
    private let servicesAssembly: ServicesAssembly
    private let tableView = UITableView()
    private var collections: [NftCollection] = []
    
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
        
        view.backgroundColor = .ypWhite
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CatalogCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 187
        tableView.backgroundColor = .ypWhite
        view.addSubview(tableView)
        tableView.constraintEdges(to: view)
        
        presenter.viewDidLoad()
    }
    
    func showCollections(_ collections: [NftCollection]) {
        self.collections = collections
        tableView.reloadData()
    }
    
    func openCollection(_ collection: NftCollection) {
        let viewController = CollectionAssembly(servicesAssembly: servicesAssembly).build(with: collection)
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
        presenter.didSelectCollection(at: indexPath.row)
    }
}
