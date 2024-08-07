//
//  PlaceSummaryView.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/08/10.
//

import UIKit

private enum Text: String {
    case all = "모든 메뉴가 비건"
    case some = "일부 메뉴가 비건"
    case request = "비건 메뉴로 요청 가능"
}

final class PlaceSummaryView: UIView {
    // MARK: When Pop Up
    private lazy var guideBar: UIView = {
        let guide = UIView()
        
        guide.backgroundColor = .gray3
        guide.layer.cornerRadius = 2.5
        
        return guide
    }()
    
    private lazy var placeIcon: UIImageView = {
        let icon = UIImageView()
        
        icon.backgroundColor = .gray3
        icon.layer.cornerRadius = 10
        
        return icon
    }()
    
    private lazy var placeTitle: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .gray0
        label.clipsToBounds = true
        label.numberOfLines = 1
        label.font = .pretendard(size: 25, weight: .heavy)

        return label
    }()
    
    private lazy var placeCategory: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.clipsToBounds = true
        label.numberOfLines = 1
        label.font = .pretendard(size: 17, weight: .semibold)

        return label
    }()
    
    private lazy var placeAddressLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = .gray1
        label.clipsToBounds = true
        label.numberOfLines = 1
        label.font = .pretendard(size: 15, weight: .regular)
        
        return label
    }()

    private lazy var distanceIcon: UIImageView = {
        let icon = UIImageView()
        
        icon.image = UIImage.placeIcon
        
        return icon
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray1
        label.font = .pretendard(size: 15, weight: .regular)
        label.text = "0m"
        
        return label
    }()
    
    private lazy var reviewsIcon: UIImageView = {
        let icon = UIImageView()
        
        icon.image = UIImage.placeReviw
        
        return icon
    }()
    
    private lazy var reviewsLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray1
        label.font = .pretendard(size: 15, weight: .regular)
        label.text = "0개"
        
        return label
    }()
    
    private lazy var placeDetailStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        
        return stackView
    }()

    private lazy var starButton: UIButton = {
        let button = UIButton()
        
        button.setImage(
            UIImage.starIcon,
            for: .normal
        )
        button.setImage(
            UIImage.starIconClicked, 
            for: .selected
        )
        button.addTarget(
            self,
            action: #selector(starButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        
        button.setImage(
            UIImage.share.withTintColor(.main),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(shareButtonTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    // MARK: When Slide Up
    private lazy var whenSlideTopLabel: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 15, weight: .medium)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var whenSlideMiddleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 24, weight: .heavy)
        label.textColor = .gray0
        label.numberOfLines = 3
        label.lineBreakMode = .byCharWrapping
        
        return label
    }()
    
    // MARK: 2개로 나눠야함...
    private lazy var whenSlideBottomLabel: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 14, weight: .regular)
        label.textColor = .gray2
        
        return label
    }()
    
    // MARK: When Full
    private lazy var whenFullBackButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage.downBack, for: .normal)
        button.addTarget(self, action: #selector(fullBackButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var whenFullTitle: UILabel = {
        let label = UILabel()
        
        label.font = .pretendard(size: 18, weight: .semibold)
        label.textAlignment = .center
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 2

        return label
    }()
    
    private var viewHeightConstraint: NSLayoutConstraint?
    
    var placeViewStated: PlaceViewState = PlaceViewState.popup {
        didSet {
            switch placeViewStated {
            case .popup:
                whenSlideUpViewIsShowUI(show: false)
                whenFullHeightViewIsShowUI(show: false)
                whenPopUpViewIsShowUI(show: true)
                
                whenPopUpViewHeight()
                switchViewCorners(true)
            case .slideup:
                whenFullHeightViewIsShowUI(show: false)
                whenPopUpViewIsShowUI(show: false)
                whenSlideUpViewIsShowUI(show: true)

                whenSlideUpViewHeight()
                switchViewCorners(true)
            case .full:
                whenSlideUpViewIsShowUI(show: false)
                whenPopUpViewIsShowUI(show: false)
                whenFullHeightViewIsShowUI(show: true)

                whenFullHeightViewHeight()
                switchViewCorners(false)
            default:
                break
            }
        }
    }
    
    var whenFullBackButtonTapped: (() -> Void)?
    var whenStarButtonTapped: ((Bool) -> Void)?
    var whenShareButtonTapped: (([String]) -> Void)?
    
    var isLoadingTopView: Bool = true {
        didSet {
            if isLoadingTopView {
                    isLoadingView()
            }
        }
    }
    
    private func isLoadingView() {
        placeIcon.image = nil
        placeTitle.text = "            "
        placeTitle.backgroundColor = .gray5
        placeTitle.layer.cornerRadius = 6
        placeCategory.text = "  "
        placeCategory.backgroundColor = .gray5
        placeCategory.layer.cornerRadius = 6
        distanceLabel.text = "0m"
        reviewsLabel.text = "0개"
        placeAddressLabel.text = "  "
        placeAddressLabel.backgroundColor = .gray5
        placeAddressLabel.layer.cornerRadius = 6
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeLayout()
        makeAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Layout & Attribute
    private func makeLayout() {
        whenPopUpViewLayout()
        whenSlideUpViewLayout()
        whenFullHeightViewLayout()
    }
    
    private func makeAttribute() {
        self.backgroundColor = .gray7
        
        switchViewCorners(true)
    }
    
    // MARK: view의 top cornerRadius 설정
    private func switchViewCorners(_ switch: Bool) {
        if `switch` {
            self.layer.cornerRadius = 20
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.layer.cornerRadius = 20
        }
    }
    
    // MARK: Button Tapped Method
    @objc private func fullBackButtonTapped() {
        whenFullBackButtonTapped?()
    }
    
    @objc func starButtonTapped() {
        starButton.isSelected.toggle()
        whenStarButtonTapped?(starButton.isSelected)
        
    }
    
    @objc func shareButtonTapped() {
        guard let title = placeTitle.text,
              let address = placeAddressLabel.text else { return }
        
        let aviro = "[어비로]\n"
        let totalString = aviro + title + "\n" + address + "\n" + "https://apps.apple.com/app/6449352804"
        
        let shareObject = [totalString]
        whenShareButtonTapped?(shareObject)
    }

    // MARK: Data Binding
    func dataBinding(_ placeModel: PlaceTopModel, _ isStar: Bool) {
        placeTitle.backgroundColor = .gray7
        placeTitle.layer.cornerRadius = 0
        placeCategory.backgroundColor = .gray7
        placeCategory.layer.cornerRadius = 0
        placeAddressLabel.backgroundColor = .gray7
        placeAddressLabel.layer.cornerRadius = 0
        
        if isStar {
            starButton.isSelected = true
        } else {
            starButton.isSelected = false
        }
        
        var placeIconImage: UIImage?
        var whenSlideTopLabelString: String?

        // TODO: - vegan 또는 category enum refectoring 필요
        switch placeModel.placeState {
        case .All:
            switch placeModel.category {
            case .Bar:
                placeIconImage = UIImage.allBoxBar
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.all.rawValue
            case .Bread:
                placeIconImage = UIImage.allBoxBread
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.all.rawValue
            case .Coffee:
                placeIconImage = UIImage.allBoxCoffee
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.all.rawValue
            case .Restaurant:
                placeIconImage = UIImage.allBoxRestaurant
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.all.rawValue
            }
            placeCategory.textColor = .all
            
            whenSlideTopLabel.textColor = .all
            whenSlideTopLabelString = Text.all.rawValue
        case .Some:
            switch placeModel.category {
            case .Bar:
                placeIconImage = UIImage.someBoxBar
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.some.rawValue
            case .Bread:
                placeIconImage = UIImage.someBoxBread
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.some.rawValue
            case .Coffee:
                placeIconImage = UIImage.someBoxCoffee
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.some.rawValue
            case .Restaurant:
                placeIconImage = UIImage.someBoxRestaurant
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.some.rawValue
            }
            placeCategory.textColor = .some
            
            whenSlideTopLabel.textColor = .some
            whenSlideTopLabelString = Text.some.rawValue
            
        case .Request:
            switch placeModel.category {
            case .Bar:
                placeIconImage = UIImage.requestBoxBar
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.request.rawValue
            case .Bread:
                placeIconImage = UIImage.requestBoxBread
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.request.rawValue
            case .Coffee:
                placeIconImage = UIImage.requestBoxCoffee
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.request.rawValue
            case .Restaurant:
                placeIconImage = UIImage.requestBoxRestaurant
                placeCategory.text = placeModel.placeCategory + " ‧ " + Text.request.rawValue
            }
            placeCategory.textColor = .request
            
            whenSlideTopLabel.textColor = .request
            whenSlideTopLabelString = Text.request.rawValue
        }
                
        placeIcon.image = placeIconImage
        
        placeTitle.text = placeModel.placeTitle
        distanceLabel.text = placeModel.distance
        reviewsLabel.text = placeModel.reviewsCount + "개"
        placeAddressLabel.text = placeModel.address
        
        whenSlideMiddleLabel.text = placeModel.placeTitle
        whenSlideTopLabel.text = whenSlideTopLabelString
        whenSlideBottomLabel.text = placeModel.distance + " " + placeModel.placeCategory
        
        whenFullTitle.text = placeModel.placeTitle
    }
        
    func updateReviewsCount(_ count: Int) {
        self.reviewsLabel.text = "\(count)개"
    }
    
    func updateMapPlace(_ mapPlace: VeganType) {
        var placeIconImage: UIImage?
        var whenSlideTopLabelString: String?
        
        switch mapPlace {
        case .All:
            placeIconImage = UIImage.allBox
            whenSlideTopLabel.textColor = .all
            whenSlideTopLabelString = Text.all.rawValue
            
            placeCategory.textColor = .all
        case .Some:
            placeIconImage = UIImage.someBox
            whenSlideTopLabel.textColor = .some
            whenSlideTopLabelString = Text.some.rawValue
            
            placeCategory.textColor = .some
        case .Request:
            placeIconImage = UIImage.requestBox
            whenSlideTopLabel.textColor = .request
            whenSlideTopLabelString = Text.request.rawValue
            
            placeCategory.textColor = .request
        }
        
        placeIcon.image = placeIconImage
        whenSlideTopLabel.text = whenSlideTopLabelString
    }
}

