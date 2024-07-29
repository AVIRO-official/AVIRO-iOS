//
//  printIfDebug.swift
//  AVIRO
//
//  Created by 전성훈 on 5/10/24.
//

func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
