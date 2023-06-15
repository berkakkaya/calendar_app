enum ResponseStatus {
  none,
  success,
  wrongEmailOrPassword,
  authorizationError,
  duplicateExists,
  notFound,
  accessDenied,
  serverError,
  invalidRequest
}

enum FormType {
  modifyEvent,
  createEvent,
}