// MARK: When View Pop up
extension PlaceSummaryView {
    // MARK: When Popup View Layout
    private func whenPopUpViewLayout() {
        [
            distanceIcon,
            distanceLabel,
            reviewsIcon,
            reviewsLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            placeDetailStackView.addArrangedSubview($0)
        }
        
        [
            guideBar,
            placeIcon,
            placeTitle,
            placeCategory,
            placeAddressLabel,
            placeDetailStackView,
            starButton,
            shareButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // guide
            guideBar.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 5
            ),
            guideBar.centerXAnchor.constraint(
                equalTo: self.centerXAnchor
            ),
            guideBar.heightAnchor.constraint(equalToConstant: 5),
            guideBar.widthAnchor.constraint(equalToConstant: 36),
            
            // placeIcon
            placeIcon.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 20
            ),
            placeIcon.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 30
            ),
            placeIcon.widthAnchor.constraint(equalToConstant: 52),
            placeIcon.heightAnchor.constraint(equalToConstant: 52),
            
            // placeTitle
            placeTitle.leadingAnchor.constraint(
                equalTo: placeIcon.trailingAnchor,
                constant: 15
            ),
            placeTitle.topAnchor.constraint(equalTo: placeIcon.topAnchor),
            placeTitle.trailingAnchor.constraint(
                equalTo: starButton.leadingAnchor,
                constant: -6
            ),
            
            // placeCategory
            placeCategory.leadingAnchor.constraint(equalTo: placeTitle.leadingAnchor),
            placeCategory.topAnchor.constraint(equalTo: placeTitle.bottomAnchor, constant: 5),
            placeCategory.trailingAnchor.constraint(equalTo: placeTitle.trailingAnchor),
            
            // addressLabel
            placeAddressLabel.topAnchor.constraint(
                equalTo: placeCategory.bottomAnchor,
                constant: 10
            ),
            placeAddressLabel.leadingAnchor.constraint(equalTo: placeTitle.leadingAnchor),
            placeAddressLabel.trailingAnchor.constraint(equalTo: placeTitle.trailingAnchor),
            
            // placeDetailStackView
            placeDetailStackView.topAnchor.constraint(
                equalTo: placeAddressLabel.bottomAnchor,
                constant: 5
            ),
            placeDetailStackView.leadingAnchor.constraint(
                equalTo: placeTitle.leadingAnchor
            ),
            placeDetailStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: shareButton.leadingAnchor,
                constant: 6
            ),
            
            // star Button
            starButton.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 30
            ),
            starButton.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -20
            ),
            starButton.widthAnchor.constraint(equalToConstant: 38),
            starButton.heightAnchor.constraint(equalToConstant: 38),
            
            // share Button
            shareButton.topAnchor.constraint(equalTo: starButton.bottomAnchor),
            shareButton.trailingAnchor.constraint(equalTo: starButton.trailingAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 38),
            shareButton.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    
    // MARK: When PopUp View is Show UI
    private func whenPopUpViewIsShowUI(show: Bool) {
        let show = !show
        
        guideBar.isHidden = show
        placeIcon.isHidden = show
        placeTitle.isHidden = show
        placeCategory.isHidden = show
        placeDetailStackView.isHidden = show
        placeAddressLabel.isHidden = show
        starButton.isHidden = show
        shareButton.isHidden = show
    }
    
    // MARK: When Popup View Height
    // TODO: 수정 필요 - address frame 못 불러옴
    private func whenPopUpViewHeight() {
        viewHeightConstraint?.isActive = false

        let guideBarHeight = guideBar.frame.height
        let placeIconHeight = placeIcon.frame.height
        let placeAddressLabelHeight = CGFloat(15)
        let placeStackViewHeight = CGFloat(15)

        // 30 + 10 + 5 + 20
        let inset: CGFloat = 75

        let totalHeight = guideBarHeight + placeIconHeight + placeAddressLabelHeight + placeStackViewHeight + inset

        viewHeightConstraint = self.heightAnchor.constraint(equalToConstant: totalHeight)
        viewHeightConstraint?.isActive = true
    }
}

