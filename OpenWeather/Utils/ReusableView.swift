protocol ReusableView {
    static var reusableIdentifier: String { get }
}

extension ReusableView {
    static var reusableIdentifier: String {
        return String(describing: self)
    }
}
