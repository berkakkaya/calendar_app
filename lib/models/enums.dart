enum ResponseStatus {
  none,
  success,
  wrongEmailOrPassword,
  authorizationError,
  duplicateExists,
  notFound,
  accessDenied,
  serverError,
}

enum FormType {
  modifyEvent,
  createEvent,
}
