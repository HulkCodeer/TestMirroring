//
//  ShipmentStepView.swift
//  evInfra
//
//  Created by 박현진 on 2022/10/24.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RxSwift
import RxCocoa

internal final class ShipmentStepView: UIView {
    typealias StepView = (lineView: UIView, dotView: UIView, totalView: UIView)
    
    enum DotConstant {
        static let size: CGFloat = 12
        static let bigSize: CGFloat = 16
    }
        
    // MARK: UI
    
    private lazy var shipmentStatusGuideLbl = UILabel().then {
        $0.text = "EV Pay 카드 발송 현황"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .black
        $0.textAlignment = .natural
    }
    
    private lazy var totalStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    private lazy var confirmReceiptGuideTotalView = UIView()
    
    private lazy var receiptMessageTotalView = UIView().then {
        $0.IBcornerRadius = 15
        $0.backgroundColor = Colors.backgroundSecondary.color
    }
    
    private lazy var messageLbl = UILabel().then {
        $0.textAlignment = .natural
        $0.textColor = Colors.contentPrimary.color
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 2
        $0.text = "발송 주소의 우편함을 확인해보세요! 📮\n카드를 잘 받으셨다면 아래 버튼을 눌러주세요."
        $0.setTextWithLineHeight(lineHeight: 22)
    }
    
    private lazy var mailboxConfirmReceiptBtn = RectButton(level: .primary).then {
        $0.setTitle("카드 수령 확정하기", for: .normal)
    }
    
    private lazy var sendingMessageTotalView = UIView()
    
    private lazy var sendingMessageLbl = UILabel().then {
        $0.textColor = Colors.contentTertiary.color
        $0.text = "카드를 잘 받으셨다면 아래 버튼을 눌러주세요."
        $0.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private lazy var sendingConfirmReceiptBtn = RectButton(level: .primary).then {
        $0.setTitle("카드 수령 확정하기", for: .normal)
    }
    
    private lazy var moveNotCardReceivedGuideLbl = UILabel().then {
        $0.textColor = Colors.contentTertiary.color
        $0.text = "아직 카드를 못받으셨나요?"        
        $0.setUnderline()
        $0.font = .systemFont(ofSize: 12, weight: .bold)
    }
            
    private lazy var completeBtn = RectButton(level: .primary).then {
        $0.setTitle("카드 수령 확정 완료", for: .normal)
        $0.isEnabled = false
    }
    
    private lazy var completeEnableBtn = UIButton().then {
        $0.isEnabled = true
    }
    
    private lazy var moveNotCardReceivedGuideBtn = UIButton()
                    
    // MARK: VARIABLE
    
    private var disposebag = DisposeBag()
    
    internal weak var reactor: MembershipCardReactor?
    
    // MARK: SYSTEM FUNC
    
    deinit {        
        printLog(out: "\(type(of: self)): Deinited")
    }
            
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    // MARK: FUNC
    
    func makeUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(shipmentStatusGuideLbl)
        shipmentStatusGuideLbl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
        }
        
