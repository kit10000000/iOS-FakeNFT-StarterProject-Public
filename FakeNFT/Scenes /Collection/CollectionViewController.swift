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
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhite
        collectionView.dataSource = self
        return collectionView
    }()
    
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
        view.addSubview(collectionView)
        collectionView.constraintEdges(to: view)
        presenter.viewDidLoad()
    }
    
    func showCollection(_ collection: NftCollection) {
        self.collection = collection
    }
}

extension CollectionViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}

