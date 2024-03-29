//
//  TheaterMapViewController.swift
//  TravelTheater
//
//  Created by 원태영 on 1/15/24.
//

import UIKit
import MapKit

// TODO: -
/// 1. 지도 핀 좌표 평균값 구해서 center 위치 구하기
/// 2. center에서 가장 먼 distance 핀 거리로 반지름 구해서 span 적용하기

final class TheaterMapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var currentLocationButton: UIButton!
  
  private var theaters: [Theater]? = TheaterList.mapAnnotations
  private var currentFilter: TheaterType = .all {
    didSet {
      updateTheaters()
      resetMapAnnotation()
      setMapAnnotation()
    }
  }
  
  /// 현재 영화관 필터가 all이면 전체가 보이는 반경으로, 아니라면 확대된 반경을 반환합니다.
  private var mapRadiusMeter: Double {
    return currentFilter == .all ? Constant.Map.radiusMeter : Constant.Map.filteredRadiusMeter
  }
  
  /// 기본(노들역)으로 설정된 좌표를 반환합니다.
  private var startCoordinate: CLLocationCoordinate2D {
    let coordValue: (x: Double, y: Double) = Constant.Location.nodeulStation.coordinateValue
    
    return CLLocationCoordinate2D(latitude: coordValue.x, longitude: coordValue.y)
  }
  
  /// 1. 델리게이트 설정
  /// 2. 위치 권한 체크
  /// 3. 핀 포인트 생성
  /// 4. 필터 Bar 버튼 추가
  /// 5. 현재위치 버튼 추가
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setDelegate()
    LocationManager.shared.checkLocationAuthorization()
    setMapAnnotation()
    setFilterBarButtonItem()
    configureCurrentLocationButton()
  }
  
  /// 현재 필터 타입에 해당하는 영화관 리스트를 반영합니다.
  private func updateTheaters() {
    self.theaters = TheaterList.filteredAnnotations[currentFilter]
  }
  
  private func configureCurrentLocationButton() {
    var config = UIButton.Configuration.filled()
    config.image = Constant.SFSymbol.currentLocationButton.image
    config.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
    config.cornerStyle = .capsule
    config.baseBackgroundColor = .white
    config.baseForegroundColor = .black
    
    currentLocationButton.configuration = config
    currentLocationButton.addTarget(
      self,
      action: #selector(currentLocationButtonTapped),
      for: .touchUpInside
    )
  }
  
  @objc private func currentLocationButtonTapped() {
    if LocationManager.shared.currentAuthorization == .denied {
      
      showPermissionRequestAlert()
    } else {
      
      LocationManager.shared.checkLocationAuthorization()
    }
  }
}

// MARK: - Navigation Bar
extension TheaterMapViewController {
  /// 네비게이션 바 우측에 필터 버튼을 추가합니다.
  private func setFilterBarButtonItem() {
    let image = Constant.SFSymbol.filterBarButton.image?.configured(size: 20, color: .label)
    let button: UIBarButtonItem = UIBarButtonItem(
      image: image,
      style: .plain,
      target: self,
      action: #selector(filterBarButtonTapped)
    )
    
    navigationItem.rightBarButtonItem = button
  }
  
  @objc private func filterBarButtonTapped() {
    showingFilterActionSheet { action in
      guard
        let title = action.title,
        let type = TheaterType(rawValue: title)
      else {
        return
      }
      
      self.currentFilter = type
    }
  }
  
  /// 액션 시트를 호출합니다.
  private func showingFilterActionSheet(completion: @escaping (UIAlertAction) -> Void) {
    let alert = UIAlertController(title: Constant.Text.filterAlertTitle.text,
                                  message: nil,
                                  preferredStyle: .actionSheet)
    
    
    /// 선택된 액션에 해당하는 영화관 필터 타입으로 현재 필터를 교체합니다.
    let actions: [UIAlertAction] = TheaterType.allCases.map { type in
      return UIAlertAction(
        title: type.name,
        style: .default,
        handler: completion
      )
    }
    
    actions.forEach { action in
      alert.addAction(action)
    }
    
    present(alert, animated: true)
  }
}

// MARK: - Configure Map
extension TheaterMapViewController {
  /// 지도의 표시 위치를 설정합니다. 목적지를 받았으면 해당 목적지로, 아니라면 전체 영화관의 중간 위치를 계산해서 설정합니다.
  private func configureMap(destination: MKCoordinateRegion? = nil, animated: Bool = true) {
    let region = destination ?? MKCoordinateRegion(
      center: mapView.annotations.centerCoordinate,
      span: mapView.annotations.centerSpan
    )
    
    mapView.setRegion(region, animated: animated)
  }
  
