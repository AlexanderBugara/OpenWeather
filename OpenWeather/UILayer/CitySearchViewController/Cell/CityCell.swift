import UIKit

final class CityCell: UITableViewCell, ReusableView {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!

    // MARK: Init

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: Update model

    func update(model: City) {
        cityNameLabel.text = model.name
        countryNameLabel.text = model.country
    }
}
