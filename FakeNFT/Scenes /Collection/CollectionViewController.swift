//
//  CollectionViewController.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import UIKit

final class CollectionViewController: UIViewController, CollectionView, LoadingView, ErrorView {

    private let presenter: CollectionPresenter
    private let servicesAssembly: ServicesAssembly
    private var headerModel: CollectionHeaderModel?
    private var nfts: [Nft] = []
    private var likedIds: Set<String> = []
    private var cartIds: Set<String> = []
    private var isGridEnabled = false
    private let sizingHeader = CollectionHeader(frame: .zero)
    private var laidOutWidth: CGFloat = 0

    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .ypBlackUniversal
        return indicator
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhiteUniversal
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeader.reuseIdentifier)
        collectionView.register(CollectionNftCell.self)
        return collectionView
    }()

    init(presenter: CollectionPresenter, servicesAssembly: ServicesAssembly) {
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
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .ypWhiteUniversal
        view.addSubview(collectionView)
        collectionView.constraintEdges(to: view)
        view.addSubview(activityIndicator)
        activityIndicator.constraintCenters(to: view)
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .ypBlackUniversal
        presenter.viewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottom = view.safeAreaInsets.bottom
        if collectionView.contentInset.bottom != bottom {
            collectionView.contentInset.bottom = bottom
        }
        let width = collectionView.bounds.width
        guard width > 0, width != laidOutWidth else { return }
        laidOutWidth = width
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func setGridInteractionEnabled(_ isEnabled: Bool) {
        isGridEnabled = isEnabled
    }

    func showCollection(_ header: CollectionHeaderModel) {
        headerModel = header
        collectionView.reloadData()
    }

    func showNfts(_ nfts: [Nft], likedIds: Set<String>, cartIds: Set<String>) {
        self.nfts = nfts
        self.likedIds = likedIds
        self.cartIds = cartIds
        collectionView.reloadData()
    }

    func openAuthorWebsite(_ url: URL) {
        let webViewController = AuthorWebViewController(url: url)
        webViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webViewController, animated: true)
    }

    func openNft(with id: String) {
        let assembly = NftDetailAssembly(servicesAssembler: servicesAssembly)
        let input = NftDetailInput(id: id)
        let nftViewController = assembly.build(with: input)
        present(nftViewController, animated: true)
    }
}

extension CollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        nfts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionNftCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let nft = nfts[indexPath.item]
        cell.configure(with: nft, isLiked: likedIds.contains(nft.id), isInCart: cartIds.contains(nft.id))
        cell.onLikeTap = { [weak self] in
            guard let self, self.isGridEnabled else { return }
            self.presenter.didTapLike(id: nft.id)
        }
        cell.onCartTap = { [weak self] in
            guard let self, self.isGridEnabled else { return }
            self.presenter.didTapCart(id: nft.id)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeader.reuseIdentifier, for: indexPath) as? CollectionHeader
        else {
            return UICollectionReusableView()
        }
        if let headerModel {
            header.configure(with: headerModel)
        }
        header.onAuthorTap = { [weak self] in
            self?.presenter.didTapAuthor()
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
        guard let headerModel else { return .zero }
        let width = collectionView.bounds.width
        guard width > 0 else { return .zero }
        sizingHeader.frame.size.width = width
        sizingHeader.setText(from: headerModel)
        let height = sizingHeader.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return CGSize(width: width, height: ceil(height))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9.5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let inset: CGFloat = 16
        let spacing: CGFloat = 9.5
        let width = collectionView.bounds.width
        let itemWidth = floor((width - inset * 2 - spacing * (columns - 1)) / columns)
        let itemHeight = itemWidth + 92
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard isGridEnabled else { return }
        presenter.didSelectNft(at: indexPath.item)
    }
}