// MARK: When View Slide up
extension PlaceSummaryView {
    // MARK: When Slideup View Layout
    private func whenSlideUpViewLayout() {
        [
            whenSlideTopLabel,
            whenSlideMiddleLabel,
            whenSlideBottomLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            whenSlideTopLabel.topAnchor.constraint(equalTo: placeIcon.topAnchor),
            whenSlideTopLabel.leadingAnchor.constraint(equalTo: placeIcon.trailingAnchor, constant: 15),
            whenSlideTopLabel.trailingAnchor.constraint(equalTo: starButton.leadingAnchor, constant: -15),
            
            whenSlideMiddleLabel.topAnchor.constraint(equalTo: whenSlideTopLabel.bottomAnchor, constant: 5),
            whenSlideMiddleLabel.leadingAnchor.constraint(equalTo: placeIcon.trailingAnchor, constant: 15),
            whenSlideMiddleLabel.trailingAnchor.constraint(equalTo: starButton.leadingAnchor, constant: -15),
            
            whenSlideBottomLabel.topAnchor.constraint(equalTo: whenSlideMiddleLabel.bottomAnchor, constant: 7.5),
            whenSlideBottomLabel.leadingAnchor.constraint(equalTo: placeIcon.trailingAnchor, constant: 15),
            whenSlideBottomLabel.trailingAnchor.constraint(equalTo: starButton.leadingAnchor, constant: -15)
        ])
        
