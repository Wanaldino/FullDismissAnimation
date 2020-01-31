//
//  ViewController.swift
//  DismissAnimationTest
//
//  Created by Wanaldino Antimonio on 30/01/2020.
//  Copyright © 2020 Wanal Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var number: Int
    static var delegate = DismissAnimationController()
    
    init(number: Int) {
        self.number = number
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.transitioningDelegate = ViewController.delegate
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = String(number)
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        button.backgroundColor = .red
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor).isActive = true
        stackView.centerXAnchor.constraint(lessThanOrEqualTo: view.centerXAnchor).isActive = true
    }

    @objc func didTapNext() {
        if number == 2 {
            ViewController.delegate.prepareForDismiss(view: view)
            SceneDelegate.nav.dismiss(animated: true, completion: nil)
        } else {
            let vc = ViewController(number: number + 1)
            let nav = UINavigationController(rootViewController: vc)
            
            nav.modalPresentationStyle = .fullScreen
            navigationController?.topMostPresent(nav, animated: true, completion: nil)
        }
    }
}

class DismissAnimationController: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var snapshot: UIView!
    
    func prepareForDismiss(view: UIView) {
        snapshot = view.snapshotView(afterScreenUpdates: false)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissed.view = snapshot
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
  
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = transitionContext.viewController(forKey: .to).flatMap({$0 as? UINavigationController})?.viewControllers.last?.view.snapshotView(afterScreenUpdates: true) else { return }
        containerView.addSubview(toView)
        containerView.addSubview(snapshot)
      
        let duration = transitionDuration(using: transitionContext)
      
        UIView.animate(withDuration: duration, animations: {
            self.snapshot.frame = CGRect(x: self.snapshot.frame.minX, y: self.snapshot.frame.maxY, width: self.snapshot.frame.width, height: self.snapshot.frame.height)
        }, completion: { finish in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

extension UIViewController {
    func topMostController() -> UIViewController {
        var topController = self
        while let nextController = topController.presentedViewController {
            topController = nextController
        }
        return topController
    }
    
    func topMostViewController() -> UIViewController {
        let topController = topMostController()
        guard
            let navigationController = topController as? UINavigationController,
            let topViewController = navigationController.viewControllers.last
        else {
            return topController
        }
        
        return topViewController
    }
    
    func topMostPresent(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        topMostController().present(viewController, animated: animated, completion: completion)
    }
}

