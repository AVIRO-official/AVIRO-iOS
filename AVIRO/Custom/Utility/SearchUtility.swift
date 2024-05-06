//
//  SearchUtility.swift
//  AVIRO
//
//  Created by 전성훈 on 5/1/24.
//

import Foundation

extension RandomAccessCollection where Element == MarkerModel, Index == Int {
    func binarySearchByPlaceId(for placeId: String, in range: Range<Index>? = nil) -> Index? {
        let range = range ?? startIndex..<endIndex
        
        guard range.lowerBound < range.upperBound else { return nil }
        
        let size = distance(from: range.lowerBound, to: range.upperBound)
        let middle = index(range.lowerBound, offsetBy: size/2)
        
        if self[middle].placeId == placeId {
            return middle
        } else if self[middle].placeId > placeId {
            return binarySearchByPlaceId(for: placeId, in: range.lowerBound..<middle)
        } else {
            return binarySearchByPlaceId(for: placeId, in: index(after: middle)..<range.upperBound)
        }
    }
}
