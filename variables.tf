variable "folder_id" {
  description = "(Optional) - Yandex Cloud Folder ID where resources will be created."
  type        = string
}

variable "ssh_key_path" {
  type = string
}

variable "preemptible" {
    description = "(Optional) - Specifies vm scheduling policies"
    type        = bool
    default     = true
}

variable "serial_console" {
    description = "(Optional) - Enable or disable serial console"
    type        = number
    default     = "0"
}