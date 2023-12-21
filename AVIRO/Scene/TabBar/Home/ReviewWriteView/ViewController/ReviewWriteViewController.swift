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
    private var viewModel: ReviewWriteViewModel!
    private var disposeBag = DisposeBag()
    
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
        
        label.text = "욕설, 비방 등 사장님과 다른 사용자들을 불쾌하게 하는 내용은 남기지 말아주세요."
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
        
        label.text = "맛, 가격, 분위기, 편의시설, 비건프렌들리함 등"
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
        
        button.backgroundColor = .keywordBlue
        button.setTitle("후기 등록하기", for: .normal)
        button.titleLabel?.font = .pretendard(size: 17, weight: .semibold)
        button.setTitleColor(.gray7, for: .normal)
        
        return button
    }()
    
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
            // TODO: placeInfoVIew 높이는 값에 따라 동적으로 다르게 설정
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
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
            self.exampleSticy.transform = CGAffineTransform(translationX: 0, y: 3)
        }
    }
    
    private func setupAttribute() {
        navigationController?.navigationBar.isHidden = false

        self.view.backgroundColor = .gray7
        self.navigationItem.title = "후기 작성"
        self.setupBack(true)
        
        if let tabBarController = self.tabBarController as? TabBarViewController {
            tabBarController.hiddenTabBar(true)
        }
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
        let textViewBiginEditing = reviewTextView.rx.didBeginEditing.asDriver()
        let text = reviewTextView.rx.text.asDriver()
        
        let input = ReviewWriteViewModel.Input(
            textViewBiginEditing: textViewBiginEditing,
            text: text
        )
        
        let output = viewModel.transform(with: input)
        
        output.isEditing
            .drive(self.rx.isEditing)
            .disposed(by: disposeBag)
        
        output.textCount
            .drive(self.rx.textCountUpdate)
            .disposed(by: disposeBag)
        
        // TODO: 쉐이크 애니메이션
        output.review
            .drive(reviewTextView.rx.text)
            .disposed(by: disposeBag)
    }
    
    func updateTextViewPlaceHolder(with isEditing: Bool) {
        placeholderLabel.isHidden = isEditing
    }
    
    func updateTextCount(with textCount: String) {
        let coloredRange = NSRange(location: 0, length: textCount.count)
        
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
                textCount,
                "/",
                "255"
            ].joined()
        )
        
        attributedText.addAttributes(
            coloredAttributes,
            range: coloredRange
        )
        attributedText.addAttributes(
            grayAttributes,
            range: NSRange(
                location: textCount.count,
                length: attributedText.length - textCount.count
            )
        )
        
        textViewCountLabel.attributedText = attributedText
    }
}

extension Reactive where Base: ReviewWriteViewController {
    var isEditing: Binder<Bool> {
        return Binder(self.base) { base, isEditing in
            base.updateTextViewPlaceHolder(with: isEditing)
        }
    }
    
    var textCountUpdate: Binder<String> {
        return Binder(self.base) { base, textCount in
            base.updateTextCount(with: textCount)
        }
    }
}
