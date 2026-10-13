//
//  CollectionViewController.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import UIKit

final class CollectionViewController: UIViewController, CollectionView {
    
    private let presenter: CollectionPresenter
    private var collection: NftCollection?
    
    init(presenter: CollectionPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        presenter.viewDidLoad()
    }
    
    func showCollection(_ collection: NftCollection) {
        self.collection = collection
    }
}

