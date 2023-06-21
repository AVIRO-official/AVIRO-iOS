//
//  DetailViewPresenter.swift
//  AVIRO
//
//  Created by 전성훈 on 2023/05/27.
//

import UIKit

protocol DetailViewProtocol: NSObject {
    func bindingData()
    func makeLayout()
    func makeAttribute()
    func showOthers()
    func updateComment(_ model: VeganModel?)
}

final class DetailViewPresenter {
    weak var viewController: DetailViewProtocol?
    
    private let aviroManager = AVIROAPIManager()
    
    var placeId: String?
    
    var placeModel: PlaceData?
    var menuModel: [MenuArray]?
    var commentModel: [CommentArray]?
    
    init(viewController: DetailViewProtocol, placeId: String? = nil) {
        self.viewController = viewController
        self.placeId = placeId
    }
    // MARK: ViewDidLoad()
    func viewDidLoad() {
        viewController?.bindingData()
        viewController?.makeLayout()
        viewController?.makeAttribute()
        viewController?.showOthers()
    }
    
    // MARK: Place Info 불러오기
    func loadPlaceInfo(completionHandler: @escaping ((PlaceData) -> Void)) {
        guard let placeId = placeId else { return }
        aviroManager.getPlaceInfo(placeId: placeId
        ) { [weak self] placeModel in
            self?.placeModel = placeModel.data
            completionHandler(placeModel.data)
        }
    }
    
    // MARK: Menu Info 불러오기
    func loadMenuInfo(completionHandler: @escaping (([MenuArray]) -> Void)) {
        guard let placeId = placeId else { return }
        aviroManager.getMenuInfo(placeId: placeId
        ) { [weak self] menuModel in
            self?.menuModel = menuModel.data.menuArray
            completionHandler(menuModel.data.menuArray)
        }
    }
    
    // MARK: Comment Info 불러오기
    func loadCommentInfo(completionHandler: @escaping (([CommentArray]) -> Void)) {
        guard let placeId = placeId else { return }
        aviroManager.getCommentInfo(placeId: placeId
        ) { [weak self] commentModel in
            self?.commentModel = commentModel.data.commentArray
            commentModel(commentModel.data.commentArray)
        }
    }
//
//    func reloadVeganModel(_ model: VeganModel) {
//        veganModel = model
//        viewController?.updateComment(veganModel)
//    }
}
