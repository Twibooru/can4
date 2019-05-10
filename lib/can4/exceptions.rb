module Can4
  # A general exception.
  class Error < StandardError; end

  # Raised when using +check_authorization+ without calling +authorize!+.
  class AuthorizationNotPerformed < Error; end

  # Raised when a resource fails a call to +authorize!+.
  class AccessDenied < Error; end
end
