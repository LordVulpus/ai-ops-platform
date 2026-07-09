resource "azurerm_ssh_public_key" "res-0" {
  location            = "ukwest"
  name                = "CentralComputerKey"
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDoi7pk5Aj0AAN9Qykwj5a157HqMbJ1xtWb1l4Uz/37nvRcA0+qhoFKBTni2anMzkKJwD3IFKoIKHlZk+Ct/9uEoD7oXCseL23mGbLLoGny7nCMcudN3eYGeelb3jXtvqgrm2WaxtL4frZfLa15OUVH2MIp+pVxqgjg7iILS4Fleme80YQvnzk4Uot03EzGzOj2zG2JpZSWXrupKKDWTU+LU9i2Ejktn1JnlxfRmasl7SfIfnXmO+Du8ftKtx5kC+dXVQx5+7PNjAGyARg/wkB1jjBpEEQZiKkPjA6HiSPV4eKS5qQicb9UJl4afb6HMKG3KyLqBPWG2dTDVw7dp5U/WUHTj0twtR7ppSRBKAOHYZ0MvFxXdgVdOCXE/pJ1LVBAtEM6u1Uk/r1LwWt6ScYHyQQ6k0EyXVcIUux4VHSNW6U0k2qCCoUInyMsNHotb9sWCUeuwB/rHl1Ua8JGDPH1+vdtFtyluwxMJe2EVuPZffJnFHKI0b+0b7vxf7MRNEO7iPIE7S4NPvwc7UI5Z2WWiKhhpKf9ieFvEdqnAIJtl1BggXJNwNX+ViDQOeDaLdRd7o2LUpennFfgCBP/Asqpqt2kB+P8BZIuS2mOYszgAD71vqzGmDG7hDWPct9G/gcpm8wE6QwED7XSPpoBxI2cXzDDjZNCAANgACPYFmubMw== junai@EREBUS"
  resource_group_name = "az-mothershipwest"
}
