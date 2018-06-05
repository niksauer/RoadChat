//
//  FetchedResultsCollectionViewController.swift
//  RoadChat
//
//  Created by Niklas Sauer on 10.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsCollectionViewController<T: NSManagedObject>: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Public Properties
    var fetchedResultsController: NSFetchedResultsController<T>!
    
    // MARK: - Private Properties
    private var blockOperations = [BlockOperation]()
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: - FetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation {
                self.collectionView?.insertItems(at: [newIndexPath!])
            })
        case .delete:
            blockOperations.append(BlockOperation {
                self.collectionView?.deleteItems(at: [indexPath!])
            })
        case .update:
            blockOperations.append(BlockOperation {
                self.collectionView?.reloadItems(at: [indexPath!])
            })
        case .move:
            blockOperations.append(BlockOperation {
                self.collectionView?.moveItem(at: indexPath!, to: newIndexPath!)
            })
        }
    }
    
}
