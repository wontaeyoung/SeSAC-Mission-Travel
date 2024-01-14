//
//  ChatRoomListViewController.swift
//  TravelTalk
//
//  Created by 원태영 on 1/12/24.
//

// TODO: -
/// 1. 채팅방 네비게이션 뒤로가기 버튼, 타이틀 설정 -> Done
/// 2. 채팅 버블 가로 사이즈 dynamic 적용 -> Done
/// 3. 검색 기능 구현
/// 4. 멀티 프로필이미지 구현
/// 5. 날짜 변경선 적용
/// 6. 채팅 메세지 입력 필드 디자인 -> Done
/// 7. 채팅 메세지 추가 기능 -> Done
/// 8. 채팅방 스크롤 동작 구현 -> Done

import UIKit

final class ChatRoomListViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var chatRoomTableView: UITableView!
  
  private var chatRooms: [ChatRoom] = ChatData.mockChatList
  private var shwoingChatRooms: [ChatRoom] = ChatData.mockChatList
  
  override func viewDidLoad() {
    super.viewDidLoad()
    register(cellType: ChatRoomTableViewCell.self)
    configureTableView()
    configureUI()
  }
}

// MARK: - Table Protocol
extension ChatRoomListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatRooms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ChatRoomTableViewCell = tableView.dequeueReusableCell(
      withIdentifier: ChatRoomTableViewCell.identifier,
      for: indexPath
    ) as! ChatRoomTableViewCell
    let row: Int = indexPath.row
    let chatRoom: ChatRoom = chatRooms[safe: row] ?? .dummy
    
    cell.setData(data: chatRoom, tag: row)
    
    return cell
  }
}

// MARK: - Configure
extension ChatRoomListViewController: TableUIConfigurable {
  func register<T: CellConfigurable>(cellType: T.Type) {
    let xib = UINib(nibName: cellType.identifier, bundle: nil)
    
    chatRoomTableView.register(xib, forCellReuseIdentifier: cellType.identifier)
  }
  
  func configureTableView() {
    chatRoomTableView.delegate = self
    chatRoomTableView.dataSource = self
    chatRoomTableView.separatorStyle = .none
  }
  
  func configureUI() {
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = Constant.Label.userNameSearchFieldPlaceholder
    
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
    navigationController?.navigationBar.barTintColor = .black
  }
}

// MARK: - Navigation
extension ChatRoomListViewController: Navigator {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chatRoom: ChatRoom = chatRooms[safe: indexPath.row] ?? .dummy
    
    push(ChatRoomViewController.self) { controller in
      controller.setData(data: chatRoom) { self.chatRooms = ChatData.mockChatList }
    }
    
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
}
