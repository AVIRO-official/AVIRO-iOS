//
//  ReviewWriteViewController.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/19.
//

// MARK: Count 바인딩, textview text 바인딩, 등록 바인딩
import RxSwift
import RxCocoa

final class ReviewWriteViewController: UIViewController {
    weak var tabBarDelegate: TabBarFromSubVCDelegate?
    weak var homeViewDelegate: AfterHomeViewControllerProtocol?
    
    private var viewModel: ReviewWritableViewModel!
    private let disposeBag = DisposeBag()
        
    private lazy var placeInfoView: ReviewPlaceInfoView = {
        let view = ReviewPlaceInfoView()
        
        return view
    }()
    
    private lazy var reviewTextView: UITextView = {
        let view = UITextView()
        
        view.textColor = .gray0
        view.textContainer.lineBreakMode = .byCharWrapping
        view.font = .pretendard(size: 16, weight: .regular)
        view.backgroundColor = .gray6
        view.roundTopCorners(cornerRadius: 10)
        view.textContainerInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 0,
            right: 16
        )
        view.scrollIndicatorInsets = UIEdgeInsets(
            top: 8,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "사장님과 다른 사용자들이 상처받지 않도록 좋은 표현을 사용해주세요."
        label.textColor = .gray5
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.font = .pretendard(size: 16, weight: .regular)
        label.isHidden = !reviewTextView.text.isEmpty
        
        return label
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
       
        stackView.backgroundColor = .gray6
        stackView.roundBottomCorners(cornerRadius: 10)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: 8,
            left: 16,
            bottom: 8,
            right:  16
        )
        
