//
//  RxAlamofire+Decodable.swift
//  RxAlamofire+Decodable
//
//  Created by Arnaud Dorgans on 08/10/2018.
//

import RxSwift
import Alamofire
import RxAlamofire

extension Result {
    
    init(_ block: () throws -> Value) {
        do {
            self = .success(try block())
        } catch {
            self = .failure(error)
        }
    }
}

extension Observable {
    
    static func from(_ result: Result<E>) -> Observable<E> {
        switch result {
        case .failure(let error):
            return .error(error)
        case .success(let value):
            return .just(value)
        }
    }
}

extension ObservableType where E == DataRequest {
    
    public func decodable<T: Decodable>(
        as type: T.Type? = nil,
        decoder: JSONDecoder? = nil,
        _ mapper: ((HTTPURLResponse, Data, Result<T>) -> Result<T>)? = nil)
        -> Observable<T> {
            return self.flatMap {
                $0.rx.responseData()
                }.decodable(as: type, decoder: decoder, mapper)
    }
}

extension ObservableType where E == (HTTPURLResponse, Data) {
    
    public func decodable<T: Decodable>(
        as type: T.Type? = nil,
        decoder: JSONDecoder? = nil,
        _ mapper: ((HTTPURLResponse, Data, Result<T>) -> Result<T>)? = nil) -> Observable<T> {
        return self.flatMap { response, data -> Observable<T> in
            let result = Result {
                try (decoder ?? JSONDecoder()).decode(T.self, from: data)
            }
            return Observable.from(mapper?(response, data, result) ?? result)
        }
    }
}

extension ObservableType where E == (HTTPURLResponse, Any) {
    
    public func decodable<T: Decodable>(
        as type: T.Type? = nil,
        decoder: JSONDecoder? = nil,
        _ mapper: ((HTTPURLResponse, Any, Result<T>) -> Result<T>)? = nil) -> Observable<T> {
        return self.flatMap { response, object -> Observable<T> in
            let result = Result {
                try JSONSerialization.data(withJSONObject: object, options: [])
            }
            switch result {
            case .success(let data):
                return Observable.just((response, data))
                    .decodable(as: type, decoder: decoder) { _, _, result in
                        return mapper?(response, object, result) ?? result
                }
            case .failure(let error):
                let result = Result<T>.failure(error)
                return Observable.from(mapper?(response, object, result) ?? result)
            }
        }
    }
}
