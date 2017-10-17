//
//  API.swift
//  StripeAPI
//
//  Created by 1amageek on 2017/10/01.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//

import Foundation
import APIKit
import Stripe
import Result

public protocol StripeAPI: Request {
    var secretKey: String { get }
}

extension StripeAPI {

    public var baseURL: URL {
        return URL(string: "https://api.stripe.com/v1")!
    }

    public var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    // Stripe Secret key
    public var secretKey: String {
        return Configuration.shared.secretKey
    }

    var encodedKey: String {
        let data: Data = self.secretKey.data(using: String.Encoding.utf8)!
        return data.base64EncodedString()
    }

    public var bodyParameters: BodyParameters? {
        guard let parameters = self.parameters as? [String: Any], !self.method.prefersQueryParameters else {
            return nil
        }
        return FormURLEncodedBodyParameters(formObject: parameters)
    }

    public var dataParser: DataParser {
        return DecodableDataParser()
    }

    @discardableResult
    public func send(_ block: @escaping (Result<Self.Response, SessionTaskError>) -> Void) -> SessionTask? {
        return Session.send(self, callbackQueue: .main, handler: block)
    }
}

final class StripeAPIEncoder: BodyParameters {

    var contentType: String {
        return "application/json"
    }

    let from: Encodable

    init(from: Encodable) {
        self.from = from
    }

    func buildEntity() throws -> RequestBodyEntity {
        return .data(try JSONEncoder().encode(""))
    }
}

public enum StripeAPIError: Error {
    case network
}

final class DecodableDataParser: DataParser {
    var contentType: String? {
        return "application/json"
    }

    func parse(data: Data) throws -> Any {
        return data
    }
}

extension StripeAPI where Response: Decodable {
    public func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        if let string = String(data: data, encoding: .utf8) {
            print("response: \(string)")
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

/**
 Create a customer
 */
struct CreateCustomer: StripeAPI {

    typealias Response = STPCustomer

    var description: String?

    var source: String?

    var email: String?

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/customers"
    }

    var queryParameters: [String : Any]? {

        var parameters: [String: Any] = [:]

        if let description: String = description {
            parameters["description"] = description
        }

        if let source: String = source {
            parameters["source"] = source
        }

        if let email: String = email {
            parameters["email"] = email
        }

        return parameters
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> STPCustomer {
        let deserializer: STPCustomerDeserializer = STPCustomerDeserializer(jsonResponse: object)
        if let _: Error = deserializer.error {
            throw ResponseError.unexpectedObject(object)
        }
        return deserializer.customer!
    }
}

/**
 Retrieve a customer
 */
struct GetCustomer: StripeAPI {

    typealias Response = STPCustomer

    let id: String

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/customers/\(id)"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> STPCustomer {
        debugPrint(object)
        let deserializer: STPCustomerDeserializer = STPCustomerDeserializer(jsonResponse: object)
        if let _: Error = deserializer.error {
            throw ResponseError.unexpectedObject(object)
        }
        return deserializer.customer!
    }
}

/**
 Update a customer sources
 */

struct UpdateCustomerSource: StripeAPI {

    typealias Response = Card

    let customer: String

    let source: String

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/customers/\(customer)/sources"
    }

    var parameters: Any? {
        return [
            "source": self.source
        ]
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

/**
 Update a customer
 */

struct UpdateCustomer: StripeAPI {

    typealias Response = Customer

    let customer: String

    let parames: [AnyHashable: Any]

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/customers/\(customer)"
    }

    var parameters: Any? {
        return self.parames
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

/**
 Create a charge
 */
struct CreateCharge: StripeAPI {

    typealias Response = Charge

    let amount: Int

    let currency: String

    let customer: String

    var description: String?

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/charges"
    }

    var parameters: Any? {

        var parameters: [String: Any] = [
            "amount": self.amount,
            "currency": self.currency,
            "customer": self.customer
        ]

        if let description: String = description {
            parameters["description"] = description
        }

        return parameters
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

/**
 Retrieve a card
 */
struct GetCard: StripeAPI {

    typealias Response = Card

    let customer: String

    let card: String

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/customers/\(customer)/sources/\(card)"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct RetriveSKU: StripeAPI {

    typealias Response = SKU

    let skuID: String

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/skus/\(skuID)"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

struct RetriveProduct: StripeAPI {
    typealias Response = Product

    let productId: String

    var headerFields: [String : String] {
        return ["authorization": "Basic \(encodedKey)"]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/products/\(productId)"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let data: Data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
