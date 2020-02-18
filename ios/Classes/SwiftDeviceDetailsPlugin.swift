import Flutter
import UIKit
import <mach/mach.h>
import <mach/mach_host.h>

public class SwiftDeviceDetailsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_details_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftDeviceDetailsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

  var iOSDeviceInfo: [String: Any] = [:]

  if(call.method.elementsEqual("getiOSInfo")) {
    iOSDeviceInfo["osVersion"] = UIDevice.current.systemVersion
    iOSDeviceInfo["totalInternalStorage"] = getTotalDiskSpace()
    iOSDeviceInfo["freeInternalStorage"] = getFreeDiskSpace()
    iOSDeviceInfo["screenSize"] = getDisplaySize()
    iOSDeviceInfo["totalRAMSize"] = humanReadableByteCount(ProcessInfo.processInfo.physicalMemory)
    iOSDeviceInfo["freeRAMSize"] = humanReadableByteCount(ProcessInfo.processInfo.)
    iOSDeviceInfo["screenSize"] = getDisplaySize()
  }
    result("iOS " + UIDevice.current.systemVersion)
    var systemVersion = UIDevice.current.systemVersion

  }

  func humanReadableByteCount(bytes: Int) -> String {
      if (bytes < 1000) { return "\(bytes) B" }
      let exp = Int(log2(Double(bytes)) / log2(1000.0))
      let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
      let number = Double(bytes) / pow(1000, Double(exp))
      if exp <= 1 || number >= 100 {
          return String(format: "%.0f %@", number, unit)
      } else {
          return String(format: "%.1f %@", number, unit)
              .replacingOccurrences(of: ".0", with: "")
      }
  }

    static func getTotalDiskSpace() -> String? {
    var totalDiskSpaceInBytes:Int64 {
              get {
                  do {
                      let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                      let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
                      return humanReadableByteCount(space!)
                  } catch {
                      return 0
                  }
              }
          }
  }

   static func getFreeDiskSpace() -> String? {
      var freeDiskSpaceInBytes:Int64 {
                    get {
                        do {
                            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
                            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
                            return humanReadableByteCount(freeSpace!)
                        } catch {
                            return 0
                        }
                    }
                }
    }
    
    static func getFreeRAMSize() -> String? {
       mach_port_t host_port;
             mach_msg_type_number_t host_size;
             vm_size_t pagesize;

             host_port = mach_host_self();
             host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
             host_page_size(host_port, &pagesize);

             vm_statistics_data_t vm_stat;

             if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
                 NSLog(@"Failed to fetch vm statistics");
             }

             /* Stats in bytes */
             natural_t mem_free = vm_stat.free_count * pagesize;
        return humanReadableByteCount(mem_free);
        
    }
    
    static func getDisplaySize() -> String? {
        let scale = UIScreen.main.scale
        let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163);
        let width = UIScreen.main.bounds.size.width * scale
        let height = UIScreen.main.bounds.size.height * scale
        let horizontal = width / ppi, vertical = height / ppi;
        let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))
        let screenSize = String(format: "%0.1f", diagonal)
        return screenSize
    }
}
