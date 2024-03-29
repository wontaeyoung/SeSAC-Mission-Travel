//
//  Chat.swift
//  TravelTalk
//
//  Created by 원태영 on 1/12/24.
//

import Foundation

struct Chat: Model {
  // MARK: - Property
  let user: User
  let date: String
  let message: String
  
  var isMine: Bool {
    return user == .user
  }
  
  var chatRoomDateFormatted: String {
    return date.formatted(format: Constant.DateFormat.chatListDateFormat)
  }
  
  var chatDetailDateFormatted: String {
    return date.formatted(format: Constant.DateFormat.chatRoomDateFormat)
  }
  
  var chatTimeFormatted: String {
    return date.formatted(format: Constant.DateFormat.chatRoomTimeFormat, travelLocale: .kr)
  }
  
  static var dummy: Chat {
    return Chat(user: .user,
                date: Date.now.string(),
                message: "더미 메세지입니다.")
  }
}
