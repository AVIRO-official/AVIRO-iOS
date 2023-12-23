//
//  ReviewWriteViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//
import RxSwift
import RxCocoa

final class ReviewWriteViewModel: ViewModel {
    private let disposeBag = DisposeBag()
    
    var placeIcon: UIImage!
    var placeTitle: String!
    var placeAddress: String!
    
    init(
        placeIcon: UIImage,
        placeTitle: String,
        placeAddress: String
    ) {
        self.placeIcon = placeIcon
        self.placeTitle = placeTitle
        self.placeAddress = placeAddress
        
    }
    
    struct Input {
        let text: Driver<String?>
    }
    
    struct Output {
        let isEditing: Driver<Bool>
        let textCount: Driver<Int>
        let review: Driver<String>
        let keyboardWillShow: Driver<Void>
        let keyboardWillHide: Driver<Void>
    }
    
    func transform(with input: Input) -> Output {
        let isEditing = input.text.map {
            $0?.count ?? 0 > 0 ? true : false
        }
        
        let restrictedText = input.text
            .map { text in
                let text = text ?? ""
                if text.count > 200 {
                    let index = text.index(text.startIndex, offsetBy: 200)
                    let restricted = String(text[..<index])
                    return restricted
                } else {
                    return text
                }
            }
        
        let textCount = restrictedText
            .map { $0.count }
        
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())

        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(
            isEditing: isEditing,
            textCount: textCount,
            review: restrictedText,
            keyboardWillShow: keyboardWillShow,
            keyboardWillHide: keyboardWillHide
        )
    }
    
}
