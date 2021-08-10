variable "lambda_shell_module" {
  description = "An `Invicton-Labs/lambda-shell/aws` module (https://registry.terraform.io/modules/Invicton-Labs/request-signer/aws). Pass the entire module in as this parameter (e.g. `lambda_shell_module = module.lambda-shell`)."
  type = object({
    invicton_labs_lambda_shell_arn = string
  })
}

variable "create_interpreter" {
  description = "The interpreter (e.g. `sh`, `bash`, `python3`) and flags to use to run the provided `create_script` when destroying the resource. The input format is a list of strings, such as `[\"bash\", \"-d\"]`."
  type        = list(string)
  default     = ["bash"]
  validation {
    condition     = var.create_interpreter != null
    error_message = "The `create_interpreter` parameter must not be `null`."
  }
}

variable "create_command" {
  description = "The command to be run by the given interpreter when creating the resource. This field can be multi-line; the content will be stored in a file and executed by the given interpreter."
  type        = string
}

variable "create_fail_on_error" {
  description = "Whether a Terraform error should be thrown if the create command returns a non-zero exit code. If true, nothing will be returned from this module and Terraform will fail the apply. If false, the error message will be returned in `stderr` and the error code will be returned in `exitstatus`."
  type        = bool
  default     = true
  validation {
    condition     = var.create_fail_on_error != null
    error_message = "The `create_fail_on_error` parameter must not be `null`."
  }
}

variable "destroy_interpreter" {
  description = "The interpreter (e.g. `sh`, `bash`, `python3`) and flags to use to run the provided `destroy_script` when destroying the resource. The input format is a list of strings, such as `[\"bash\", \"-d\"]`."
  type        = list(string)
  default     = ["bash"]
  validation {
    condition     = var.destroy_interpreter != null
    error_message = "The `destroy_interpreter` parameter must not be `null`."
  }
}

variable "destroy_command" {
  description = "The command to be run by the given interpreter when destroying the resource. This field can be multi-line; the content will be stored in a file and executed by the given interpreter."
  type        = string
  default     = null
}

variable "destroy_fail_on_error" {
  description = "Whether a Terraform error should be thrown if the destroy command returns a non-zero exit code. If true, nothing will be returned from this module and Terraform will fail the apply. If false, nothing will happen if the destroy command fails."
  type        = bool
  default     = true
  validation {
    condition     = var.destroy_fail_on_error != null
    error_message = "The `destroy_fail_on_error` parameter must not be `null`."
  }
}
