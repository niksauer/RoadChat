//
//  CarsCollectionViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 13.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class CarsViewController: FetchedResultsCollectionViewController<Car>, UICollectionViewDelegateFlowLayout, CreateNewCellDelegate {
   
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let owner: User
    private let activeUser: User
    private let searchContext: NSManagedObjectContext
    private let colorPalette: ColorPalette
    private let cellDateFormatter: DateFormatter
    
    private let reuseIdentifier = "CarCell"
    private var sizingCell: CarCell!
    
    private var refreshControl: UIRefreshControl?
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, owner: User, activeUser: User, searchContext: NSManagedObjectContext, colorPalette: ColorPalette, cellDateFormatter: DateFormatter) {
        self.viewFactory = viewFactory
        self.owner = owner
        self.activeUser = activeUser
        self.searchContext = searchContext
        self.colorPalette = colorPalette
        self.cellDateFormatter = cellDateFormatter
        
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
        
        self.title = "Car"
        
        layout.headerReferenceSize = CGSize.zero
        
        if activeUser.id == owner.id {
            layout.footerReferenceSize = CGSize(width: collectionView!.frame.width, height: 50)
        }
        
        collectionView?.backgroundColor = colorPalette.backgroundColor
        collectionView?.alwaysBounceVertical = true
        
        sizingCell = {
            let nib = Bundle.main.loadNibNamed(reuseIdentifier, owner: self, options: nil)
            let sizingCell = nib?.first as! CarCell
            return sizingCell
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        super.viewDidLoad()

        // register cell classes
        self.collectionView!.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        if activeUser.id == owner.id {
            self.collectionView!.register(UINib(nibName: "CreateNewCellView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "CreateNewCellView")
        }
    
        // pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl?.layer.zPosition = -1
        refreshControl?.addTarget(self, action: #selector(updateData), for: .valueChanged)
        self.collectionView?.addSubview(refreshControl!)
        
        // aditional view setup
        owner.getCars(completion: nil)
        updateUI()
    }
    
    // MARK: - Private Methods
    @objc private func updateData() {
        owner.getCars { _ in
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func updateUI() {
        let request: NSFetchRequest<Car> = Car.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "userID = %d", owner.id)
        
        fetchedResultsController = NSFetchedResultsController<Car>(fetchRequest: request, managedObjectContext: searchContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
        collectionView?.reloadData()
    }
    
    // MARK: - Private Methods
    func didPressAddButton(_ sender: CreateNewCellView) {
        let createCarViewController = viewFactory.makeCreateCarViewController(for: owner)
        let createCarNavigationController = UINavigationController(rootViewController: createCarViewController)
        present(createCarNavigationController, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let car = fetchedResultsController!.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CarCell
        cell.configure(car: car, dateFormatter: cellDateFormatter)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // item for which size should be calculated
        let car = fetchedResultsController!.object(at: indexPath)
        
        // width cell should use
        let width = collectionView.frame.width
        
        // configure sizing cell
        sizingCell.configure(car: car, dateFormatter: cellDateFormatter)
        
        // calculate size based on sizing cell
        return sizingCell.preferredLayoutSizeFittingWidth(width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CreateNewCellView", for: indexPath) as! CreateNewCellView
            footer.configure(text: "Car", colorPalette: colorPalette)
            footer.delegate = self
            return footer
        default:
            // unintentionally registered
            fatalError()
        }
    }

    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let car = fetchedResultsController!.object(at: indexPath)
        let carDetailViewController = viewFactory.makeCarDetailViewController(for: car, activeUser: activeUser)
        let carDetailNavigationController = UINavigationController(rootViewController: carDetailViewController)
        self.navigationController?.present(carDetailNavigationController, animated: true, completion: nil)
    }
    
}
