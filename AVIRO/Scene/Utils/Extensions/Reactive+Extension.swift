//
//  Reactive+Extension.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillAppear)).map {
            $0.first as? Bool ?? false
        }
        return ControlEvent(events: source)
    }
    
    var viewDidAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidAppear)).map {
            $0.first as? Bool ?? false
        }
        return ControlEvent(events: source)
    }
    
    var viewWillDisAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillDisappear)).map {
            $0.first as? Bool ?? false
        }
        return ControlEvent(events: source)
    }
}
