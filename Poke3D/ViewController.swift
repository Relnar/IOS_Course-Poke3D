//
//  ViewController.swift
//  Poke3D
//
//  Created by Pierre-Luc Bruyere on 2018-11-03.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate
{
  // MARK: - Attributes

  @IBOutlet var sceneView: ARSCNView!

  // MARK: -
  override func viewDidLoad()
  {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
  }

  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARImageTrackingConfiguration()

    if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main)
    {
      configuration.trackingImages = imagesToTrack
      configuration.maximumNumberOfTrackedImages = 1
    }

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  // MARK: - ARSCNViewDelegate

  // Override to create and configure nodes for anchors added to the view's session.
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
  {
    guard let imageAnchor = anchor as? ARImageAnchor
    else
    {
      return nil
    }

    let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                         height: imageAnchor.referenceImage.physicalSize.height)
    plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)

    let planeNode = SCNNode(geometry: plane)
    planeNode.eulerAngles.x = -Float.pi / 2

    if let modelScene = SCNScene(named: "art.scnassets/Squirtle/Squirtle.scn"),
       let modelNode = modelScene.rootNode.childNodes.first
    {
      modelNode.eulerAngles.x = .pi / 2
      modelNode.scale = SCNVector3(0.05, 0.05, 0.05)
      planeNode.addChildNode(modelNode)
    }

    let node = SCNNode()
    node.addChildNode(planeNode)

    return node
  }
}
