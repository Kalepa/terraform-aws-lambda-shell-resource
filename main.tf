module "state" {
  source  = "Invicton-Labs/get-state/null"
  version = "0.2.1"
}

locals {
  trigger = {
    command     = var.create_command
    interpreter = var.create_interpreter
  }
}

module "trigger_changed_create" {
  source  = "Invicton-Labs/value-changed/null"
  version = "0.1.1"
  value   = local.trigger
  depends = [
    data.aws_lambda_invocation.shell_create
  ]
}

module "trigger_changed_destroy" {
  //source  = "Invicton-Labs/value-changed/null"
  //version = "0.1.1"
  source = "../terraform-null-value-changed"
  value  = local.trigger
  depends = [
    data.aws_lambda_invocation.shell_destroy
  ]
}

locals {
  create = module.trigger_changed_create.changed
  // Only run the destroy if the inputs have changed since the last successful run AND the old value wasn't null (which would imply that this is the first create; there's nothing to destroy) AND a destroy command has been provided AND the last successful trigger is the same as the last stored trigger
  destroy = module.trigger_changed_destroy.changed && module.trigger_changed_destroy.old_value != null && var.destroy_command != null && (module.state_keeper.existing_value != null ? module.state_keeper.existing_value.trigger == module.trigger_changed_destroy.old_value : false)
  // The uuid() function waits for the apply phase before it knows the value
  wait_for_apply_create  = local.create ? uuid() : true
  wait_for_apply_destroy = local.destroy ? uuid() : true
}

// This is configured to send a special payload to the Lambda with a flag telling it not to execute anything if the trigger hasn't changed; 
// this is to prevent it from executing anything that might have side effects when it shouldn't.
data "aws_lambda_invocation" "shell_create" {
  depends_on = [
    var.lambda_shell_module,
    data.aws_lambda_invocation.shell_destroy,
    module.trigger_changed_destroy
  ]
  // Force it to wait for the apply step, and also wait for the destroy to complete if the destroy should be done
  function_name = local.wait_for_apply_create == null ? var.lambda_shell_module.invicton_labs_lambda_shell_arn : var.lambda_shell_module.invicton_labs_lambda_shell_arn
  input = jsonencode(merge({
    mode          = "CREATE"
    interpreter   = local.create ? var.create_interpreter : null
    command       = local.create ? var.create_command : null
    fail_on_error = local.create ? var.create_fail_on_error : null
    }, local.create ? {} : {
    __IL_TF_LS_SKIP_RUN = true
  }))
}

data "aws_lambda_invocation" "shell_destroy" {
  depends_on = [
    var.lambda_shell_module,
  ]
  // Wait for apply time
  function_name = local.wait_for_apply_destroy == null ? var.lambda_shell_module.invicton_labs_lambda_shell_arn : var.lambda_shell_module.invicton_labs_lambda_shell_arn
  input = jsonencode(merge({
    mode          = "DESTROY"
    interpreter   = local.destroy ? var.destroy_interpreter : null
    command       = local.destroy ? var.destroy_command : null
    fail_on_error = local.destroy ? var.destroy_fail_on_error : null
    }, local.destroy ? {} : {
    __IL_TF_LS_SKIP_RUN = true
  }))
}

locals {
  // Save the output, as well as the interpreter/command used to generate it, in the state
  create_result = merge(jsondecode(data.aws_lambda_invocation.shell_create.result), {
    trigger = local.trigger
  })
}

// This keeps the output value in state until it's re-created
module "state_keeper" {
  source  = "Invicton-Labs/state-keeper/null"
  version = "0.1.1"
  // This convoluted expression just forces the shell_destroy data source to actually execute. Since the value isn't being returned anywhere, 
  // the data source won't be executed unless you tell it to use the output value in order to evaluate a conditional expression like this ternary one.
  input               = local.destroy ? (data.aws_lambda_invocation.shell_create.result == null ? local.create_result : local.create_result) : local.create_result
  triggers            = local.trigger
  read_existing_value = true
}