        self.addSubview(totalStackView)
        totalStackView.snp.makeConstraints {
            $0.top.equalTo(shipmentStatusGuideLbl.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(16)
            $0.width.equalTo(24)
        }
        
        self.addSubview(confirmReceiptGuideTotalView)
        confirmReceiptGuideTotalView.snp.makeConstraints {
            $0.top.equalTo(totalStackView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-39)
            $0.height.equalTo(0)
        }
        
        let lineView = self.createLineView()
        self.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.height.equalTo(4)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    internal func bind(model: MembershipCardInfo) {
        totalStackView.removeAllArrangedSubviews()
        
        completeEnableBtn.rx.tap
            .asDriver()
            .drive(with: self) { obj, _ in
                GlobalFunctionSwift.showPopup(
                    title: "EV Pay 카드 발송 안내",
                    message: "카드 발송은 최대 10일 소요될 수 있어요.\n10일 이후에도 카드가 도착하지 않은 경우,\n고객센터에 문의 시 빠르게 확인해드릴게요.",
                    confirmBtnTitle: "고객센터 전화하기",
                    confirmBtnAction: {
                        guard let number = URL(string: "tel://070-8633-9009") else { return }
                        UIApplication.shared.open(number)
                    },
                    cancelBtnTitle: "취소")
            }
            .disposed(by: self.disposebag)
        
        Observable.merge(mailboxConfirmReceiptBtn.rx.tap.asObservable(), sendingConfirmReceiptBtn.rx.tap.asObservable())
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { obj, _ in
                guard let _reactor = obj.reactor else { return }
                
                GlobalFunctionSwift.showPopup(
                    title: "EV Pay 카드를 잘 받으셨나요?",
                    message: "받은 경우 아래 버튼을 눌러주세요.\n이후 카드 발송 현황은 사라져요.",
                    confirmBtnTitle: "네 잘 받았어요",
                    confirmBtnAction: {
                        Observable.just(MembershipCardReactor.Action.confirmDelivery)
                            .bind(to: _reactor.action)
                            .disposed(by: obj.disposebag)
                    },
                    cancelBtnTitle: "아직이에요")
            }
            .disposed(by: self.disposebag)
                        
        let isCurrentMainboxConfirm = model.condition.convertStatusArr.filter { $0.passType == .current }.first?.shipmentStatusType != .mailboxConfirm
        
        let isCurrentSendComplete = model.condition.convertStatusArr.allSatisfy { $0.passType == .complete }
                         
        if !isCurrentMainboxConfirm { // 우편함 확인일 경우
            confirmReceiptGuideTotalView.isHidden = isCurrentMainboxConfirm
            self.makeMailBoxConfirmMessageView()
        }
        
        if isCurrentSendComplete { // 발송 완료일 경우 위의 우편함 확인 View에 버튼만 올린다.
            confirmReceiptGuideTotalView.removeAllSubviews()
            confirmReceiptGuideTotalView.isHidden = !isCurrentSendComplete
            self.makeSendCompleteView()
        }
                                           
        for convertStatus in model.condition.convertStatusArr {            
            let stepTotalView = self.makeStepDotView(statusInfo: convertStatus)
            
            totalStackView.addArrangedSubview(stepTotalView.totalView)
                                                            
            self.makeStatusDesc(statusInfo: convertStatus,
                                parentView: stepTotalView.dotView,
                                registerTime: model.condition.displayRegDate,
                                startTime: model.condition.displayStartDate)
                        
            let isSendReadyCurrent = convertStatus.passType == .current && convertStatus.shipmentStatusType == .sendReady
            let isSendingCurrent = convertStatus.passType == .current && convertStatus.shipmentStatusType == .sending
            
            // 신청 접수, 발송 시작 옆에 메세지 만드는 로직
            if isSendReadyCurrent {
                self.makeSendReadyGuideView(stepTotalView: stepTotalView, convertStatus: convertStatus)
            }
            
            if isSendingCurrent {
                self.makeSendingGuideView(stepTotalView: stepTotalView, convertStatus: convertStatus)
            }
        }
    }
    
    private func makeSendReadyGuideView(stepTotalView: StepView, convertStatus: ConvertStatus) {
        let statusDescTotalView = UIView().then {
            $0.IBcornerRadius = 15
            $0.backgroundColor = Colors.backgroundSecondary.color
        }

        self.addSubview(statusDescTotalView)
        statusDescTotalView.snp.makeConstraints {
            $0.leading.equalTo(stepTotalView.lineView.snp.trailing).offset(26)
            $0.top.equalTo(stepTotalView.dotView.snp.bottom).offset(14)
            $0.height.greaterThanOrEqualTo(120)
            $0.trailing.equalToSuperview().offset(-18)
        }
        
        let message = "\(convertStatus.shipmentStatusType.toMessage)"
        let attributeText = NSMutableAttributedString(string: message)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: Colors.contentPrimary.color]
        attributeText.setAttributes(attributes, range: NSRange(location: 0, length: message.count))
        
        attributeText.attributedString(text: "2~3일내로 발송",
                                          font: .systemFont(ofSize: 14, weight: .regular),
                                          textColor: Colors.contentPositive.color)
                                        
        let statusDescLbl = UILabel().then {
            $0.textAlignment = .natural
            $0.textColor = Colors.contentPrimary.color
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 5
            $0.attributedText = attributeText
        }
        
        statusDescTotalView.addSubview(statusDescLbl)
        statusDescLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        let moveChargingHelpGuideTotalView = UIView().then {
            $0.backgroundColor = .white
            $0.IBcornerRadius = 18
        }

        statusDescTotalView.addSubview(moveChargingHelpGuideTotalView)
        moveChargingHelpGuideTotalView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(statusDescLbl.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-16)
        }

