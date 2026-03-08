class_name TransactionResult

var success: bool
var residual: float

func _init(success:bool, residual:= .0):
	self.success = success
	self.residual = residual
