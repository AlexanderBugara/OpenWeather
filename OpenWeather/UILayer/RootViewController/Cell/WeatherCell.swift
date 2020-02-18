import UIKit

class WeatherCell: UICollectionViewCell, ReusableView {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func update(model: CellModel) {
        temperatureLabel.text = model.temperatureCelsiumString
        timeLabel.text = model.time
        dateLabel.text = model.date
        guard let iconName = model.iconName else { return }
        iconImageView.image = UIImage(named: iconName)
    }
}
