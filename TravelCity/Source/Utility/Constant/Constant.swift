//
//  Constant.swift
//  SeSAC-Mission-Day10-CollectionView
//
//  Created by 원태영 on 1/9/24.
//

import Foundation

enum Constant {
  enum Symbol {
    static let ellipsis: String = "ellipsis"
    static let photo: String = "photo"
    static let heart: String = "heart"
    static let heartFill: String = "heart.fill"
    static let starFill: String = "star.fill"
    static let starLeadinghalfFilled: String = "star.leadinghalf.filled"
    static let xmark: String = "xmark"
  }
  
  enum Label {
    static let headerTitle: String = "인기 도시"
    static let cityDetailInfoTitle: String = "도시 상세 정보"
    static let travelDetailTitle: String = "관광지 화면"
    static let adTitle: String = "광고 화면"
    static let searchingCityPlaceholder: String = "도시를 입력하세요"
  }
  
  enum CollectionView {
    static let spacing: CGFloat = 24
    static let cellCount: Int = 2
    static let cellLabelFreeSpace: CGFloat = 75
  }
  
  enum Storyboard {
    static let travel: String = "Travel"
  }
  
  enum Identifier {
    static let cityCollectionViewCell: String = "CityCollectionViewCell"
    static let travelViewController: String = "TravelViewController"
    static let travelDetailViewController: String = "TravelDetailViewController"
  }
}
