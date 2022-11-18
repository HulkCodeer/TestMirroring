//
//  ServerResultProtocol.swift
//  evInfra
//
//  Created by 박현진 on 2022/11/18.
//  Copyright © 2022 soft-berry. All rights reserved.
//

protocol ServerResponse {
    var code:Int { get set }
    var msg: String { get set }
}
