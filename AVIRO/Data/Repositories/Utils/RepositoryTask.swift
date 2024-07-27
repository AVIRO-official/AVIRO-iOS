//
//  RepositoryTask.swift
//  AVIRO
//
//  Created by 전성훈 on 7/6/24.
//

import Foundation

class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
