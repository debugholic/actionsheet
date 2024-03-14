//
//  ActionSheetViewController.swift
//  ActionSheet
//
//  Created by debugholic on 2019/12/09.
//  Copyright © 2019 SideKickAcademy. All rights reserved.
//

import UIKit

public protocol ActionSheetItem {
    var title: String { get }
}

class ActionSheetTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return titleLabel
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryView = UIImageView(image: UIImage(systemName: selected ? "checkmark.circle.fill" : "circle"))
    }
}

public class ActionSheetViewController: UIViewController {
    public var data: [(any ActionSheetItem)]?
    public var selected: Int?        
    public var dismissHandler: ((Int?)->())?
    
    lazy var layerView: UIView = {
        let layerView = UIView()
        layerView.backgroundColor = UIColor.systemBackground
        view.addSubview(layerView)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            layerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            layerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            layerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        return layerView
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        layerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: layerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: layerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: layerView.topAnchor, constant: 15),
        ])
        tableView.register(ActionSheetTableViewCell.self, forCellReuseIdentifier: String(describing: ActionSheetTableViewCell.self))
        return tableView
    }()
    
    var tableViewHeight: NSLayoutConstraint! {
        didSet {
            tableViewHeight.isActive = true
        }
    }
    
    var tableViewLayerView: UIView?
    
    public var cellHeight: CGFloat = 48.0
    
    convenience public init(data: [any ActionSheetItem]?) {
        self.init(nibName: nil, bundle: nil)
        self.data = data
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        transitioningDelegate = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if let selected = selected {
            tableView.selectRow(at: IndexPath(row: selected, section: 0), animated: false, scrollPosition: .none)
        }

    }
    
    public override func loadView() {
        super.loadView()
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: .zero)
        let dimView = UIView()
        view.addSubview(dimView)
        view.sendSubviewToBack(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        layerView.layer.cornerRadius = 9
    }
        
    @IBAction func touchUpInside(_ sender: UIView) {
        self.dismiss(animated: true, completion:nil)
    }
}

extension ActionSheetViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.dismissHandler?(indexPath.row)
        }
    }
}
    
extension ActionSheetViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewHeight.constant = CGFloat(data?.count ?? 0) * cellHeight
        return data?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionSheetTableViewCell.self)) as! ActionSheetTableViewCell
        cell.titleLabel.text = data?[indexPath.row].title
        cell.selectionStyle = .none
        return cell
    }
}

extension ActionSheetViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension ActionSheetViewController: UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let fromViewController = transitionContext.viewController(forKey: .from)!
        let fromView = fromViewController.view!

        let toViewController = transitionContext.viewController(forKey: .to)!
        let toView = toViewController.view!
        
        if (isBeingPresented) {
            containerView.addSubview(toView)

            var centerOffScreen = containerView.center
            centerOffScreen.y = containerView.frame.height + layerView.frame.height / 2
            layerView.center = centerOffScreen
            toView.alpha = 0
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                self.layerView.center = containerView.center
                toView.alpha = 1

            }) { _ in
                transitionContext.completeTransition(true)
            }
            
        } else {
            var centerOffScreen = containerView.center
            centerOffScreen.y = containerView.frame.height + layerView.frame.height / 2
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                self.layerView.center = centerOffScreen
                fromView.alpha = 0
            }) { _ in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}
