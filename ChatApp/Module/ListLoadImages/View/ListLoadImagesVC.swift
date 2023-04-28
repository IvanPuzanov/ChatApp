//
//  ListLoadImagesVC.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 25.04.2023.
//

import UIKit
import Combine

final class ListLoadImagesVC: UIViewController {
    // MARK: - Параметры
    
    private var viewModel = ListLoadImagesViewModel()
    private var dataSource: UICollectionViewDiffableDataSource<Section, ImageModel>?
    private var layout: UICollectionViewCompositionalLayout?
    
    // MARK: - Combine
    
    private var input = PassthroughSubject<ListLoadImagesViewModel.Input, Never>()
    public var imagePickerSubject = PassthroughSubject<(UIImage, String), Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private var cancelButton        = UIBarButtonItem()
    private var collectionView      = UICollectionView(frame: .zero, collectionViewLayout: .init())
    private var activityIndicator   = UIActivityIndicatorView(style: .large)
}

extension ListLoadImagesVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        configure()
        configureNavigationBar()
        configureCollectionView()
        configureActivityIndicator()
        configureDataSource()
        configureLayout()
        isActivityIndactorAnimating(true)
        
        input.send(.fetchImagesList)
    }
}

private extension ListLoadImagesVC {
    func bindViewModel() {
        let output = viewModel.transform(input.eraseToAnyPublisher())
        
        output.sink { [weak self] event in
            switch event {
            case .imagesListFetchingSucceeded(let images):
                self?.isActivityIndactorAnimating(false)
                self?.update(with: images)
            case .errorOccured:
                break
            }
        }.store(in: &disposeBag)
    }
    
    func update(with images: [ImageModel]?) {
        guard let images else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, ImageModel>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(images, toSection: .main)
        
        DispatchQueue.main.async {
            self.dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
    
    @objc
    func buttonTapped(sender: UIControl) {
        switch sender {
        case cancelButton:
            dismiss(animated: true)
        default:
            break
        }
    }
    
    func isActivityIndactorAnimating(_ value: Bool) {
        DispatchQueue.main.async { [weak self] in
            switch value {
            case true:
                self?.activityIndicator.startAnimating()
                self?.activityIndicator.isHidden = false
            case false:
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
        }
    }
}

private extension ListLoadImagesVC {
    func configure() {
        self.view.backgroundColor = .systemBackground
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = Project.Title.selectPhoto
        
        cancelButton = UIBarButtonItem(title: Project.Button.cancel, style: .plain, target: self, action: #selector(buttonTapped))
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
    }
    
    func configureCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.delegate = self
        collectionView.register(ImageCVCell.self, forCellWithReuseIdentifier: ImageCVCell.id)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureActivityIndicator() {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    func configureDataSource() {
        typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageModel>
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCVCell.id, for: indexPath) as? ImageCVCell
            cell?.configure(with: itemIdentifier)
            return cell
        })
    }
    
    func configureLayout() {
        layout = UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
            let multiplier: CGFloat = 1 / 3
            let spacing: CGFloat    = 1
            
            let itemSize    = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item        = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize   = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(multiplier))
            let group       = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            group.interItemSpacing = .fixed(spacing)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            
            return section
        })
        
        guard let layout else { return }
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
}

extension ListLoadImagesVC {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offSetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height
    
        if offSetY > contentHeight - height {
            self.isActivityIndactorAnimating(true)
            self.input.send(.fetchMoreImages)
        }
    }
}

extension ListLoadImagesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? ImageCVCell,
            let image = cell.image,
            let imageLink = cell.imageModel?.urls?.regular
        else { return }
        
        dismiss(animated: true)
        imagePickerSubject.send((image, imageLink))
        
    }
}
