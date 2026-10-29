class OperationResult {
  final bool success;
  final String message;

  const OperationResult.ok(this.message) : success = true;
  const OperationResult.error(this.message) : success = false;
}