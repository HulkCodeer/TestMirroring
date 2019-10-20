//
//  MembershipIssuanceViewDelegate.swift
//  evInfra
//
//  Created by bulacode on 18/09/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation
protocol MembershipIssuanceViewDelegate {
    func searchZipCode()
    func applyMembershipCard(params: [String: String])
    func showValidateFailMsg(msg: String)
}
