//
//  BVManager.swift
//  BVSwift
//
//  Copyright © 2018 Bazaarvoice. All rights reserved.
//

import Foundation

public class BVManager {
  
  private static var configFileProduction: String = "bvsdk_config_prod"
  private static var configFileStaging: String = "bvsdk_config_staging"
  private static var configFileExtension: String = "json"
  
  private static var production: [String : Any]? = {
    return Bundle.loadJSONFileFromMain(
      name: BVManager.configFileProduction,
      fileExtension: BVManager.configFileExtension)
  }()
  
  private static var staging: [String : Any]? = {
    return Bundle.loadJSONFileFromMain(
      name: BVManager.configFileStaging,
      fileExtension: BVManager.configFileExtension)
  }()
  
  private static var activeFileConfigurationType: BVConfigurationType?
    = {
      
      if let stg = BVManager.staging,
        let clientId: String = stg[BVConstants.clientKey] as? String {
        return .staging(clientId: clientId)
      }
      
      if let prd = BVManager.production,
        let clientId: String = prd[BVConstants.clientKey] as? String {
        return .production(clientId: clientId)
      }
      
      return nil
  }()
  
  private var configurations: [BVConfiguration]?
  
  private init() {}
  
  /// Public
  public static let sharedManager = BVManager()
  
  public var logLevel: Int {
    get {
      return 0
    }
    set(newValue) {
      /// Set
    }
  }
  
  @discardableResult
  public func addConfiguration(
    _ configuration: BVConfiguration) -> Self {
    
    var configs = configurations ?? [BVConfiguration]()
    
    if !configs.contains(where: { (config: BVConfiguration) -> Bool in
        config.isSameAs(configuration)
      }) {
      configs.append(configuration)
    }
    configurations = configs
    
    return self
  }
}

internal extension BVManager {
  func getConfiguration<T: BVConfiguration>() -> T? {
    
    if let configList = configurations {
      for config in configList {
        if let cfg = config as? T {
          return cfg
        }
      }
      return nil
    }
    
    guard let active = BVManager.activeFileConfigurationType else {
      return nil
    }
    
    let keyValues = { () -> [String : Any]? in
      switch active {
      case .production:
        return BVManager.production
      case .staging:
        return BVManager.staging
      }
    }()
    
    return T.init(active, keyValues: keyValues)
  }
}
