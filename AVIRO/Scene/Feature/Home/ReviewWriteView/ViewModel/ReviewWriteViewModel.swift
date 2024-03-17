//
//  ReviewWriteViewModel.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//
import RxSwift
import RxCocoa

struct ReviewWritePlaceModel {
    let placeIcon: UIImage
    let placeTitle: String
    let placeAddress: String
}

struct AfterWriteReviewModel {
    let placeId: String
    let contentId: String
    let content: String
    let userId: String
    let levelUp: Bool
    let userLevel: Int
}

final class ReviewWriteViewModel: ViewModel {
    private var amplitude: AmplitudeProtocol!
    
    private var placeId: String!
    private var placeIcon: UIImage!
    private var placeTitle: String!
    private var placeAddress: String!
    private var editReview: String = ""
    private var editCommentId: String?
    
    private var isViewWillAppear = true
    
    init(
        placeId: String,
        placeIcon: UIImage,
        placeTitle: String,
        placeAddress: String,
        content: String = "",
        editCommentId: String? = nil,
        amplitude: AmplitudeProtocol = AmplitudeUtility()
    ) {
        self.placeId = placeId
        self.placeIcon = placeIcon
        self.placeTitle = placeTitle
        self.placeAddress = placeAddress
        self.editReview = content
        self.editCommentId = editCommentId
        
        self.amplitude = amplitude
    }
    
    struct Input {
        let text: Driver<String?>
        let uploadReview: Driver<Void>
    }
    
    struct Output {
        let reviewWritePlaceModel: Driver<ReviewWritePlaceModel>
        let isShowTextViewPlaceHolder: Driver<Bool>
        let textCount: Driver<Int>
        let review: Driver<String>
        let keyboardWillShow: Driver<Void>
        let keyboardWillHide: Driver<Void>
        let uploadReview: Driver<(AfterWriteReviewModel, Bool)>
        let error: Driver<APIError>
    }
    
    func transform(with input: Input) -> Output {
        var content = self.editReview.isEmpty ? "" : self.editReview

        let uploadReviewError = PublishSubject<Error>()
        
        let isEditing = input.text.map {
            $0?.count ?? 0 > 0 ? true : false
        }
        
        let placeModel = ReviewWritePlaceModel(
            placeIcon: self.placeIcon,
            placeTitle: self.placeTitle,
            placeAddress: self.placeAddress
        )
        
        let reviewWritePlaceModel = Observable<ReviewWritePlaceModel>.just(placeModel)
            .asDriver(onErrorDriveWith: .empty())
        
        let restrictedText = input.text
            .map { [weak self] text in
                var newText = text ?? ""
                
                if self?.isViewWillAppear ?? false {
                    newText = self?.editReview.isEmpty ?? true ? (text ?? "") : self?.editReview ?? ""
                    self?.isViewWillAppear.toggle()
                }
                
                if newText.count > 200 {
                    let index = newText.index(newText.startIndex, offsetBy: 200)
                    let restricted = String(newText[..<index])
                    content = restricted
                    return restricted
                } else {
                    content = newText
                    return newText
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
                    return Driver<(AfterWriteReviewModel, Bool)>.empty()
                }
                
                var model = AVIROEnrollReviewDTO(
                    placeId: self.placeId,
                    userId: MyData.my.id,
                    content: content
                )
                
                if let editCommentId = self.editCommentId {
                    model.commentId = editCommentId
                    
                    return self.editReview(with: model)
                        .asDriver { error in
                            uploadReviewError.onNext(error)
                            return Driver.empty()
                        }
                }
                                
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
            reviewWritePlaceModel: reviewWritePlaceModel,
            isShowTextViewPlaceHolder: isEditing,
            textCount: textCount,
            review: restrictedText,
            keyboardWillShow: keyboardWillShow,
            keyboardWillHide: keyboardWillHide,
            uploadReview: uploadReview,
            error: error
        )
    }
    
    private func updateReview(with reviewModel: AVIROEnrollReviewDTO) -> Single<(AfterWriteReviewModel, Bool)> {

        return Single.create { single in
            AVIROAPI.manager.createReview(with: reviewModel) { [weak self] result in
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        self?.amplitude.reviewUpload(
                            with: self?.placeTitle ?? "",
                            review: reviewModel.content
                        )
                        
                        guard let myChallengeStatus = model.data else { return }
                        
                        let resultModel = AfterWriteReviewModel(
                            placeId: self?.placeId ?? "",
                            contentId: reviewModel.commentId,
                            content: reviewModel.content,
                            userId: reviewModel.userId,
                            levelUp: myChallengeStatus.levelUp,
                            userLevel: myChallengeStatus.userLevel
                        )
                        
                        single(.success((resultModel, false)))
                    } else {
                        single(.failure(APIError.clientError(1)))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func editReview(with reviewModel: AVIROEnrollReviewDTO) -> Single<(AfterWriteReviewModel, Bool)> {
        let model = AVIROEditReviewDTO(
            commentId: reviewModel.commentId,
            content: reviewModel.content,
            userId: reviewModel.userId
        )
        
        return Single.create { single in
            AVIROAPI.manager.editReview(with: model) { [weak self] result in
                switch result {
                case .success(let model):
                    if model.statusCode == 200 {
                        let resultModel = AfterWriteReviewModel(
                            placeId: self?.placeId ?? "",
                            contentId: reviewModel.commentId,
                            content: reviewModel.content,
                            userId: reviewModel.userId,
                            levelUp: false,
                            userLevel: 0
                        )
                        
                        single(.success((resultModel, true)))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
}
