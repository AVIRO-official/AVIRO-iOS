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
    weak var tabBarDelegate: TabBarDelegate?
    
    private var viewModel: ReviewWriteViewModel!
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
        view.layer.cornerRadius = 10
        view.textContainerInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 32,
            right: 16
        )
        view.scrollIndicatorInsets = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 32,
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
    
    private lazy var textViewCountLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "도움이 돼요 : 맛, 가격, 분위기, 편의시설, 비건프렌들리함 등"
        label.textColor = .gray2
        label.numberOfLines = 1
        label.font = .pretendard(size: 16, weight: .medium)
        
        return label
    }()
    
    private lazy var exampleSticy: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage.pointExplain
        
        return imageView
    }()
    
    private lazy var reviewUploadButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("후기 등록하기", for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .semibold)
        button.setTitleColor(.gray7, for: .normal)
        
        button.setTitleColor(.gray2, for: .disabled)
        return button
    }()
        
    private var reviewTextViewWhenKeyboardWillShow: NSLayoutConstraint!
    private var reviewTextViewWhenKeyboardWillHide: NSLayoutConstraint!
    
    private var afterViewDidLoad = false
    
    static func create(with viewModel: ReviewWriteViewModel) -> ReviewWriteViewController {
        let vc = ReviewWriteViewController()
        vc.viewModel = viewModel
        
        vc.placeInfoView.dataBinding(
            icon: viewModel.placeIcon,
            title: viewModel.placeTitle,
            address: viewModel.placeAddress
        )
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupAttribute()
        dataBinding()
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
            placeInfoView,
            reviewTextView,
            placeholderLabel,
            textViewCountLabel,
            exampleLabel,
            exampleSticy,
            reviewUploadButton
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
                constant: 20
            ),
            placeholderLabel.leadingAnchor.constraint(
                equalTo: reviewTextView.leadingAnchor,
                constant: 20
            ),
            placeholderLabel.trailingAnchor.constraint(
                equalTo: reviewTextView.trailingAnchor,
                constant: -20
            ),
            
            textViewCountLabel.bottomAnchor.constraint(
                equalTo: reviewTextView.bottomAnchor,
                constant: -16
            ),
            textViewCountLabel.trailingAnchor.constraint(
                equalTo: reviewTextView.trailingAnchor,
                constant: -16
            ),
            
            exampleLabel.topAnchor.constraint(
                equalTo: reviewTextView.bottomAnchor,
                constant: 16
            ),
            exampleLabel.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 17
            ),
            
            exampleSticy.centerXAnchor.constraint(
                equalTo: self.view.centerXAnchor
            ),
            exampleSticy.bottomAnchor.constraint(
                equalTo: reviewUploadButton.topAnchor,
                constant: -11
            ),
            
            reviewUploadButton.bottomAnchor.constraint(
                equalTo: self.view.bottomAnchor
            ),
            reviewUploadButton.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor
            ),
            reviewUploadButton.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor
            )
            
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
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
            self.exampleSticy.transform = CGAffineTransform(translationX: 0, y: 3)
        }
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
                self?.tabBarDelegate?.isHidden = (false, true)
                self?.navigationController?.popViewController(animated: true)
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
        let text = reviewTextView.rx.text.asDriver()
        
        let input = ReviewWriteViewModel.Input(
            text: text
        )
        
        let output = viewModel.transform(with: input)
        
        output.isEditing
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
    }
    
    func adjustViewForKeyboardWillShow() {
        UIView.animate(withDuration: 0.3) {
            self.reviewTextViewWhenKeyboardWillHide.isActive = false
            self.reviewTextViewWhenKeyboardWillShow.isActive = true

            self.view.layoutIfNeeded()
        }
    }

    func adjustViewForKeyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.reviewTextViewWhenKeyboardWillShow.isActive = false
            self.reviewTextViewWhenKeyboardWillHide.isActive = true

            self.view.layoutIfNeeded()
        }
    }
    
    func updateTextViewPlaceHolder(with isEditing: Bool) {
        placeholderLabel.isHidden = isEditing
    }
    
    func updateTextCount(with textCount: Int) {
        updateButtonEnable(with: textCount)
        updateTextViewCountLabel(with: textCount)
        
        if textCount == 200 {
            whenOverText()
        }
    }
    
    private func updateButtonEnable(with textCount: Int) {
        reviewUploadButton.isEnabled = textCount != 0
        reviewUploadButton.backgroundColor = textCount != 0 ? .keywordBlue : .gray5
    }
    
    private func updateTextViewCountLabel(with textCount: Int) {
        let textCountString = String(textCount)
        
        let coloredRange = NSRange(location: 0, length: textCountString.count)
        
        let coloredAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.keywordBlue,
            NSAttributedString.Key.font: UIFont.pretendard(size: 16, weight: .regular)
        ]
        
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
}

extension Reactive where Base: ReviewWriteViewController {
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
}
