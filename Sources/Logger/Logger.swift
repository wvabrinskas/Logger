
import Foundation
import os

public enum LogPriority: String {
  case low, medium, high, alwaysShow
}

/// Type of adkit log
public enum LogType: String {
  
  case error, success, message

  /// Prefix to add to log statement
  /// - Returns: String to prepend
  public func prefix() -> String {
    let suffix = self.rawValue.uppercased()
    switch self {
    case .error:
      return "🔴 \(suffix): "
    case .success:
      return "🟢 \(suffix):"
    case .message:
      return "🟡 \(suffix):"
    }
  }
  
  /// Log type for system
  /// - Returns: OSLogType
  public func osLogType() -> OSLogType {
    switch self {
    case .error:
      return .error
    case .success:
      return .default
    case .message:
      return .info
    }
  }
  
  /// Determines whether logs should be shown

  
  /// Determins whether logs should be shown
  /// - Parameters:
  ///   - priority: The priority of the current message
  ///   - level: The overall level of the logger, will effectively filter messages
  /// - Returns: Whether or not to show the message
  public func canShow(for priority: LogPriority, for level: LogLevel) -> Bool {
    if priority == .alwaysShow {
      return true
    }
    
    guard level != .none else {
      return false
    }
    
    switch priority {
    case .low:
      return level.rawValue >= LogLevel.low.rawValue
    case .medium:
      return level.rawValue >= LogLevel.medium.rawValue
    case .high:
      return level.rawValue >= LogLevel.high.rawValue
    case .alwaysShow:
      return true
    }
  }
}

public enum LogLevel: Int {
  //show no logs
  case none
  
  //show only success logs
  case low
  
  //show only success and loading logs
  case medium
  
  //show all logs
  case high
}

public protocol Logger: class {
  static var osLogger: OSLog { get }
  var logLevel: LogLevel { get set }
  static func log(type: LogType, priority: LogPriority, message: String)
  func log(type: LogType, priority: LogPriority, message: String)
}

public extension Logger {
  var logLevel: LogLevel {
    get {
      return .high
    }
  }
  
  static var osLogger: OSLog {
    get {
      let identifier = Bundle.main.bundleIdentifier ?? "logger_log"
      return OSLog(subsystem: "\(identifier).logger.plist", category: "\(identifier)-log")
    }
  }
  
  static func log(type: LogType, priority: LogPriority = .low, message: String) {
    let message = "\(type.prefix()) - \(message)"
    os_log("%@", log: osLogger, type: type.osLogType(), message)
  }
  
  func log(type: LogType, priority: LogPriority = .low, message: String) {
    if type.canShow(for: priority, for: self.logLevel) {
      let message = "\(type.prefix()) - \(message)"
      os_log("%@", log: Self.osLogger, type: type.osLogType(), message)
    }
  }
}

