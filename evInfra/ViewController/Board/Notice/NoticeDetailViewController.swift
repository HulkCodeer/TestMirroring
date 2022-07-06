//
//  NewNoticeContentViewController.swift
//  evInfra
//
//  Created by Kyoon Ho Park on 2022/06/27.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Then

final internal class NoticeDetailViewController: BaseViewController, StoryboardView {
    private let contentTextView = UITextView().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        $0.isEditable = false
        $0.dataDetectorTypes = .link
        $0.sizeToFit()
    }

    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func bind(reactor: NoticeDetailReactor) {
        Observable.just(Reactor.Action.loadData(reactor.boardId))
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.data }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] data in
                guard let self = self else { return }
                switch data.code {
                case 1000:
                    self.prepareActionBar(with: data.title)
                    self.contentTextView.text = data.content
                default :break
                }
            }.disposed(by: disposeBag)
    }
}
