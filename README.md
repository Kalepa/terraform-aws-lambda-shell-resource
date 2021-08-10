# Terraform Lambda Shell (Resource)

This module runs shell commands in a Lambda function and treats the result like a resource (keeps the value in state and doesn't re-create unless inputs change). It also supports specifying shell commands for when the resource is destroyed.