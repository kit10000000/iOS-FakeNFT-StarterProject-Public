//
//  CatalogViewController.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 12.10.2026.
//

import UIKit

final class CatalogViewController: UIViewController, CatalogView {
    
    private let presenter: CatalogPresenter
    private let tableView = UITableView()
    private var collections: [NftCollection] = []
    
    init(presenter: CatalogPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.constraintEdges(to: view)
        
        presenter.viewDidLoad()
    }
    
    func showCollections(_ collections: [NftCollection]) {
        self.collections = collections
        tableView.reloadData()
    }
}

extension CatalogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            UITableViewCell()
    }
}