        whenSlideTopLabel.isHidden = true
        whenSlideMiddleLabel.isHidden = true
        whenSlideBottomLabel.isHidden = true
    }
    
    private func whenSlideUpViewIsShowUI(show: Bool) {
        let show = !show
        
        guideBar.isHidden = show
        placeIcon.isHidden = show
        starButton.isHidden = show
        shareButton.isHidden = show
        whenSlideTopLabel.isHidden = show
        whenSlideMiddleLabel.isHidden = show
        whenSlideBottomLabel.isHidden = show
    }
    
    private func whenSlideUpViewHeight() {
        let topHeight = whenSlideTopLabel.frame.height
        let middleHeight = whenSlideMiddleLabel.frame.height
        let bottomHeight = whenSlideBottomLabel.frame.height
        // 30 + 5 + 7.5 + 28
        let inset: CGFloat = 70.5
        
        let totalHeight = topHeight + middleHeight + bottomHeight + inset
        
        viewHeightConstraint?.constant = totalHeight
        viewHeightConstraint?.isActive = true
    }
    
}

// MARK: When View Full up {
extension PlaceSummaryView {
    // MARK: When Full Height View
    private func whenFullHeightViewLayout() {
        [
            whenFullBackButton,
            whenFullTitle
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            whenFullBackButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            whenFullBackButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            
            whenFullTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            whenFullTitle.topAnchor.constraint(equalTo: whenFullBackButton.topAnchor),
            whenFullTitle.leadingAnchor.constraint(equalTo: whenFullBackButton.trailingAnchor, constant: 16),
            whenFullTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -56)
        ])
        
        whenFullBackButton.isHidden = true
        whenFullTitle.isHidden = true
    }
    
    private func whenFullHeightViewIsShowUI(show: Bool) {
        let show = !show

        whenFullBackButton.isHidden = show
        whenFullTitle.isHidden = show
    }
    
    private func whenFullHeightViewHeight() {
        let titleHeight = whenFullTitle.frame.height
        
        // 18 + 18
        let inset: CGFloat = 36
        
        let totalHeight = titleHeight + inset
        
        viewHeightConstraint?.constant = totalHeight
        viewHeightConstraint?.isActive = true
    }
}
