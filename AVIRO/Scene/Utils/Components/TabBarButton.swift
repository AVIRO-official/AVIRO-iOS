//
//  TabBarButton.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/12/26.
//

import UIKit

final class TabBarButton: UIButton {
    
    init(tabBarType: TabBarType) {
        super.init(frame: .zero)
        var config = defaultButtonConfig()
        config.attributedTitle = AttributedString(
            tabBarType.title,
            attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont.pretendard(size: 11, weight: .medium)
            ])
        )
        config.image = tabBarType.icon.withRenderingMode(.alwaysTemplate)
        configuration = config
        
        configurationUpdateHandler = { button in
            switch self.state {
            case .selected:
                button.configuration?.imageColorTransformer = UIConfigurationColorTransformer({ _ in
                    tabBarType.selectedColor}
                )
                button.configuration?.attributedTitle?.foregroundColor = tabBarType.selectedColor
            default:
                button.configuration?.imageColorTransformer = UIConfigurationColorTransformer({ _ in
                    tabBarType.normalColor }
                )
                button.configuration?.attributedTitle?.foregroundColor = tabBarType.normalColor
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func defaultButtonConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()
        
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .clear
        config.imagePlacement = .top
        config.imagePadding = 4
        config.contentInsets = .init(top: 5, leading: 0, bottom: 0, trailing: 0)
        
        return config
    }
}
