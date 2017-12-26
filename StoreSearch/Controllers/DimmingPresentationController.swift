//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by Diego Caroli on 28/06/2017.
//  Copyright © 2017 Diego Caroli. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  lazy var dimmingView = GradientView(frame: CGRect.zero)
  
  override var shouldRemovePresentersView: Bool {
    return false
  }
  
  override func presentationTransitionWillBegin() {
    dimmingView.frame = containerView!.bounds
    containerView!.insertSubview(dimmingView, at: 0)
    // Animate background gradient view
    dimmingView.alpha = 0
    if let coordinator = presentedViewController.transitionCoordinator {
      coordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 1
      }, completion: nil)
    }
  }
  
  override func dismissalTransitionWillBegin()  {
    if let coordinator = presentedViewController.transitionCoordinator {
      coordinator.animate(alongsideTransition: { _ in
        self.dimmingView.alpha = 0
      }, completion: nil)
    }
  }
}
