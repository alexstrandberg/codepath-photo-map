//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationsViewControllerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var images = [UIImage]()
    
    var lastPinNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        images.append(editedImage)
        
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCapture(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            vc.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        self.presentViewController(vc, animated: true, completion: {
            self.performSegueWithIdentifier("tagSegue", sender: nil) })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            annotationView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            annotationView!.rightCalloutAccessoryView?.tag = lastPinNumber
            lastPinNumber += 1
        }
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        //imageView.image = UIImage(named: "camera")
        let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = thumbnail
        annotationView!.image = thumbnail
        
        return annotationView
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "tagSegue" {
            let vc = segue.destinationViewController as! LocationsViewController
            vc.delegate = self
        } else if segue.identifier == "fullImageSegue" {
            let vc = segue.destinationViewController as! FullImageViewController
            let sendPin = sender as! MKAnnotationView
            let sendButton = sendPin.rightCalloutAccessoryView as! UIButton
            vc.image = images[sendButton.tag]
        }
        // Pass the selected object to the new view controller.
    }
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        self.navigationController?.popViewControllerAnimated(true)
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        let annotation = PhotoAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.photo = images[images.endIndex.predecessor()]
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("fullImageSegue", sender: view)
    }
}