        let moveChargingHelpGuideLbl = UILabel().then {
            $0.text = "카드 받기 전 충전 방법"
            $0.textAlignment = .center
            $0.textColor = Colors.contentPrimary.color
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }

        moveChargingHelpGuideTotalView.addSubview(moveChargingHelpGuideLbl)
        moveChargingHelpGuideLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        let arrowImgView = ChevronArrow.init(.size16(.right))
        arrowImgView.IBimageColor = Colors.contentTertiary.color

        moveChargingHelpGuideTotalView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints {
            $0.leading.equalTo(moveChargingHelpGuideLbl.snp.trailing)
            $0.width.height.equalTo(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        let moveChargingHelpBtn = UIButton()

        moveChargingHelpGuideTotalView.addSubview(moveChargingHelpBtn)
        moveChargingHelpBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        moveChargingHelpBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let viewcon = ChargingGuideWebViewController()
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposebag)
    }
    
    private func makeSendingGuideView(stepTotalView: StepView, convertStatus: ConvertStatus) {
        let statusDescTotalView = UIView().then {
            $0.IBcornerRadius = 15
            $0.backgroundColor = Colors.backgroundSecondary.color
        }

        self.addSubview(statusDescTotalView)
        statusDescTotalView.snp.makeConstraints {
            $0.leading.equalTo(stepTotalView.lineView.snp.trailing).offset(26)
            $0.top.equalTo(stepTotalView.dotView.snp.bottom).offset(14)
            $0.height.equalTo(155)
            $0.trailing.equalToSuperview().offset(-18)
        }
        
        let message = "\(convertStatus.shipmentStatusType.toMessage)"
        let attributeText = NSMutableAttributedString(string: message)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: Colors.contentPrimary.color]
        attributeText.setAttributes(attributes, range: NSRange(location: 0, length: message.count))
        
        attributeText.attributedString(text: "우편 발송되어 도착 날짜가 정확하지 않을 수 있으니\n양해 부탁드려요.",
                                          font: .systemFont(ofSize: 12, weight: .regular),
                                          textColor: Colors.contentTertiary.color)
                                        
        let statusMainDescLbl = UILabel().then {
            $0.textAlignment = .natural
            $0.textColor = Colors.contentPrimary.color
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.numberOfLines = 5
            $0.attributedText = attributeText
        }
                    
