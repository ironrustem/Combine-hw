//
//  ViewController.swift
//  Combine-hw
//
//  Created by wrustem on 09.11.2021.
//

import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
    
    enum Constants {
        static let catIndex = 0
        static let dogIndex = 1
        
        static let moreButtonSize = CGSize(width: 144, height: 40)
    }
    
    private lazy var resetBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Reset",
                                     style: .plain,
                                     target: self,
                                     action: #selector(resetButtonDidPress))
        return button
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Cats", "Dogs"])
        segmentControl.selectedSegmentIndex = Constants.catIndex
        return segmentControl
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.addSubview(self.contentLabel)
        view.addSubview(self.contentImageView)
        return view
    }()
    
    private lazy var contentImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.textAlignment = .center
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("more", for: .normal)
        button.backgroundColor = UIColor(named: "Colors/moreButtonColor")
        button.layer.cornerRadius = 20
        return button
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.text = "Score: 0 cats and 0 dogs"
        label.textAlignment = .center
        return label
    }()
    
    private var cancellableSet = Set<AnyCancellable>()
    
    private var catDogService: CatDogService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        addSubviews()
        makeConstraints()
        catDogService = CatDogService()
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        
        guard let catDogService = catDogService else {
            return
        }
        
        self.segmentControl
            .publisher(for: \.selectedSegmentIndex)
            .sink { value in
                self.makeNotVisible()
                switch value {
                case 0:
                    self.catDogService?.getCatFact()
                case 1:
                    self.catDogService?.getDogImage()
                default:
                    break
                }
            }
            .store(in: &cancellableSet)
        
        self.moreButton
            .publisher(for: .touchUpInside)
            .sink { _ in
                self.makeNotVisible()
                switch self.segmentControl.selectedSegmentIndex {
                case 0:
                    self.catDogService?.getCatFact()
                case 1:
                    self.catDogService?.getDogImage()
                default:
                    break
                }
            }
            .store(in: &cancellableSet)
        
        catDogService.$dog
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {  _ in },
                receiveValue: { dog in
                    if self.segmentControl.selectedSegmentIndex == Constants.dogIndex {
                        self.contentImageView.image = dog
                        self.makeVisibleDog()
                    }
                   
                }
            )
            .store(in: &cancellableSet)
        
        catDogService.$cat
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {  _ in },
                receiveValue: { fact in
                    guard let fact = fact else { return }
                    if self.segmentControl.selectedSegmentIndex == Constants.catIndex {
                        self.contentLabel.text = fact
                        self.makeVisibleCat()
                    }
                }
            )
            .store(in: &cancellableSet)
        
        catDogService.$counter
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {  _ in },
                receiveValue: { [self] counter in
                    self.counterLabel.text = "Score: \(counter.cat) cats and \(counter.dog) dogs"
                }
            )
            .store(in: &cancellableSet)
    }
    
    private func makeVisibleCat() {
        DispatchQueue.main.async { [weak self] in
            self?.contentLabel.isHidden = false
            self?.contentImageView.isHidden = true
        }
    }
    
    private func makeNotVisible() {
        DispatchQueue.main.async { [weak self] in
            self?.contentLabel.isHidden = true
            self?.contentImageView.isHidden = true
        }
    }
    
    private func makeVisibleDog() {
        DispatchQueue.main.async { [weak self] in
            self?.contentLabel.isHidden = true
            self?.contentImageView.isHidden = false
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupNavigationBar() {
        title = "Cats and dogs"
        navigationItem.rightBarButtonItem = resetBarButtonItem
    }
    
    private func addSubviews() {
        view.addSubview(contentView)
        view.addSubview(moreButton)
        view.addSubview(counterLabel)
        view.addSubview(segmentControl)
    }
    
    private func makeConstraints() {
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(100)
            make.trailing.leading.equalToSuperview().inset(18)
            make.height.equalTo(204.37)
        }
        
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.bottom).offset(12.63)
            make.size.equalTo(Constants.moreButtonSize)
            make.centerX.equalToSuperview()
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(27)
            make.centerX.equalToSuperview()
            make.trailing.leading.equalToSuperview().inset(90)
            make.height.equalTo(32)
        }
        
        counterLabel.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(41)
            make.top.equalTo(moreButton.snp.bottom).offset(19)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Action
    
    @objc private func resetButtonDidPress() {
        catDogService?.resetCounter()
    }
}

