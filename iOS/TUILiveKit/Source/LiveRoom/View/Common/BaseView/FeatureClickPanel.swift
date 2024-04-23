//
//  FeatureClickPanel.swift
//  TUILiveKit
//
//  Created by WesleyLei on 2023/10/18.
//

import Foundation

enum FeatureItemType {
    case singleImage
    case imageAboveTitle
    case imageAboveTitleBottom
}

class FeatureItemDesignConfig {
    var type: FeatureItemType = .singleImage
    var backgroundColor: UIColor? = .clear
    var titileColor: UIColor? = .g6
    var titleFont: UIFont = .customFont(ofSize: 10)
    var cornerRadius: CGFloat = 0
    var imageScale: CGFloat = 1.0
}

class FeatureItem {
    init(title: String? = nil, image: UIImage? = nil, designConfig: FeatureItemDesignConfig = FeatureItemDesignConfig(),
         action: Any) {
        normalTitle = title
        normalImage = image
        self.designConfig = designConfig
        actionType = action
    }

    var normalTitle: String?
    var normalImage: UIImage?
    var designConfig: FeatureItemDesignConfig
    var actionType: Any?
}

class FeatureClickPanelModel {
    var items: [FeatureItem] = []
    var itemDiff: CGFloat = 0.0
    var itemSize: CGSize = .zero
}

class FeatureItemButton: UIControl {
    var item: FeatureItem
    init(item: FeatureItem) {
        self.item = item
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let buttonTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = false
        return label
    }()

    let buttonImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let imageBgView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true

        setView()
    }

    func setView() {
        if item.designConfig.type == .imageAboveTitleBottom {
            imageBgView.backgroundColor = item.designConfig.backgroundColor
            imageBgView.layer.cornerRadius = item.designConfig.cornerRadius
            imageBgView.layer.masksToBounds = true
        } else {
            backgroundColor = item.designConfig.backgroundColor
            layer.cornerRadius = item.designConfig.cornerRadius
            layer.masksToBounds = true
        }
        
        addSubview(imageBgView)
        addSubview(buttonImageView)
        addSubview(buttonTitle)

        buttonImageView.image = item.normalImage
        buttonTitle.text = item.normalTitle
        buttonTitle.textColor = item.designConfig.titileColor
        buttonTitle.font = item.designConfig.titleFont

        switch item.designConfig.type {
        case .singleImage:
            buttonImageView.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(item.designConfig.imageScale)
                make.height.equalToSuperview().multipliedBy(item.designConfig.imageScale)
                make.center.equalToSuperview()
            }
        case .imageAboveTitle:
            buttonImageView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8.scale375())
                make.width.height.equalTo(24.scale375())
                make.centerX.equalToSuperview()
            }
            buttonTitle.snp.makeConstraints { make in
                make.top.equalTo(buttonImageView.snp.bottom).offset(2.scale375())
                make.width.equalToSuperview()
                make.height.equalTo(17.scale375())
            }
        case .imageAboveTitleBottom:
            imageBgView.isHidden = false
            imageBgView.snp.makeConstraints { make in
                make.width.height.equalTo(56.scale375())
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            buttonImageView.snp.makeConstraints { make in
                make.width.height.equalTo(30.scale375())
                make.center.equalTo(imageBgView)
            }
            
            buttonTitle.snp.makeConstraints { make in
                make.top.equalTo(imageBgView.snp.bottom).offset(3.scale375())
                make.width.equalToSuperview()
                make.height.equalTo(17.scale375())
            }
        }
    }
}

class FeatureClickPanel: UIView {
    let clickEventCallBack: Observable<Any> = Observable(LiveKitClickEvent.default)
    var model: FeatureClickPanelModel
    init(model: FeatureClickPanelModel) {
        self.model = model
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        backgroundColor = .clear
        setView()
    }

    func setView() {
        var leftButton: FeatureItemButton?
        for item in model.items {
            let button = createFeatureItemButton(item: item)
            button.snp.makeConstraints { make in
                if let leftBu = leftButton {
                    make.leading.equalTo(leftBu.snp.trailing).offset(model.itemDiff)
                } else {
                    make.leading.equalToSuperview()
                }
                make.centerY.equalToSuperview()
                make.width.equalTo(model.itemSize.width)
                make.height.equalTo(model.itemSize.height)
            }
            leftButton = button
        }
        mm_h = model.itemSize.height
        mm_w = (model.itemSize.width + model.itemDiff) * CGFloat(model.items.count) - model.itemDiff
    }

    func createFeatureItemButton(item: FeatureItem) -> FeatureItemButton {
        let view = FeatureItemButton(item: item)
        view.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func updateFeatureItems(newItems: [FeatureItem]) {
        model.items = newItems
        for subview in subviews {
            subview.removeFromSuperview()
        }
        setView()
    }
}

// MARK: Action

extension FeatureClickPanel {
    @objc func itemClick(_ sender: FeatureItemButton) {
        guard let actionType = sender.item.actionType else{ return}
        clickEventCallBack.value = actionType
    }
}