        statusDescTotalView.addSubview(statusMainDescLbl)
        statusMainDescLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(79)
        }

        let moveChargingHelpGuideTotalView = UIView().then {
            $0.backgroundColor = .white
            $0.IBcornerRadius = 18
        }

        statusDescTotalView.addSubview(moveChargingHelpGuideTotalView)
        moveChargingHelpGuideTotalView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(statusMainDescLbl.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-16)
        }

        let moveChargingHelpGuideLbl = UILabel().then {
            $0.text = "카드 받기 전 충전 방법"
            $0.textAlignment = .center
            $0.textColor = Colors.contentPrimary.color
            $0.font = .systemFont(ofSize: 14, weight: .regular)
        }

        moveChargingHelpGuideTotalView.addSubview(moveChargingHelpGuideLbl)
        moveChargingHelpGuideLbl.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        let arrowImgView = ChevronArrow.init(.size16(.right))
        arrowImgView.IBimageColor = Colors.contentTertiary.color

        moveChargingHelpGuideTotalView.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints {
            $0.leading.equalTo(moveChargingHelpGuideLbl.snp.trailing)
            $0.width.height.equalTo(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }

        let moveChargingHelpBtn = UIButton()

        moveChargingHelpGuideTotalView.addSubview(moveChargingHelpBtn)
        moveChargingHelpBtn.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        moveChargingHelpBtn.rx.tap
            .asDriver()
            .drive(onNext: {
                let viewcon = ChargingGuideWebViewController()
                GlobalDefine.shared.mainNavi?.push(viewController: viewcon)
            })
            .disposed(by: self.disposebag)
        
        self.addSubview(sendingMessageTotalView)
        sendingMessageTotalView.snp.makeConstraints {
            $0.leading.equalTo(statusDescTotalView)
            $0.top.equalTo(statusDescTotalView.snp.bottom).offset(16)
            $0.height.equalTo(70)
            $0.trailing.equalToSuperview().offset(-18)
        }
        
        sendingMessageTotalView.addSubview(sendingMessageLbl)
        sendingMessageLbl.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        sendingMessageTotalView.addSubview(sendingConfirmReceiptBtn)
        sendingConfirmReceiptBtn.snp.makeConstraints {
            $0.top.equalTo(sendingMessageLbl.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
            
    private func makeSendCompleteView() {
        confirmReceiptGuideTotalView.snp.remakeConstraints {
            $0.top.equalTo(totalStackView.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        self.confirmReceiptGuideTotalView.addSubview(completeBtn)
        completeBtn.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
                
        self.confirmReceiptGuideTotalView.addSubview(completeEnableBtn)
        completeEnableBtn.snp.makeConstraints {
            $0.width.equalTo(completeBtn.snp.width)
            $0.height.equalTo(completeBtn.snp.height)
        }
    }
    
    private func makeMailBoxConfirmMessageView() {
        confirmReceiptGuideTotalView.snp.remakeConstraints {
            $0.top.equalTo(totalStackView.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        self.confirmReceiptGuideTotalView.addSubview(receiptMessageTotalView)
        receiptMessageTotalView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        receiptMessageTotalView.addSubview(messageLbl)
        messageLbl.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(16)
            $0.height.equalTo(44)
            $0.trailing.bottom.equalToSuperview().offset(-16)
        }

        self.confirmReceiptGuideTotalView.addSubview(mailboxConfirmReceiptBtn)
        mailboxConfirmReceiptBtn.snp.makeConstraints {
            $0.top.equalTo(receiptMessageTotalView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }

        self.confirmReceiptGuideTotalView.addSubview(moveNotCardReceivedGuideLbl)
        moveNotCardReceivedGuideLbl.snp.makeConstraints {
            $0.top.equalTo(mailboxConfirmReceiptBtn.snp.bottom).offset(16)
            $0.centerX.equalTo(mailboxConfirmReceiptBtn.snp.centerX)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview()
        }

        self.confirmReceiptGuideTotalView.addSubview(moveNotCardReceivedGuideBtn)
        moveNotCardReceivedGuideBtn.snp.makeConstraints {
            $0.center.equalTo(moveNotCardReceivedGuideLbl)
            $0.height.equalTo(44)
            $0.width.equalTo(moveNotCardReceivedGuideLbl)
        }                
    }
    
    private func makeStatusDesc(statusInfo: ConvertStatus, parentView: UIView, registerTime: String, startTime: String) {
        let typeDescLbl = UILabel().then {
            $0.text = "\(statusInfo.shipmentStatusType.toString)"
            
            var textColor = Colors.contentDisabled.color
            // 현재 스텝, 또는 이미 완료된 스텝일 경우 글씨 색 변경
            if statusInfo.passType == .current {
                textColor = Colors.contentPrimary.color
            }
            if statusInfo.passType == .complete {
                textColor = Colors.contentSecondary.color
            }
                                    
            $0.textColor = textColor
            $0.font = .systemFont(ofSize: statusInfo.passType == .current ? 16 : 14, weight: .regular)
            $0.textAlignment = .natural
        }
        
        self.addSubview(typeDescLbl)
        typeDescLbl.snp.makeConstraints {
            $0.leading.equalTo(parentView.snp.trailing).offset(20)
            $0.centerY.equalTo(parentView.snp.centerY)
            $0.height.equalTo(24)
        }
        
        let timeLbl = UILabel().then {
            $0.text = "\(registerTime)"
            $0.textColor = Colors.contentTertiary.color
            $0.font = .systemFont(ofSize:12 , weight: .regular)
            $0.textAlignment = .natural
        }
        
        self.addSubview(timeLbl)
        timeLbl.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalTo(typeDescLbl.snp.centerY)
            $0.height.equalTo(18)
        }
        
        timeLbl.text = ""
                        
        if !registerTime.isEmpty && statusInfo.shipmentStatusType == .sendReady {
            timeLbl.text = registerTime
        }
        
        if !startTime.isEmpty && statusInfo.shipmentStatusType == .sending {
            timeLbl.text = startTime
        }
    }
    
    private func makeStepDotView(statusInfo: ConvertStatus) -> StepView {
        let totalView = UIView()
        
        totalView.snp.makeConstraints {
            $0.width.equalTo(24)
        }
        
        let dotView = UIView()
        
        if statusInfo.shipmentStatusType == .mailboxConfirm && statusInfo.passType == .complete {
            dotView.layer.addSublayer(self.makeBigDotView())
            totalView.addSubview(dotView)
            dotView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.width.height.equalTo(DotConstant.bigSize)
                $0.centerX.equalToSuperview()
            }
            
            let checkImgView = UIImageView().then {
                $0.image = Icons.iconCheckXs.image
                $0.tintColor = Colors.backgroundPrimary.color
            }
            
            dotView.addSubview(checkImgView)
            checkImgView.snp.makeConstraints {
                $0.width.height.equalTo(DotConstant.bigSize)
            }
        } else {
            dotView.layer.addSublayer(self.makeDotView(statusInfo: statusInfo))
            totalView.addSubview(dotView)
            dotView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.width.height.equalTo(DotConstant.size)
                $0.centerX.equalToSuperview()
            }
        }
                                                
        let lineView = self.createLineView(color: statusInfo.passType == .complete ? Colors.contentPrimary.color : Colors.contentDisabled.color)
        totalView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.top.equalTo(dotView.snp.bottom)
            $0.centerX.equalToSuperview()
            let isSendComplete = statusInfo.shipmentStatusType == .mailboxConfirm
            let isLongLine = statusInfo.passType == .current
            let isSending = statusInfo.shipmentStatusType == .sending
            $0.height.equalTo(isSendComplete ? 0 : isLongLine ? (isSending ? 276 : 168) : 36)
            $0.width.equalTo(2)
            $0.bottom.equalToSuperview()
        }
        
        totalView.bringSubviewToFront(dotView)
                                                
        return (lineView: lineView, dotView: dotView, totalView: totalView)
    }
    
    private func makeDotView(statusInfo: ConvertStatus) -> CAShapeLayer {
        var fillColor: CGColor
        var strokeColor: CGColor
        
        let primaryColor: CGColor = Colors.contentPrimary.color.cgColor
        let disableColor: CGColor = Colors.contentDisabled.color.cgColor
        
        switch statusInfo.passType {
        case .current:
            fillColor = UIColor.clear.cgColor
            strokeColor = primaryColor
            
        case .nextStep:
            fillColor = UIColor.clear.cgColor
            strokeColor = disableColor
            
        case .complete:
            fillColor = primaryColor
            strokeColor = primaryColor
            
        case .none:
            fillColor = UIColor.clear.cgColor
            strokeColor = UIColor.clear.cgColor
        }
        
        switch statusInfo.shipmentStatusType {
        case .mailboxConfirm:
            fillColor = statusInfo.passType == .current ? UIColor.clear.cgColor : disableColor
            
        default: break
        }
                
        return makeBezierPathRound(size: DotConstant.size, fillColor: fillColor, strokeColor: strokeColor)
    }
    
    private func makeBigDotView() -> CAShapeLayer {
        var fillColor: CGColor
        var strokeColor: CGColor
        
        let primaryColor: CGColor = Colors.contentPrimary.color.cgColor
        
        fillColor = primaryColor
        strokeColor = primaryColor
                                                
        return makeBezierPathRound(size: DotConstant.bigSize, fillColor: fillColor, strokeColor: strokeColor)
    }
    
    private func makeBezierPathRound(size: CGFloat, fillColor: CGColor, strokeColor: CGColor) -> CAShapeLayer {
        let center = CGPoint(x: size/2, y: size/2)
        let path = UIBezierPath(arcCenter: center,
                                radius: size/2,
                                startAngle: -CGFloat.pi/2,
                                endAngle: 2*CGFloat.pi-CGFloat.pi/2,
                                clockwise: true)
                                        
        let circleLayer = CAShapeLayer()
        circleLayer.frame = bounds
        circleLayer.path = path.cgPath
        circleLayer.fillColor = fillColor
        circleLayer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        circleLayer.strokeColor = strokeColor
        circleLayer.lineWidth = 2
        return circleLayer
    }
    
    internal func createLineView(color: UIColor? = Colors.backgroundSecondary.color) -> UIView {
        return UIView().then {
            $0.backgroundColor = color
        }
    }
}
