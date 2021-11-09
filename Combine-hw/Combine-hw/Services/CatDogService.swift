//
//  CatDogService.swift
//  Combine-hw
//
//  Created by wrustem on 09.11.2021.
//

import Foundation
import Combine
import UIKit

class CatDogService {
    
    @Published
    var dog: UIImage?
    
    @Published
    var cat: String?
    
    @Published
    var counter = (cat: 0,dog: 0)
    
    private let catURL = URL(string: "https://catfact.ninja/fact")!
    private let dogURL = URL(string: "https://dog.ceo/api/breeds/image/random")!
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var cancellableSet = Set<AnyCancellable>()
    
    // MARK: - Internal Methods
    func getCatFact() {
        urlSession.dataTaskPublisher(for: catURL)
            .map { $0.data }
            .decode(type: CatFact.self, decoder: decoder)
            .replaceError(with: CatFact(fact: "Error"))
            .eraseToAnyPublisher()
            .sink(receiveValue: { cat in
                self.cat = cat.fact
                self.counter.cat += 1
            }
            ).store(in: &cancellableSet)
    }
    
    func getDogImage() {
        urlSession.dataTaskPublisher(for: dogURL)
            .map { $0.data }
            .decode(type: DogImage.self, decoder: decoder)
            .replaceError(with: DogImage(message: "Error"))
            .eraseToAnyPublisher()
            .sink(receiveValue: { dog in
                if let url = URL(string: dog.message),
                    let data = try? Data(contentsOf: url) {
                    self.dog = UIImage(data: data)
                    self.counter.dog += 1
                }
            }
            ).store(in: &cancellableSet)
    }
    
    func resetCounter() {
        counter = (0,0)
    }
}
