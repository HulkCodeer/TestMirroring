//
//  ViewModel.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/05/22.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

internal class ViewModel: NSObject {
    internal let provider: SoftberryAPI
    internal let backgroundScheduler = SerialDispatchQueueScheduler(qos: .userInitiated)
    internal let disposeBag = DisposeBag()
    internal let softberryDBWorker: SoftberryDBWorker = SoftberryDBWorker()

    init(provider: SoftberryAPI) {
        self.provider = provider
        super.init()
    }

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
}
