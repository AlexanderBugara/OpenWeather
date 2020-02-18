import UIKit

final class TableCellLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        var intristicContentSize = super.intrinsicContentSize
        intristicContentSize.height = 44
        return intristicContentSize
    }
}
