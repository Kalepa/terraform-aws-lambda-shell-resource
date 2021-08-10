output "stdout" {
  description = "The stdout output of the shell command."
  depends_on = [
    module.state_keeper,
    module.trigger_changed_create
  ]
  value = module.state_keeper.output.stdout
}

output "stderr" {
  description = "The stderr output of the shell command."
  depends_on = [
    module.state_keeper,
    module.trigger_changed_create
  ]
  value = module.state_keeper.output.stderr
}

output "exitstatus" {
  description = "The exit status code of the shell command."
  depends_on = [
    module.state_keeper,
    module.trigger_changed_create
  ]
  value = module.state_keeper.output.exitstatus
}
