//
//  AppBuilderCoordinator.swift
//  OpenWeather
//
//  Created by Oleksandr Buhara on 2/20/20.
//  Copyright © 2020 Oleksandr Buhara. All rights reserved.
//

import Foundation

protocol Builder {
    associatedtype T
    func build()
    func retrieve() -> T
}

final class RootBuilder: Builder {
    var rootContext: RootContext?
    var rootSnapshotContext: RootSnapshotContext?
    var coordinator: AnyCoordinator<RootCoordintor.Next, RootCoordintor.Back>?
    private var rootViewController: RootViewController?

    func build() {
        guard let rootContext = self.rootContext, let snapshotContext = self.rootSnapshotContext, let coordinator = self.coordinator else { return }
        rootViewController = RootViewController(context: rootContext, snapshotContext: snapshotContext, coordinator: coordinator)
    }
    func retrieve() -> RootViewController? { rootViewController }
}

class RootDirector {
    private var builder: RootBuilder?
    var rootContext: RootContext
    var rootSnapshotContext: RootSnapshotContext
    var coordinator: AnyCoordinator<RootCoordintor.Next, RootCoordintor.Back>

    init(rootContext: RootContext, rootSnapshotContext: RootSnapshotContext, coordinator: AnyCoordinator<RootCoordintor.Next, RootCoordintor.Back>) {
        self.rootContext = rootContext
        self.rootSnapshotContext = rootSnapshotContext
        self.coordinator = coordinator
    }

    func update(builder: RootBuilder) {
        builder.rootContext = rootContext
        builder.rootSnapshotContext = rootSnapshotContext
        builder.coordinator = coordinator
        self.builder = builder
    }

    func buildRoot() {
        builder?.build()
    }
}
