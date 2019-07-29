//
//  ReportChargerChildCell.swift
//  evInfra
//
//  Created by 이신광 on 2018. 10. 18..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import Foundation

class ReportChargerChildCell: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var removeBtn: UIButton!
    
    @IBOutlet weak var dcCommboImg: UIImageView!
    @IBOutlet weak var dcDemoImg: UIImageView!
    @IBOutlet weak var ac3Img: UIImageView!
    @IBOutlet weak var slowImg: UIImageView!
    @IBOutlet weak var superImg: UIImageView!
    @IBOutlet weak var destinationImg: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ReportChargerChildCell", owner: self, options: nil)

        let dcCombo = UITapGestureRecognizer(target: self, action: #selector(self.onclickCombo))
        dcCommboImg.isUserInteractionEnabled = true
        dcCommboImg.addGestureRecognizer(dcCombo)
        
        let dcDemo = UITapGestureRecognizer(target: self, action: #selector(self.onclickDcDemo))
        dcDemoImg.isUserInteractionEnabled = true
        dcDemoImg.addGestureRecognizer(dcDemo)
        
        let ac3 = UITapGestureRecognizer(target: self, action: #selector(self.onclickAc3))
        ac3Img.isUserInteractionEnabled = true
        ac3Img.addGestureRecognizer(ac3)
        
        let slow = UITapGestureRecognizer(target: self, action: #selector(self.onclickSlow))
        slowImg.isUserInteractionEnabled = true
        slowImg.addGestureRecognizer(slow)
        
        let superCharger = UITapGestureRecognizer(target: self, action: #selector(self.onclickSuper))
        superImg.isUserInteractionEnabled = true
        superImg.addGestureRecognizer(superCharger)
        
        let destination = UITapGestureRecognizer(target: self, action: #selector(self.onclickDestination))
        destinationImg.isUserInteractionEnabled = true
        destinationImg.addGestureRecognizer(destination)
        
        var newFrame = self.frame
        newFrame.size = containerView.frame.size
        self.frame = newFrame
        
        containerView.translatesAutoresizingMaskIntoConstraints = true
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        addSubview(containerView)
    }
    
    /*
     self.dcCommboImg
     self.dcDemoImg
     self.ac3Img
     self.slowImg
     self.superImg
     self.destinationImg
     */
    @objc func onclickCombo(sender: UITapGestureRecognizer) {
        if slowImg.isHighlighted {
            Snackbar().show(message: "DC콤보 타입과 완속 타입은 동시에 설정할수 없습니다.")
            return
        } else if superImg.isHighlighted {
            Snackbar().show(message: "DC콤보 타입과 슈퍼차저 타입은 동시에 설정할수 없습니다.")
            return
        } else if destinationImg.isHighlighted {
            Snackbar().show(message: "DC콤보 타입과 데스티네이션 타입은 동시에 설정할수 없습니다.")
            return
        }
        
        dcCommboImg.isHighlighted = !dcCommboImg.isHighlighted
    }
    
    @objc func onclickDcDemo(sender: UITapGestureRecognizer) {
        if slowImg.isHighlighted {
            Snackbar().show(message: "DC데모 타입과 완속 타입은 동시에 설정할수 없습니다.")
            return
        } else if superImg.isHighlighted {
            Snackbar().show(message: "DC데모 타입과 슈퍼차저 타입은 동시에 설정할수 없습니다.")
            return
        } else if destinationImg.isHighlighted {
            Snackbar().show(message: "DC데모 타입과 데스티네이션 타입은 동시에 설정할수 없습니다.")
            return
        }
        
        dcDemoImg.isHighlighted = !dcDemoImg.isHighlighted
    }
    
    @objc func onclickAc3(sender: UITapGestureRecognizer) {
        if slowImg.isHighlighted {
            Snackbar().show(message: "AC3상 타입과 완속 타입은 동시에 설정할수 없습니다.")
            return
        } else if superImg.isHighlighted {
            Snackbar().show(message: "AC3상 타입과 슈퍼차저 타입은 동시에 설정할수 없습니다.")
            return
        } else if destinationImg.isHighlighted {
            Snackbar().show(message: "AC3상 타입과 데스티네이션 타입은 동시에 설정할수 없습니다.")
            return
        }
        
        ac3Img.isHighlighted = !ac3Img.isHighlighted
    }
    
    @objc func onclickSlow(sender: UITapGestureRecognizer) {
        if dcCommboImg.isHighlighted {
            Snackbar().show(message: "완속 타입과 DC콤보 타입은 동시에 설정할수 없습니다.")
            return
        } else if dcDemoImg.isHighlighted {
            Snackbar().show(message: "완속 타입과 DC데모 타입은 동시에 설정할수 없습니다.")
            return
        } else if ac3Img.isHighlighted {
            Snackbar().show(message: "완속 타입과 AC3상 타입은 동시에 설정할수 없습니다.")
            return
        } else if superImg.isHighlighted {
            Snackbar().show(message: "완속 타입과 슈퍼차저 타입은 동시에 설정할수 없습니다.")
            return
        } else if destinationImg.isHighlighted {
            Snackbar().show(message: "완속 타입과 데스티네이션 타입은 동시에 설정할수 없습니다.")
            return
        }
        
        slowImg.isHighlighted = !slowImg.isHighlighted
    }
    
    @objc func onclickSuper(sender: UITapGestureRecognizer) {
        if dcCommboImg.isHighlighted {
            Snackbar().show(message: "슈퍼차저 타입과 DC콤보 타입은 동시에 설정할수 없습니다.")
            return
        } else if dcDemoImg.isHighlighted {
            Snackbar().show(message: "슈퍼차저 타입과 DC데모 타입은 동시에 설정할수 없습니다.")
            return
        } else if ac3Img.isHighlighted {
            Snackbar().show(message: "슈퍼차저 타입과 AC3상 타입은 동시에 설정할수 없습니다.")
            return
        } else if slowImg.isHighlighted {
            Snackbar().show(message: "슈퍼차저 타입과 완속 타입은 동시에 설정할수 없습니다.")
            return
        } else if destinationImg.isHighlighted {
            Snackbar().show(message: "슈퍼차저 타입과 데스티네이션 타입은 동시에 설정할수 없습니다.")
            return
        }
        
        superImg.isHighlighted = !superImg.isHighlighted
    }
    
    @objc func onclickDestination(sender: UITapGestureRecognizer) {
        if self.dcCommboImg.isHighlighted {
            Snackbar().show(message: "데스티네이션 타입과  DC콤보 타입은 동시에 설정할수 없습니다.")
            return
        } else if self.dcDemoImg.isHighlighted {
            Snackbar().show(message: "데스티네이션 타입과 DC데모 타입은 동시에 설정할수 없습니다.")
            return
        } else if self.ac3Img.isHighlighted {
            Snackbar().show(message: "데스티네이션 타입과 AC3상 타입은 동시에 설정할수 없습니다.")
            return
        } else if self.slowImg.isHighlighted {
            Snackbar().show(message: "데스티네이션 타입과 완속 타입은 동시에 설정할수 없습니다.")
            return
        } else if self.superImg.isHighlighted {
            Snackbar().show(message: "데스티네이션 타입과 슈퍼차저 타입은 동시에 설정할수 없습니다.")
            return
        }
        
        destinationImg.isHighlighted = !destinationImg.isHighlighted
    }
}
