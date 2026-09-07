# -----------------------------------------------------------------------------
# locals.tf — Computed values built from variables and resources.
#
# Locals let you combine variables, resource attributes, and built-in
# functions into named intermediate values. Here we compute the final
# container name once and reuse it everywhere (main.tf and outputs.tf).
# -----------------------------------------------------------------------------

locals {
  # A short random suffix (from the random_id resource in main.tf) makes the
  # container name unique on every fresh apply, so you can re-run the lab
  # without "container name already in use" errors.
  #
  # Note: we deliberately do NOT use timestamp() here — its value changes on
  # every plan, which would force the container to be recreated forever
  # (a "perpetual diff"). A random_id that is kept in state stays stable.
  name_suffix = random_id.name_suffix.hex

  # The computed container name: "<prefix>-<suffix>".
  # Try changing container_name_prefix in terraform.tfvars and watch how
  # the planned replacement reflects it.
  container_name = "${var.container_name_prefix}-${local.name_suffix}"
}
