module ErrorSolver
  def record_invalid_error(ex)
    error_handler RecordInvalidError.new('validation failed', caused_by: ex)
  end
end
