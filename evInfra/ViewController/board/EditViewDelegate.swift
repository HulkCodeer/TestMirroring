//
//  BoardEditDelegate.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 12..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit

protocol EditViewDelegate {
    func postBoardData(content: String, hasImage: Int, picture: Data?)
    func editBoardData(content: String, hasImage: Int, boardId: Int, editImage: Int, picture: Data?)
    func postReplyData(content: String, boardId: Int)
    func editReplyData(content: String, replyId: Int)
}
