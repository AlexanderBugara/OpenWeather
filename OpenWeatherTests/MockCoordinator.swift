import XCTest
@testable import OpenWeather

final class MockCoordinator: RootCoordinating {
    var rootViewModel: RootViewModeling?
    var data: TransferData?

    func update(data: TransferData?) {
    }

    var isBack: Bool = false

    var nextCoordinator: Coordinating?

    var previousCoordinator: Coordinating?

    func setup() {

    }

    func next() {

    }

    func back(data: TransferData?) {
        self.data = data
        isBack = true
    }
}
