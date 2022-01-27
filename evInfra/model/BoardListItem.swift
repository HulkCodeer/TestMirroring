//
//  BoardListItem.swift
//  evInfra
//
//  Created by PKH on 2022/01/12.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation

struct BoardResponseData: Decodable {
    var total: Int?
    var page: Int?
    var size: Int?
    var prize: Int?
    var list: [BoardListItem]?
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
