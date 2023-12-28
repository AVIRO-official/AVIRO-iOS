//
//  KakaoMapRequestManager.swift
//  VeganRestaurant
//
//  Created by 전성훈 on 2023/05/20.
//

import Foundation

final class KakaoAPI: KakaoAPIManagerProtocol {
    static let manager = KakaoAPI()
    
    var onRequest: Set<URL> = []

    let session: URLSession
    
    let api = KakaoMapRequestAPI()
    
    private var kakaoMapAPIKey: String? = {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: path) as? [String: Any],
              let key = dict["KakaoMapAPI_ Authorization _Key"] as? String else {
            return nil
        }
        return key
    }()
    
    private lazy var headers = ["Authorization": "\(kakaoMapAPIKey ?? "")"]
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func keywordSearchPlace(
        with model: KakaoKeywordSearchDTO,
        completionHandler: @escaping (Result<KakaoKeywordResultDTO, APIError>) -> Void
    ) {
        guard let url = api.searchPlace(model: model).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: headers,
            completionHandler: completionHandler)
    }
    
    func allSearchPlace(
        with model: KakaoKeywordSearchDTO,
        completionHandler: @escaping (Result<KakaoKeywordResultDTO, APIError>) -> Void
    ) {
        guard let url = api.searchLocation(model: model).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: headers,
            completionHandler: completionHandler
        )
    }
    
    func coordinateSearch(
        with model: KakaoCoordinateSearchDTO,
        completionHandler: @escaping (Result<KakaoCoordinateSearchResultDTO, APIError>) -> Void
    ) {
        guard let url = api.searchCoodinate(model: model).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: headers,
            completionHandler: completionHandler
        )
    }
    
    func addressSearch(
        with address: String,
        completionHandler: @escaping (Result<KakaoAddressPlaceDTO, APIError>) -> Void
    ) {
        guard let url = api.searchAddress(query: address).url else {
            completionHandler(.failure(.urlError))
            return
        }
        
        performRequest(
            with: url,
            headers: headers,
            completionHandler: completionHandler
        )
    }
}

extension KakaoAPI {
    func performRequest<T>(
        with url: URL,
        httpMethod: HTTPMethodType = .get,
        requestBody: Data? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping (Result<T, APIError>) -> Void
    ) where T: Decodable {
        guard !onRequest.contains(url) else { return }
        
        onRequest.insert(url)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        request.httpBody = requestBody
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.onRequest.remove(url)
            }
            
            if let error = error {
                completionHandler(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            if let apiError = self?.handleStatusCode(with: httpResponse.statusCode) {
                completionHandler(.failure(apiError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.badRequest))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(decodedObject))
            } catch {
                completionHandler(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    private func handleStatusCode(with code: Int) -> APIError? {
        switch code {
        case 100..<200:
            return APIError.informationResponse
        case 200..<300:
            return nil
        case 300..<400:
            return APIError.redirectionRequired
        case 400..<500:
            return APIError.clientError(code)
        case 500...:
            return APIError.serverError(code)
        default:
            return APIError.badRequest
        }
    }
}
