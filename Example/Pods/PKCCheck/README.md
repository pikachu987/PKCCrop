# PKCCheck

[![Version](https://img.shields.io/cocoapods/v/PKCCheck.svg?style=flat)](http://cocoapods.org/pods/PKCCheck)
[![License](https://img.shields.io/cocoapods/l/PKCCheck.svg?style=flat)](http://cocoapods.org/pods/PKCCheck)
[![Platform](https://img.shields.io/cocoapods/p/PKCCheck.svg?style=flat)](http://cocoapods.org/pods/PKCCheck)

  
<img src="https://github.com/pikachu987/PKCCheck/blob/master/img1.jpeg?raw=true" width="140" >

<img src="https://github.com/pikachu987/PKCCheck/blob/master/img2.jpeg?raw=true" width="140" >

<img src="https://github.com/pikachu987/PKCCheck/blob/master/img3.jpeg?raw=true" width="140" >




## Example



To run the example project, clone the repo, and run `pod install` from the Example directory first.



<br><br>


- import the PKCCheck header
~~~~
import PKCCheck
~~~~


<br><br>





- ViewController
~~~~
import PKCCheck

class ViewController: UIViewController{
  let pkcCheck = PKCCheck()
  override func viewDidLoad() {
        super.viewDidLoad()
        self.pkcCheck.delegate = self
    }
}

~~~~



<br><br>





- AudioAccessCheck

~~~~
pkcCheck.audioAccessCheck()
~~~~

~~~~

extension ViewController: PKCCheckDelegate{
    func pkcCheckAudioPermissionUndetermined() {
        print("audioAccess: undetermined (first approach)")
    }
    
    func pkcCheckAudioPermissionGranted() {
        print("audioAccess: granted")
    }
    
    func pkcCheckAudioPermissionDenied() {
        print("audioAccess: denied")
        self.pkcCheck.permissionsChange()
    }
}

~~~~




<br><br>




- CameraAccessCheck

~~~~
pkcCheck.cameraAccessCheck()
~~~~

~~~~

extension ViewController: PKCCheckDelegate{
    func pkcCheckCameraPermissionUndetermined() {
        print("cameraAccess: undetermined (first approach)")
    }
    
    func pkcCheckCameraPermissionGranted() {
        print("cameraAccess: granted")
    }
    
    func pkcCheckCameraPermissionDenied() {
        print("cameraAccess: denied")
        self.pkcCheck.permissionsChange()
    }
}

~~~~




<br><br>




- PhotoAccessCheck

~~~~
pkcCheck.photoAccessCheck()
~~~~

~~~~

extension ViewController: PKCCheckDelegate{
    func pkcCheckPhotoPermissionUndetermined() {
        print("photoAccess: undetermined (first approach)")
    }
    
    func pkcCheckPhotoPermissionGranted() {
        print("photoAccess: granted")
    }
    
    func pkcCheckPhotoPermissionDenied() {
        print("photoAccess: denied")
        self.pkcCheck.permissionsChange()
    }
}

~~~~


<br><br>

- PlugCheck

~~~~
pkcCheck.plugAccessCheck()
~~~~

~~~~

extension ViewController: PKCCheckDelegate{
    func pkcCheckPlugIn() {
        print("plugIn")
    }
    
    func pkcCeckPlugOut() {
        print("plugOut")
    }
}

~~~~

<br><br>

- DecibelCheck

~~~~
//pkcCheck.minDecibelDegree = 45
//pkcCheck.maxDecibelDegree = 315
pkcCheck.decibelStart()
pkcCheck.decibelStop()
~~~~

~~~~

extension ViewController: PKCCheckDelegate{
    func pkcCheckDecibel(_ level: CGFloat, average: CGFloat, degree: CGFloat, radian: CGFloat) {
        
    }
    func pkcCheckSoundErr(_ error: Error) {
        print("sound error: \(error)")
    }
}

~~~~

<br><br>


- PermissionsChange

~~~~
pkcCheck.permissionsChange()
~~~~




<br><br>

- Delegate All
~~~~
extension ViewController: PKCCheckDelegate{
    func pkcCheckAudioPermissionUndetermined() {
        print("audioAccess: undetermined (first approach)")
    }
    
    func pkcCheckAudioPermissionGranted() {
        print("audioAccess: granted")
    }
    
    func pkcCheckAudioPermissionDenied() {
        print("audioAccess: denied")
        self.pkcCheck.permissionsChange()
    }
    
    
    
    func pkcCheckCameraPermissionUndetermined() {
        print("cameraAccess: undetermined (first approach)")
    }
    
    func pkcCheckCameraPermissionGranted() {
        print("cameraAccess: granted")
    }
    
    func pkcCheckCameraPermissionDenied() {
        print("cameraAccess: denied")
        self.pkcCheck.permissionsChange()
    }
    
    
    
    func pkcCheckPhotoPermissionUndetermined() {
        print("photoAccess: undetermined (first approach)")
    }
    
    func pkcCheckPhotoPermissionGranted() {
        print("photoAccess: granted")
    }
    
    func pkcCheckPhotoPermissionDenied() {
        print("photoAccess: denied")
        self.pkcCheck.permissionsChange()
    }
    
    
    
    func pkcCheckPlugIn() {
        print("plugIn")
    }
    
    func pkcCeckPlugOut() {
        print("plugOut")
    }
    
    
    
    func pkcCheckDecibel(_ level: CGFloat, average: CGFloat, degree: CGFloat, radian: CGFloat) {
        
    }
    func pkcCheckSoundErr(_ error: Error) {
        print("sound error: \(error)")
    }
}
~~~~

<br><br><br><br>

## Requirements

## Installation

PKCCheck is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "PKCCheck"
```

## Author

pikachu987, pikachu987@naver.com

## License

PKCCheck is available under the MIT license. See the LICENSE file for more info.
