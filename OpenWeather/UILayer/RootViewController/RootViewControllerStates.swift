//
//  RootViewControllerStates.swift
//  OpenWeather
//
//  Created by Oleksandr Buhara on 2/24/20.
//  Copyright © 2020 Oleksandr Buhara. All rights reserved.
//

import UIKit

// MARK: State protocol

protocol State: AnyObject {
    func update(context: RootContext)
    var selectCityButton: Bool? { get }
    var selectYourCityLabel: Bool? { get }
    var city: City? { get }
    var isLoadable: Bool { get }
    var isNeedSaveCityName: Bool { get }
    func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void)
    func update(city: City)
    func error()
}

// MARK: Parent class State

class BaseState: State {
    private(set) weak var context: RootContext?
    let snapshotContext: RootSnapshotContext

    func update(context: RootContext) {
        self.context = context
    }
    var selectCityButton: Bool? { nil }
    var selectYourCityLabel: Bool? { nil }
    var city: City? { nil }
    var isLoadable: Bool { false }
    var isNeedSaveCityName: Bool { false }
    func update(city: City) {}
    init(snapshotContext: RootSnapshotContext) {
        self.snapshotContext = snapshotContext
    }

    func makeSnapshot(sections: [RootViewController.SectionViewModel]) -> NSDiffableDataSourceSnapshot<RootViewController.SectionViewModel, RootViewController.CellViewModel> {
        var snapshot = NSDiffableDataSourceSnapshot<RootViewController.SectionViewModel, RootViewController.CellViewModel>()
        snapshot.appendSections(sections)
        for section in sections { snapshot.appendItems(section.items, toSection: section) }
        return snapshot
    }

    func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void) {}
    func error() {}
}

// MARK: - RootContext -

//Context for all RootViewController states
class RootContext {
    private var state: State

    init(_ state: State) {
        self.state = state
        transitionTo(state: state)
    }

    func transitionTo(state: State) {
        self.state = state
        self.state.update(context: self)
    }

    var selectCityButton: Bool { state.selectCityButton ?? false }
    var selectYourCityLabel: Bool { state.selectYourCityLabel ?? false }
    var city: City? { state.city }
    var isLoadable: Bool { state.isLoadable }
    var isNeedSaveCityName: Bool { state.isNeedSaveCityName }

    func update(city: City) { state.update(city: city) }
    func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void) {
        state.fetch(completetion: completetion)
    }
    func error() { state.error() }
}

// MARK: - OnlineEmptyState -

// Init state with empty snapshot
final class OnlineEmptyState: BaseState {
    override var selectCityButton: Bool? { true }
    override var selectYourCityLabel: Bool? { true }
    override var city: City? { nil }
    override func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void) {
        completetion(.success(nil))
    }
}

// MARK: - OnlineState -

// Online state without selecting new city
final class OnlineState: BaseState {
    private var _city: City?
    override var selectCityButton: Bool? { true }
    override var selectYourCityLabel: Bool? { false }
    override var city: City? { _city }

    override func update(city: City) { _city = city }
    override func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void) {
        if self.snapshotContext.isExistSnapshot(for: .online) {
            self.snapshotContext.switch(state: .online)
            completetion(.success(self.snapshotContext.snapshot))
        }
    }

    override func update(context: RootContext) {
        super.update(context: context)
        if !self.snapshotContext.isExistSnapshot(for: .online) { context.transitionTo(state: OnlineEmptyState(snapshotContext: snapshotContext)) }
    }
}

// MARK: - OnlineLoadingState -

// Online state with fetching from internet
final class OnlineLoadingState: BaseState {
    private var _city: City?
    private let dataProvider = OnlineForecastProvider()
    override var selectCityButton: Bool? { true }
    override var selectYourCityLabel: Bool? { false }
    override var city: City? { _city }
    override var isLoadable: Bool { true }
    override var isNeedSaveCityName: Bool { true }

    override func update(city: City) { _city = city }
    override func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void) {
        guard let city = city, !city.name.isEmpty else {
            self.snapshotContext.switch(state: .online)
            completetion(.success(self.snapshotContext.snapshot))
            return
        }

        let resourse: Resource
        if let cityId = city.cityId {
            resourse = WeatherAPI.Forecast5dInterval3hById(cityId: cityId)
        } else {
            resourse = WeatherAPI.Forecast5dInterval3hByName(cityName: city.name)
        }

        dataProvider.fetch(network: resourse) { result in
            switch result {
            case .success(let sections):
                let snapshot = self.makeSnapshot(sections: sections)
                self.snapshotContext.save(snapshot: snapshot, for: .online)
                completetion(.success(snapshot))
            case .failure(let error): completetion(.failure(error))
            }
        }
    }
    override func error() {
        context?.transitionTo(state: OnlineState(snapshotContext: snapshotContext))
    }

}

// MARK: - OfflineState -

// offline state for defaukt city: Munich - could be changed in Consts
final class OfflineState: BaseState {
    private let dataProvider = OfflineForecastProvider()
    override var selectCityButton: Bool? { false }
    override var selectYourCityLabel: Bool? { false }
    override var city: City? { return City(name: Consts.kDefaultOfflineCity) }


    override func fetch(completetion: @escaping (Result<RootSnapshotContext.Snapshot?, Error>) -> Void) {
        if self.snapshotContext.isExistSnapshot(for: .offline) {
            self.snapshotContext.switch(state: .offline)
            completetion(.success(self.snapshotContext.snapshot))
        } else {
            guard let city = city else {
                completetion(.success(nil))
                return
            }
            dataProvider.fetch(city: city) { result in
                switch result {
                case .success(let sections):
                    let snapshot = self.makeSnapshot(sections: sections)
                    self.snapshotContext.save(snapshot: snapshot, for: .offline)
                    completetion(.success(snapshot))
                case .failure(let error): completetion(.failure(error))
                }
            }
        }
    }
}
