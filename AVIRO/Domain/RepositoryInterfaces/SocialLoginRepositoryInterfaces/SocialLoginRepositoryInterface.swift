//
//  SocialLoginRepositoryInterface.swift
//  AVIRO
//
//  Created by 전성훈 on 5/30/24.
//

import Foundation

protocol SocialLoginRepositoryInterface {
    func login(
        requestLogin: () -> Void,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    func logout(completion: @escaping (Result<String, Error>) -> Void)
}
