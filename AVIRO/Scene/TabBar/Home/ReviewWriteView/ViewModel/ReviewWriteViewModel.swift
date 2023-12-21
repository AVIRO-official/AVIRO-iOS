//
//  ReviewWriteViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//
import RxSwift
import RxCocoa

final class ReviewWriteViewModel: ViewModel {
    
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
        let textViewBiginEditing: Driver<Void>
        let text: Driver<String?>
    }
    
    struct Output {
        let isEditing: Driver<Bool>
        let textCount: Driver<String>
        let review: Driver<String>
    }
    
    func transform(with input: Input) -> Output {
        let isEditing = input.textViewBiginEditing
            .map { true }
        
        let restrictedText = input.text
            .flatMapLatest { text -> Driver<String> in
                let text = text ?? ""
                if text.count > 255 {
                    let index = text.index(text.startIndex, offsetBy: 255)
                    let restricted = String(text[..<index])
                    return Driver.just(restricted)
                } else {
                    return Driver.just(text)
                }
            }
        
        let textCount = restrictedText
            .map { "\($0.count)" }
        
        return Output(
            isEditing: isEditing,
            textCount: textCount,
            review: restrictedText
        )
    }
}
