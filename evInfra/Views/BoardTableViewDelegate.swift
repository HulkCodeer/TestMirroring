//
//  BoardTableViewDelegate.swift
//  evInfra
//
//  Created by bulacode on 2018. 4. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit


protocol BoardTableViewDelegate {

    func getFirstBoardData()
    func getNextBoardData()
    
    func boardEdit(tag: Int)
    func boardDelete(tag: Int)
    
    func makeReply(tag: Int)
    func makeAdReply(tag: Int)
    func replyEdit(tag: Int)
    func replyDelete(tag: Int)
    
    func goToStation(tag: Int)
    func goToAdUrl(tag: Int)
}

