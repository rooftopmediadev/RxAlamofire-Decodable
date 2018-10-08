//
//  RxAlamofire+Decodable.swift
//  RxAlamofire+Decodable
//
//  Created by Arnaud Dorgans on 08/10/2018.
//

import RxSwift
import RxAlamofire

extension ObservableType where E == (HTTPURLResponse, Data) {
    
    public func decodable<T: Decodable>(as type: T.Type? = nil, decoder: JSONDecoder? = nil) -> Observable<T> {
        return self.map { _, data in
            try (decoder ?? JSONDecoder()).decode(T.self, from: data)
        }
    }
}

extension ObservableType where E == (HTTPURLResponse, Any) {
    
    public func decodable<T: Decodable>(as type: T.Type? = nil, decoder: JSONDecoder? = nil) -> Observable<T> {
        return self.map { response, object in
            (response, try JSONSerialization.data(withJSONObject: object, options: []))
        }.decodable(as: T.self, decoder: decoder)
    }
}