  /// 영화관 데이터 배열을 통해 위치를 계산해서 핀 포인트를 설치합니다.
  private func setMapAnnotation() {
    guard let theaters else {
      print(#function, TheaterError.theaterFilterInvalid.errorDescription)
      return
    }
    
    let annotations: [MKPointAnnotation] = theaters.map { theater in
      let annotation = MKPointAnnotation()
      annotation.coordinate = theater.coordinate
      annotation.title = theater.location
      
      return annotation
    }
    
    mapView.addAnnotations(annotations)
    configureMap(destination: nil)
  }
  
  /// 핀 포인트의 위치로 현재 위치를 이동시킵니다.
  private func moveToDestination(_ annotation: MKPointAnnotation?) {
    if let annotation {
      let newRegion = MKCoordinateRegion(center: annotation.coordinate,
                                         latitudinalMeters: Constant.Map.selectedRadiusMeter,
                                         longitudinalMeters: Constant.Map.selectedRadiusMeter)
      
      configureMap(destination: newRegion)
    }
  }
  
  /// 좌표의 위치로 현재 위치를 이동시킵니다.
  private func moveToDestination(_ coordinate: CLLocationCoordinate2D, animated: Bool) {
    let newRegion = MKCoordinateRegion(center: coordinate,
                                       latitudinalMeters: Constant.Map.selectedRadiusMeter,
                                       longitudinalMeters: Constant.Map.selectedRadiusMeter)
    
    configureMap(destination: newRegion, animated: animated)
  }
  
  /// 모든 핀 포인트를 제거합니다.
  private func resetMapAnnotation() {
    mapView.removeAnnotations(mapView.annotations)
  }
}

// MARK: - Map Delegate
extension TheaterMapViewController: MKMapViewDelegate {
  /// 맵뷰, Location 매니저 델리게이트를 설정합니다.
  private func setDelegate() {
    mapView.delegate = self
    LocationManager.shared.delegate = self
  }
  
  /// 핀 포인트가 탭 되면 호출됩니다. 목적지로 이동하는 함수를 호출합니다.
  func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
    guard let casted = annotation as? MKPointAnnotation else {
      print(#function, TheaterError.castingAnnotationFailed.errorDescription)
      return
    }
    
    moveToDestination(casted)
  }
  
  /// 영화관 로고 이미지를 핀 포인트에 적용합니다.
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard 
      let annotation = annotation as? MKPointAnnotation,
      let theaterTitle = annotation.title?.firstWord,
      let theaterType = TheaterType(rawValue: theaterTitle)
    else {
      return nil
    }
    
    let annotationView = MKAnnotationView()
    
    annotationView.annotation = annotation
    annotationView.image = theaterType.annotationImage.resized(newWidth: 30)
    annotationView.canShowCallout = true
    
    return annotationView
  }
}

// MARK: - Location Manager Delegate
extension TheaterMapViewController: LocationManagerDelegate {
  
  /// 지정한 좌표로 지도의 현재 위치를 이동합니다.
  func updateCoordinateOnMap(coordiante: CLLocationCoordinate2D) {
    self.moveToDestination(coordiante, animated: false)
  }
  
  /// 위치 서비스 글로벌 설정 OFF 안내를 팝업하고 앱을 종료합니다.
  func showLocationServiceTurnOffAlert() {
    
    let alert = UIAlertController(
      title: "위치 서비스 이용 불가",
      message: .combineWithLineBreaks(
        "위치 서비스가 꺼져 있어서 위치 권한을 요청할 수 없어요.",
        "지도 서비스를 이용하려면 설정>개인정보 보호 및 보안>위치 서비스에서 켜주세요.",
        "확인을 누르면 TravelTheater 앱이 종료됩니다."
      ),
      preferredStyle: .alert
    )
      .setAction(title: "확인", style: .destructive) {
        fatalError()
      }
    
    self.present(alert, animated: true)
  }
  
  /// 권한 허용 유도 안내 팝업을 호출합니다.
  func showPermissionRequestAlert() {
    
    DispatchQueue.main.async {
      let alert = UIAlertController(
        title: "위치 정보 이용",
        message: "현재 위치 서비스를 사용하기 위해 기기의 '설정>개인정보 보호 및 보안>위치 서비스>TravelTheater'에서 위치 접근을 허용해주세요.",
        preferredStyle: .alert
      )
        .setAction(title: "설정으로 이동", style: .default) {
          self.goSettingAction()
        }
        .setCancelAction()
      
      self.present(alert, animated: true)
    }
  }
  
  /// 설정창 이동 URL을 통해 화면을 전환합니다.
  /// URL을 찾지 못하면 직접 변경 안내 팝업을 호출합니다.
  private func goSettingAction() {
    guard let settingURL = URL(string: UIApplication.openSettingsURLString) else {
      cannotGoSettingAlert()
      return
    }
    
    UIApplication.shared.open(settingURL)
  }
  
  /// 직접 변경 안내 팝업을 호출합니다.
  private func cannotGoSettingAlert() {
    let alert = UIAlertController(
      title: "연결 불가",
      message: .combineWithLineBreaks(
        "설정으로 연결할 수 없습니다. 직접 설정에서 변경해주세요.",
        "확인을 누르면 'TravelTheater' 앱이 종료됩니다."
      ),
      preferredStyle: .alert
    )
      .setAction(title: "확인", style: .default)
    
    self.present(alert, animated: true)
  }
}
