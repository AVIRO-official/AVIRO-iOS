//
//  ReviewWriteViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//
import RxSwift
import RxCocoa

final class ReviewWriteViewModel: ViewModel {    
    private var amplitude: AmplitudeProtocol!
    
    var placeId: String!
    var placeIcon: UIImage!
    var placeTitle: String!
    var placeAddress: String!
    
    init(
        placeId: String,
        placeIcon: UIImage,
        placeTitle: String,
        placeAddress: String,
        amplitude: AmplitudeProtocol = AmplitudeUtility()
    ) {
        self.placeIcon = placeIcon
        self.placeTitle = placeTitle
        self.placeAddress = placeAddress
        
        self.amplitude = amplitude
    }
    
    struct Input {
        let text: Driver<String?>
        let uploadReview: Driver<Void>
    }
    
    struct Output {
        let isEditing: Driver<Bool>
        let textCount: Driver<Int>
        let review: Driver<String>
        let keyboardWillShow: Driver<Void>
        let keyboardWillHide: Driver<Void>
        let uploadReview: Driver<AVIROEnrollReviewResultDTO>
        let error: Driver<APIError>
    }
    
    func transform(with input: Input) -> Output {
        var content = ""
        let uploadReviewError = PublishSubject<Error>()
        
        let isEditing = input.text.map {
            $0?.count ?? 0 > 0 ? true : false
        }
        
        let restrictedText = input.text
            .map { text in
                let text = text ?? ""
                if text.count > 200 {
                    let index = text.index(text.startIndex, offsetBy: 200)
                    let restricted = String(text[..<index])
                    content = restricted
                    return restricted
                } else {
                    content = text
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
        
        let uploadReview = input.uploadReview
            .flatMapLatest { [weak self] in
                guard let self = self else {
                    return Driver<AVIROEnrollReviewResultDTO>.empty()
                }
                
                let model = AVIROEnrollReviewDTO(
                    placeId: self.placeId,
                    userId: MyData.my.id,
                    content: content
                )
                
                return self.updateReview(with: model)
                    .asDriver { error in
                        uploadReviewError.onNext(error)
                        return Driver.empty()
                    }
            }
        
        let error = uploadReviewError
            .map { error -> APIError in
                return (error as? APIError) ?? APIError.badRequest
            }
            .asDriver(onErrorDriveWith: Driver.empty())
        
        return Output(
            isEditing: isEditing,
            textCount: textCount,
            review: restrictedText,
            keyboardWillShow: keyboardWillShow,
            keyboardWillHide: keyboardWillHide,
            uploadReview: uploadReview,
            error: error
        )
    }
    
    private func updateReview(with reviewModel: AVIROEnrollReviewDTO) -> Single<AVIROEnrollReviewResultDTO> {
        return Single.create { single in
            AVIROAPIManager().createReview(with: reviewModel) { [weak self] result in
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        self?.amplitude.uploadReview(
                            with: self?.placeTitle ?? "",
                            review: reviewModel.content
                        )
                        single(.success(model))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
