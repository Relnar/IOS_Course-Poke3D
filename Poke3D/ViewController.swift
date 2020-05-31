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

    sceneView.autoenablesDefaultLighting = true
  }

  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARImageTrackingConfiguration()

    if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main)
    {
      configuration.trackingImages = imagesToTrack
      configuration.maximumNumberOfTrackedImages = 6
    }

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewDidAppear(_ animated: Bool)
  {
    super.viewDidAppear(animated)

    // Enable flashlight
    if let device = AVCaptureDevice.default(for: .video),
       let input = try? AVCaptureDeviceInput.init(device: device),
       device.hasFlash, device.hasTorch
    {
      var torch = input.device.torchMode

      switch torch {
      case .off:
        torch = .on
//        sender.setBackgroundImage( imageLiteral(resourceName: "torch_off"), for: UIControlState.normal)
//      case .on:
//        torch = .off
//        sender.setBackgroundImage( imageLiteral(resourceName: "torch_on"), for: UIControlState.normal)
      default:
        break
      }

      try? input.device.lockForConfiguration()
      input.device.torchMode = torch
      input.device.unlockForConfiguration()
    }
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

    if let modelScene = SCNScene(named: "art.scnassets/\(imageAnchor.referenceImage.name!)/\(imageAnchor.referenceImage.name!).scn"),
       let modelNode = modelScene.rootNode.childNodes.first
    {
      let minSize = CGFloat.minimum(imageAnchor.referenceImage.physicalSize.width,
                                    imageAnchor.referenceImage.physicalSize.height)

      // Rotate the pitch to be able to see the model face-to-face when the angle is almost edge-on.
      modelNode.eulerAngles.x = .pi / 3

      let boundingBox = modelNode.boundingBox
      var boundingBoxSize = boundingBox.max - boundingBox.min
      let boundingBoxSizeX = boundingBoxSize.x
      boundingBoxSize.x = Float.minimum(boundingBoxSizeX, boundingBoxSize.z)
      boundingBoxSize.z = Float.minimum(boundingBoxSizeX, boundingBoxSize.z)
      modelNode.scale = SCNVector3(imageAnchor.referenceImage.physicalSize.width, minSize, imageAnchor.referenceImage.physicalSize.height) / boundingBoxSize
      modelNode.pivot = SCNMatrix4MakeTranslation(-modelNode.position.x, -modelNode.position.y, -modelNode.position.z)
      modelNode.position = SCNVector3(float3(0.0))

//      modelNode.scale = SCNVector3(1.0, 1.0, 1.0) / (boundingBox.max - boundingBox.min)
//      modelNode.scale.maximize(max: SCNVector3(float3(1.0)))
//      print(modelNode.scale)
      planeNode.addChildNode(modelNode)
    }

    let node = SCNNode()
    node.addChildNode(planeNode)

    return node
  }
}
