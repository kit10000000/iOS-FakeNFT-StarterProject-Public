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
    private let sizingHeader = CollectionHeader(frame: .zero)
    private var laidOutWidth: CGFloat = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CollectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionHeader.reuseIdentifier
        )
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = collectionView.bounds.width
        guard width > 0, width != laidOutWidth else { return }
        laidOutWidth = width
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func showCollection(_ collection: NftCollection) {
        self.collection = collection
        collectionView.reloadData()
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeader.reuseIdentifier, for: indexPath) as? CollectionHeader else {
            return UICollectionReusableView()
        }
        if let collection {
            header.configure(with: collection)
        }
        return header
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard let collection else { return .zero }
        let width = collectionView.bounds.width
        guard width > 0 else { return .zero }
        sizingHeader.frame.size.width = width
        sizingHeader.configure(with: collection)
        let height = sizingHeader.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return CGSize(width: width, height: ceil(height))
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9.5
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns: CGFloat = 3
        let inset: CGFloat = 16
        let spacing: CGFloat = 9.5
        let width = collectionView.bounds.width
        let itemWidth = floor((width - inset * 2 - spacing * (columns - 1)) / columns)
        let itemHeight = itemWidth + 92
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