        return stackView
    }()
    
    private lazy var expainTextCountLabel: UILabel = {
        let label = UILabel()
        
        label.text = " * 최소 10글자 이상"
        label.textAlignment = .left
        label.textColor = .gray3
        label.numberOfLines = 1
        label.font = .pretendard(size: 12, weight: .medium)
        
        return label
    }()
    
    private lazy var textViewCountLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .right
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "도움이 돼요 : 맛, 가격, 분위기, 편의시설, 비건프렌들리함 등"
        label.textColor = .gray2
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        label.font = .pretendard(size: 16, weight: .medium)
        
        return label
    }()
    
    private lazy var challengeSticker: ChallengeNameStickerView = {
        let view = ChallengeNameStickerView()
               
        view.isHidden = true
        
        return view
    }()
    
    private lazy var reviewUploadButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("후기 등록하기", for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .semibold)
        button.setTitleColor(.gray7, for: .normal)
        
        button.setTitleColor(.gray2, for: .disabled)
        return button
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        
        view.style = .large
        view.color = .gray5
        view.startAnimating()
        view.isHidden = true
        
        return view
    }()
        
    private var reviewTextViewWhenKeyboardWillShow: NSLayoutConstraint!
    private var reviewTextViewWhenKeyboardWillHide: NSLayoutConstraint!
    
    private var afterViewDidLoad = false
    
    static func create(with viewModel: ReviewWritableViewModel) -> ReviewWriteViewController {
        let vc = ReviewWriteViewController()
        
        vc.viewModel = viewModel
        vc.dataBinding()
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !afterViewDidLoad {
            afterViewDidLoad.toggle()
            afterViewDidLoadLayout()
        }
    }
    
    private func setupLayout() {
        [
            expainTextCountLabel,
            textViewCountLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomStackView.addArrangedSubview($0)
        }
        
        [
            placeInfoView,
            reviewTextView,
            placeholderLabel,
            bottomStackView,
            exampleLabel,
            challengeSticker,
            reviewUploadButton,
            indicatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeInfoView.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                constant: 20
            ),
            placeInfoView.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            placeInfoView.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),

            reviewTextView.topAnchor.constraint(
                equalTo: placeInfoView.bottomAnchor,
                constant: 20
            ),
            reviewTextView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 16
            ),
            reviewTextView.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -16
            ),
            
            placeholderLabel.topAnchor.constraint(
                equalTo: reviewTextView.topAnchor,
                constant: 18
            ),
            placeholderLabel.leadingAnchor.constraint(
                equalTo: reviewTextView.leadingAnchor,
                constant: 22
            ),
            placeholderLabel.trailingAnchor.constraint(
                equalTo: reviewTextView.trailingAnchor,
                constant: -20
            ),
            
            bottomStackView.topAnchor.constraint(
                equalTo: reviewTextView.bottomAnchor
            ),
            bottomStackView.leadingAnchor.constraint(
                equalTo: reviewTextView.leadingAnchor
            ),
            bottomStackView.trailingAnchor.constraint(
                equalTo: reviewTextView.trailingAnchor
            ),
            
            exampleLabel.topAnchor.constraint(
                equalTo: bottomStackView.bottomAnchor,
                constant: 16
            ),
            exampleLabel.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 17
            ),
            exampleLabel.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -16
            ),
            
            challengeSticker.centerXAnchor.constraint(
                equalTo: self.view.centerXAnchor
            ),
            challengeSticker.bottomAnchor.constraint(
                equalTo: reviewUploadButton.topAnchor,
                constant: -10
            ),
            
            reviewUploadButton.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor
            ),
            reviewUploadButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor
            ),
            reviewUploadButton.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor
            ),
            
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        reviewTextViewWhenKeyboardWillShow = self.reviewTextView.topAnchor.constraint(
            equalTo: self.view.safeAreaLayoutGuide.topAnchor
        )
        reviewTextViewWhenKeyboardWillHide = self.reviewTextView.topAnchor.constraint(
            equalTo: self.placeInfoView.bottomAnchor,
            constant: 20
        )
        
        reviewTextViewWhenKeyboardWillShow.isActive = false
        reviewTextViewWhenKeyboardWillHide.isActive = true
    }
    
    private func setupAttribute() {
        let tapGesture = UITapGestureRecognizer()

        tapGesture.rx.event.bind { [weak self] _ in
            self?.view.endEditing(true)
        }.disposed(by: disposeBag)

        view.addGestureRecognizer(tapGesture)
        
        navigationController?.navigationBar.isHidden = false

        self.view.backgroundColor = .gray7
        self.navigationItem.title = "후기 작성"

        let backButton = UIButton()
        
        // TODO: 후기 등록할때도 hidden 메서드 추가하기
        backButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.popViewController()
            })
            .disposed(by: disposeBag)
        
        backButton.setImage(
            UIImage.back,
            for: .normal
        )
        backButton.frame = .init(
            x: 0,
            y: 0,
            width: 24,
            height: 24
        )
        
        let barButtonItem = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    private func afterViewDidLoadLayout() {
        let height = self.view.frame.height
        
        NSLayoutConstraint.activate([
            reviewUploadButton.heightAnchor.constraint(
                equalToConstant: 60 + self.view.safeAreaInsets.bottom
            ),
            
            height > 750 ?
            reviewTextView.heightAnchor.constraint(equalToConstant: 320)
            :
                reviewTextView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func dataBinding() {
        let viewDidLoadTrigger = self.rx.viewDidLoad
            .map { _ in }
            .asDriver(onErrorDriveWith: .empty())
        
        let text = reviewTextView.rx.text.asDriver()
        
        let updateReview = reviewUploadButton.rx
            .controlEvent(.touchUpInside)
            .asDriver()
            .do { [weak self] _ in
                self?.startLoading()
            }
        
        let input = ReviewWritableViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger,
            text: text,
            uploadReview: updateReview
        )
        
        let output = viewModel.transform(with: input)
        
        output.challengeName
            .drive(self.rx.loadChallengeName)
            .disposed(by: disposeBag)
        
        output.reviewWritePlaceModel
            .drive(self.rx.updatePlaceInfo)
            .disposed(by: disposeBag)
        
        output.isShowTextViewPlaceHolder
            .drive(self.rx.isEditing)
            .disposed(by: disposeBag)
        
        output.textCount
            .drive(self.rx.textCountUpdate)
            .disposed(by: disposeBag)
        
        output.review
            .drive(reviewTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.keyboardWillShow
            .drive(self.rx.keyboardWillShow)
            .disposed(by: disposeBag)

        output.keyboardWillHide
            .drive(self.rx.keyboardWillHide)
            .disposed(by: disposeBag)
        
        output.uploadReview
            .drive(self.rx.uploadReview)
            .disposed(by: disposeBag)
        
        output.error
            .drive(self.rx.isErrorShow)
            .disposed(by: disposeBag)
    }
    
    internal func updateChallengeName(with challenge: String) {
        challengeSticker.isHidden = challenge == "" ? true : false
        
        challengeSticker.bindingChallengeName(with: challenge)
    }
    
    internal func updatePlaceInfo(with model: ReviewWritePlaceModel) {
        placeInfoView.dataBinding(
            icon: model.placeIcon,
            title: model.placeTitle,
            address: model.placeAddress
        )
    }
    
    internal func adjustViewForKeyboardWillShow() {
        UIView.animate(withDuration: 0.3) {
            self.reviewTextViewWhenKeyboardWillHide.isActive = false
            self.reviewTextViewWhenKeyboardWillShow.isActive = true

            self.view.layoutIfNeeded()
        }
    }

    internal func adjustViewForKeyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.reviewTextViewWhenKeyboardWillShow.isActive = false
            self.reviewTextViewWhenKeyboardWillHide.isActive = true

            self.view.layoutIfNeeded()
        }
    }
    
    internal func updateTextViewPlaceHolder(with isEditing: Bool) {
        placeholderLabel.isHidden = isEditing
    }
    
    internal func updateTextCount(with textCount: Int) {
        updateButtonEnable(with: textCount)
        updateTextViewCountLabel(with: textCount)
        
        if textCount == 200 {
            whenOverText()
        }
    }
    
    private func updateButtonEnable(with textCount: Int) {
        reviewUploadButton.isEnabled = textCount >= 10
        reviewUploadButton.backgroundColor = textCount >= 10 ? .keywordBlue : .gray5
    }
    
    private func updateTextViewCountLabel(with textCount: Int) {
        let textCountString = String(textCount)
        
        let coloredRange = NSRange(location: 0, length: textCountString.count)
        
        var coloredAttributes: [NSAttributedString.Key: NSObject] = [:]
        
        switch textCount {
        case 0:
            coloredAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.gray3,
                NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .regular)
            ]
        case 1...9:
            coloredAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.warning,
                NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .regular)
            ]
        default:
            coloredAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.keywordBlue,
                NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .regular)
            ]
        }
       
        let grayAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray3,
            NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .regular)
        ]
        
        let attributedText = NSMutableAttributedString(
            string: [
                textCountString,
                "/",
                "200"
            ].joined()
        )
        
        attributedText.addAttributes(
            coloredAttributes,
            range: coloredRange
        )
        attributedText.addAttributes(
            grayAttributes,
            range: NSRange(
                location: textCountString.count,
                length: attributedText.length - textCountString.count
            )
        )
        
        textViewCountLabel.attributedText = attributedText
    }
    
    private func whenOverText() {
        reviewTextView.activeHshakeEffect()
    }
    
    func afterSuccessUploadReview(with model: (AfterWriteReviewModel, Bool)) {
        homeViewDelegate?.showRecommendPlaceAlert(with: model)
        
        popViewController()
    }
    
    private func popViewController() {
        endLoading()
        tabBarDelegate?.isHidden = (false, true)
        navigationController?.popViewController(animated: true)
    }
    
    func afterErrorShow(with error: APIError) {
        endLoading()
        switch error {
        case .clientError(1):
            showAlert(title: "에러", message: "중복 등록된 후기 입니다.")
        default:
            showAlert(title: "에러", message: error.localizedDescription)
        }
    }
    
    private func startLoading() {
        indicatorView.isHidden = false
        reviewUploadButton.isEnabled = false
        reviewUploadButton.backgroundColor = .gray5
    }

    private func endLoading() {
        indicatorView.isHidden = true
        reviewUploadButton.isEnabled = true
        reviewUploadButton.backgroundColor = .keywordBlue
    }
}

