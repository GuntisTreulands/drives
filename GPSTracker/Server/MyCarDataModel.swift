
import Foundation

struct MyCarDataModel : Codable {
	let costs : [Double]?
	let valueDrop : [Double]?

	enum CodingKeys: String, CodingKey {

		case costs = "costs"
		case valueDrop = "valueDrop"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		costs = try values.decodeIfPresent([Double].self, forKey: .costs)
		valueDrop = try values.decodeIfPresent([Double].self, forKey: .valueDrop)
	}

}
