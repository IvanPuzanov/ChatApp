//
//  ChannelDataSource.swift
//  ChatApp
//
//  Created by Ivan Puzanov on 10.04.2023.
//

import UIKit

final class ChannelsDataSource: UITableViewDiffableDataSource<Section, ChannelViewModel> {    
    // MARK: - Методы
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
