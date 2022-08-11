//
//  BoardListItem.swift
//  evInfra
//
//  Created by PKH on 2022/01/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import UIKit

struct BoardResponseData: Decodable {
    var total: Int?
    var page: Int?
    var size: Int?
    var prize: Int?
    var list: [BoardListItem]?
    var liked: [String]?
}

struct BoardListItem: Decodable {
    var title: String?
    var content: String?
    var nick_name: String?
    var module_srl: String?
    var mb_id: String?
    var document_srl: String?
    var last_update: String?
    var regdate: String?
    var is_notice: String?
    var title_bold: String?
    var title_color: String?
    var readed_count: String?
    var report_count: String?
    var like_count: String?
    var hate_count: String?
    var comment_count: String?
    var uploaded_count: String?
    var tags: String?
    var cover_filename: String?
    var mb_profile: String?
    var blind: String?
    var board_id: String?
    var files: [FilesItem]?
    
    init(_ adInfo: Ad) {
        self.title = adInfo.ad_url
        self.content = adInfo.ad_description
        self.nick_name = adInfo.client_name
        self.mb_id = adInfo.client_id
        self.document_srl = adInfo.ad_id
        self.cover_filename = adInfo.ad_image
        self.mb_profile = adInfo.ad_logo
        self.board_id = "ad"
    }
    
    init(_ adsInfo: AdsInfo) {
        self.title = adsInfo.evtTitle
        self.content = adsInfo.evtDesc
        self.nick_name = adsInfo.clientName
        self.document_srl = adsInfo.evtId
        self.cover_filename = adsInfo.img
        self.mb_profile = adsInfo.logo
        self.board_id = "ad"
    }
}

struct FilesItem: Decodable {
    var file_srl: String?
    var module_srl: String?
    var upload_target_srl: String?
    var upload_target_type: String?
    var mb_id: String?
    var source_filename: String?
    var uploaded_filename: String?
    var file_size: String?
    var isvalid: String?
    var cover_image: String?
    var regdate: String?
    var ipaddress: String?
    var file_seq: String?
    var thumb_filename: String?
}

struct BoardDetailResponseData: Decodable {
    var comments: [Comment]?
    var has_next: Bool?
    var has_prev: Bool?
    var prize: Int?
    var liked: Int?
    var document: Document?
    var files: [FilesItem]?
}

struct Document: Decodable {
    var document_srl: String?
    var module_srl: String?
    var is_notice: String?
    var title: String?
    var title_bold: String?
    var title_color: String?
    var content: String?
    var readed_count: String?
    var like_count: String?
    var hate_count: String?
    var comment_count: String?
    var uploaded_count: String?
    var report_count: String?
    var mb_id: String?
    var nick_name: String?
    var mb_profile: String?
    var tags: String?
    var youtube: String?
    var cover_filename: String?
    var fromMobile: String?
    var regdate: String?
    var last_update: String?
    var last_updater: String?
    var status: String?
    var comment_status: String?
    var ipaddress: String?
    var board_id: String?
    var findYoutube: Bool?
}

struct Comment: Decodable {
    var comment_srl: String?
    var module_srl: String?
    var document_srl: String?
    var parent_srl: String?
    var is_secret: String?
    var content: String?
    var like_count: String?
    var hate_count: String?
    var report_count: String?
    var mb_id: String?
    var nick_name: String?
    var uploaded_count: String?
    var regdate: String?
    var last_update: String?
    var ipaddress: String?
    var status: String?
    var mb_profile: String?
    var target_mb_id: String?
    var target_nick_name: String?
    var cover_filename: String?
    var tags: String?
    var comment_count: String?
    var head: String?
    var arrange: String?
    var depth: String?
    var blind: String?
    var block: String?
    var liked: Int?
    var files: [FilesItem]?
}

struct DocumentParameter {
    var document: Document
    var text: String
    var image: [UIImage]?
}

struct CommentParameter {
    var mid: String
    var documentSRL: String
    var comment: Comment?
    var text: String
    var image: UIImage?
    var selectedCommentRow: Int
    var isRecomment: Bool
}

struct Recomment {
    var targetMbId: String
    var targetNickName: String
    var parentSRL: String
    var head: String
    var depth: String
    var row: Int
}
