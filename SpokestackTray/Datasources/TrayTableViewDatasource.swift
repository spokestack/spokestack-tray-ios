//
//  TrayTableViewDatasource.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/11/20.
//

import Foundation
import UIKit

final class TrayTableViewDatasource: NSObject {
    
    // MARK: Internal (properties)
    
    weak var tableView: UITableView? {
        
        didSet {
            
            tableView?.dataSource = self
            tableView?.delegate = self
        }
    }
    
    private (set) var messages: Array<TrayMessage> = []
    
    // MARK: Internal (methods)
    
    func add(_ message: TrayMessage) -> Void {
        
        guard let tableView: UITableView = self.tableView else {
            return
        }
        
        if self.messages.isEmpty {
            
            self.messages.append(message)
            self.tableView?.reloadData()
            return
        }
        
        var insertedIndexPaths: Array<IndexPath> = []
        
        let index: Int = self.messages.count
        let indexPath: IndexPath = IndexPath(row: index, section: 0)

        self.messages.insert(message, at: index)

        insertedIndexPaths.append(indexPath)

        UIView.performWithoutAnimation {

            tableView.performBatchUpdates({

                tableView.insertRows(at: insertedIndexPaths, with: .bottom)

            }, completion: {completed in
                
                if completed {
                    tableView.spsk_scrollToBottomRow()
                }
            })
        }
    }
    
    func add(_ messages: Array<TrayMessage>) -> Void {
        
        /// If there aren't any messages then add them
        /// If there are then add them to the beginning
        
        guard let tableView: UITableView = self.tableView else {
            return
        }

        var indexPaths: Array<IndexPath> = []

        messages.forEach{message in

            self.messages.append(message)

            let index: Int = self.messages.count - 1
            let indexPath: IndexPath = IndexPath(row: index, section: 0)

            indexPaths.append(indexPath)
        }

        UIView.performWithoutAnimation {
    
            tableView.performBatchUpdates({

                tableView.insertRows(at: indexPaths, with: .bottom)

            }, completion: {completed in
                
                if completed {
                    tableView.spsk_scrollToBottomRow()
                }
            })
        }
    }
}

extension TrayTableViewDatasource: UITableViewDelegate, UITableViewDataSource {
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row: Int = indexPath.row
        let message: TrayMessage = self.messages[row]

        let cell: TrayTableViewCell = tableView.dequeueReusableCell(withIdentifier: TrayTableViewCell.reuseIdentifier,
                                                                                 for: indexPath) as! TrayTableViewCell
        cell.message = message

        return cell
    }
}
