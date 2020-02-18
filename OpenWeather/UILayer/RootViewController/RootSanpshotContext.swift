//
//  RootSanpshotContext.swift
//  OpenWeather
//
//  Created by Oleksandr Buhara on 2/23/20.
//  Copyright © 2020 Oleksandr Buhara. All rights reserved.
//

import UIKit

final class RootSnapshotContext {
    enum State {
        case online
        case offline
    }

    typealias Snapshot = NSDiffableDataSourceSnapshot<RootViewController.SectionViewModel, RootViewController.CellViewModel>
    private var state: State = .online
    private var onlineSnapshot: Snapshot?
    private var offlineSnapshot: Snapshot?
    private(set) var snapshot: Snapshot?

    func save(snapshot: NSDiffableDataSourceSnapshot<RootViewController.SectionViewModel, RootViewController.CellViewModel>, for state: State) {
        switch state {
        case .online: onlineSnapshot = snapshot
        case .offline: offlineSnapshot = snapshot
        }
    }

    func isExistSnapshot(for state: State) -> Bool {
        switch state {
        case .online: return onlineSnapshot != nil
        case .offline: return offlineSnapshot != nil
        }
    }

    func `switch`(state: State) {
        self.state = state
        switch state {
        case .online: snapshot = onlineSnapshot
        case .offline: snapshot = offlineSnapshot
        }
    }
}
