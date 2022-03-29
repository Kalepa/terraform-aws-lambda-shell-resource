locals {
  input = jsonencode({
    interpreter = var.interpreter
    // Remove carriage returns from commands, since they'll be running in a Linux environment
    command                   = replace(replace(var.command, "\r", ""), "\r\n", "\n")
    log_event                 = var.log_event
    fail_on_nonzero_exit_code = var.fail_on_nonzero_exit_code
    fail_on_stderr            = var.fail_on_stderr
    fail_on_timeout           = var.fail_on_timeout
    timeout                   = var.timeout == null ? null : (var.timeout <= 0 ? null : var.timeout)
    environment               = var.sensitive_environment == null || length(var.sensitive_environment) == 0 ? (var.environment == null ? {} : var.environment) : sensitive(merge((var.environment == null ? {} : var.environment), var.sensitive_environment))
  })
}

resource "aws_lambda_invocation" "shell" {
  function_name = var.lambda_shell_module.invicton_labs_lambda_shell_arn
  triggers      = var.triggers
  input         = var.suppress_console ? sensitive(local.input) : local.input
}

module "state_keeper" {
  source  = "Invicton-Labs/state-keeper/null"
  version = "~> 0.1.2"
  count   = var.track_version ? 1 : 0
  depends_on = [
    aws_lambda_invocation.shell
  ]
  read_existing_value = true
  input               = module.state_keeper[0].existing_value == null ? 0 : module.state_keeper[0].existing_value + 1
  triggers = {
    trigger = base64sha256(jsonencode({
      var_triggers  = aws_lambda_invocation.shell.triggers
      input         = aws_lambda_invocation.shell.input
      function_name = aws_lambda_invocation.shell.function_name
    }))
  }
}

locals {
  result = jsondecode(aws_lambda_invocation.shell.result)
}
