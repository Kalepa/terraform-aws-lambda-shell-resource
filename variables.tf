variable "lambda_shell_module" {
  description = "An `Kalepa/lambda-shell/aws` module (https://registry.terraform.io/modules/Kalepa/lambda-shell/aws). Pass the entire module in as this parameter (e.g. `lambda_shell_module = module.lambda-shell`)."
  type = object({
    invicton_labs_lambda_shell_arn = string
  })
}

variable "interpreter" {
  description = "The interpreter (e.g. `sh`, `bash`, `python3`) and flags to use to run the provided `command`. The input format is a list of strings, such as `[\"bash\", \"-d\"]`."
  type        = list(string)
  default     = ["bash"]
  validation {
    condition     = var.interpreter != null
    error_message = "The `interpreter` variable must not be `null`."
  }
}

variable "command" {
  description = "The command to be run by the given interpreter. Note that the command will be stored in a file and the file name will be given as an argument to the `interpreter`. This means it can be multi-line if desired."
  type        = string
}

variable "triggers" {
  description = "A map of arbitrary keys and values that, when changed, will trigger a re-invocation."
  type        = any
  default     = null
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Map of environment variables to pass to the command. Will be merged with `sensitive_environment` and `triggerless_environment` (if either of them has the same key, those values will overwrite these values)."
}

variable "sensitive_environment" {
  type        = map(string)
  default     = {}
  description = "Map of (sentitive) environment variables to pass to the command. Will be merged with `environment` (this overwrites those values with the same key) and `triggerless_environment` (those values overwrite these values with the same key)."
}

variable "fail_on_nonzero_exit_code" {
  type        = bool
  default     = true
  description = "Whether a Terraform error should be thrown if the command exits with a non-zero exit code. If true, nothing will be returned from this module and Terraform will fail the apply. If false, the error message will be returned in `stderr` and the error code will be returned in `exit_code`."
  validation {
    condition     = var.fail_on_nonzero_exit_code != null
    error_message = "The `fail_on_nonzero_exit_code` variable must not be `null`."
  }
}

variable "fail_on_stderr" {
  type        = bool
  default     = false
  description = "Whether a Terraform error should be thrown if the command outputs anything to stderr. If true, nothing will be returned from this module and Terraform will fail the apply. If false, the error message will be returned in `stderr` and the exit code will be returned in `exit_code`. This is disabled by default because many commands write to stderr even if nothing went wrong."
  validation {
    condition     = var.fail_on_stderr != null
    error_message = "The `fail_on_stderr` variable must not be `null`."
  }
}

variable "fail_on_timeout" {
  type        = bool
  default     = true
  description = "Whether a Terraform error should be thrown if the create command times out (only applies if the `timeout_create` or `timeout_destroy` variable is provided). If true, nothing will be returned from this module and Terraform will fail the apply. If false, the `exit_code` will be -1."
  validation {
    condition     = var.fail_on_timeout != null
    error_message = "The `fail_on_timeout` variable must not be `null`."
  }
}

variable "timeout" {
  type        = number
  default     = null
  description = "The maximum number of seconds to allow the shell command to execute for. If it exceeds this timeout, it will be killed and will fail. Leave as the default (`null`) for no timeout."
}

variable "suppress_console" {
  type        = bool
  default     = false
  description = "Whether to suppress the Terraform console output (including plan content and shell execution status messages) for this module. If enabled, much of the content will be hidden by marking it as \"sensitive\"."
}

variable "log_event" {
  type        = bool
  default     = false
  description = "Whether to log input events in CloudWatch logs. `false` by default to reduce risk of secrets being exposed in logs."
  validation {
    condition     = var.log_event != null
    error_message = "The `log_event` variable must not be `null`."
  }
}
