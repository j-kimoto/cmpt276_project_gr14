//
//  IterateEnum.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/* Used for iterating over enums (unit tests)
   Use the EnumCollection protocol for your enum E, then write Array(E.cases())
   Source https://stackoverflow.com/questions/24007461/how-to-enumerate-an-enum-with-string-type/32429125#32429125 */

protocol EnumCollection : Hashable {}
extension EnumCollection {
    static func cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current : Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}
