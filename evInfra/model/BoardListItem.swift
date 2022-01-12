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