extension Reactive where Base: ReviewWriteViewController {
    var loadChallengeName: Binder<String> {
        return Binder(self.base) { base, model in
            base.updateChallengeName(with: model)
        }
    }
    
    var updatePlaceInfo: Binder<ReviewWritePlaceModel> {
        return Binder(self.base) { base, model in
            base.updatePlaceInfo(with: model)
        }
    }
    
    var isEditing: Binder<Bool> {
        return Binder(self.base) { base, isEditing in
            base.updateTextViewPlaceHolder(with: isEditing)
        }
    }
    
    var textCountUpdate: Binder<Int> {
        return Binder(self.base) { base, textCount in
            base.updateTextCount(with: textCount)
        }
    }
    
    var keyboardWillShow: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.adjustViewForKeyboardWillShow()
        }
    }
    
    var keyboardWillHide: Binder<Void> {
        return Binder(self.base) { base, _ in
            base.adjustViewForKeyboardWillHide()
        }
    }
    
    var uploadReview: Binder<(AfterWriteReviewModel, Bool)> {
        return Binder(self.base) { base, model in
            base.afterSuccessUploadReview(with: model)
        }
    }
    
    var isErrorShow: Binder<APIError> {
        return Binder(self.base) { base, error in
            base.afterErrorShow(with: error)
        }
    }
}
