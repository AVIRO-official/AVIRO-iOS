//
//  MyCommentListTableViewCell.swift
//  AVIRO
//
//  Created by 전성훈 on 2024/03/04.
//

import UIKit

final class MyCommentListTableViewCell: UITableViewCell {
    static let identifier = MyCommentListTableViewCell.description()
        
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 10.3
        view.clipsToBounds = true
        
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 20, weight: .bold)
        lbl.numberOfLines = 1
        lbl.textColor = .gray0
        
        return lbl
    }()
    
    private lazy var dotsButton: UIButton = {
        let btn = UIButton()
        
        btn.setImage(.dots, for: .normal)
        btn.addTarget(self, action: #selector(tappedDotsButton), for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var enrollTimeLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.textAlignment = .left
        lbl.font = .pretendard(size: 14, weight: .regular)
        lbl.numberOfLines = 1
        lbl.textColor = .gray3
        
        return lbl
    }()
    
    // TODO: - 네이밍 변경 필요
    private lazy var reviewTextView: UILabel = {
        let view = UILabel()
        
        view.textAlignment = .left
        view.font = .pretendard(size: 15, weight: .regular)
        view.textColor = .gray2
        view.numberOfLines = 0
        view.lineBreakMode = .byCharWrapping
        
        return view
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .gray7
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
       
        view.backgroundColor = .gray6
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        setupAttribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    private var test: Bool = true
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if test && mainView.frame.height != 0 {
            test.toggle()
            print(reviewTextView.countCurrentLines())
            print(enrollTimeLabel.frame)
            
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        initConfiguration()
    }
    
    private func setupLayout() {
        [
            mainView,
            separatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            
            separatorView.topAnchor.constraint(equalTo: mainView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        [
            iconImageView,
            titleLabel,
            dotsButton,
            enrollTimeLabel,
            reviewTextView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            mainView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 59),
            iconImageView.heightAnchor.constraint(equalToConstant: 59),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: dotsButton.leadingAnchor, constant: -14),
            
            dotsButton.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            dotsButton.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16),
            dotsButton.widthAnchor.constraint(equalToConstant: 24),
            dotsButton.heightAnchor.constraint(equalToConstant: 24),
            
            enrollTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            enrollTimeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            enrollTimeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            reviewTextView.topAnchor.constraint(equalTo: enrollTimeLabel.bottomAnchor, constant: 6),
            reviewTextView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            reviewTextView.trailingAnchor.constraint(equalTo: dotsButton.trailingAnchor),
            reviewTextView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupAttribute() {
        self.backgroundColor = .clear
    }
    
    private func initConfiguration() {
        iconImageView.image = nil
        
        titleLabel.text = ""
        enrollTimeLabel.text = ""
        
        reviewTextView.text = ""
    }

    @objc private func tappedDotsButton(_ sender: UIButton) {
        
    }
    
    func configuration(with model: MyCommentCellModel) {
        iconImageView.image = .allBoxBar
        
        titleLabel.text = model.title
        enrollTimeLabel.text = model.date
        
        reviewTextView.text = model.content
        
        layoutIfNeeded()
    }
}
