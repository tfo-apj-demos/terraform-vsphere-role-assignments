data "vsphere_role" "role1" {
  label = "Administrator"
}

output "ds_consumer" {
  value = data.vsphere_role.role1
}

# --- Datacenter Permissions
data "vsphere_datacenter" "this" {
  name = "Datacenter"
}

resource "vsphere_role" "create_vm_datacenter_permissions" {
  name = "create_vm_datacenter_permissions"
  role_privileges = sort([
    "VirtualMachine.Provisioning.ModifyCustSpecs",
  ])
}

resource "vsphere_entity_permissions" "datacenter" {
  entity_id   = data.vsphere_datacenter.this.id
  entity_type = "Datacenter"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = false
    is_group      = true
    role_id       = vsphere_role.create_vm_datacenter_permissions.id
  }
}

#

# --- Template folder permissions
resource "vsphere_role" "create_vm_template_permissions" {
  name = "create_vm_template_permissions"
  role_privileges = sort([
    "VirtualMachine.Provisioning.Clone",
    "VirtualMachine.Provisioning.CloneTemplate",
    "VirtualMachine.Provisioning.DeployTemplate",
    "VirtualMachine.Inventory.Move"
  ])
}

data "vsphere_folder" "templates" {
  path = "templates"
}

resource "vsphere_entity_permissions" "folder_templates" {
  entity_id   = data.vsphere_folder.templates.id
  entity_type = "Folder"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = true
    is_group      = true
    role_id       = vsphere_role.create_vm_template_permissions.id
  }
}


# --- Target folder permissions
resource "vsphere_role" "create_vm_folder_permissions" {
  name = "create_vm_folder_permissions"
  role_privileges = sort([
    # "VirtualMachine.Provisioning.Clone",
    # "VirtualMachine.Provisioning.CloneTemplate",
    # "VirtualMachine.Provisioning.DeployTemplate",
    "VirtualMachine.Inventory.Move",
    "VirtualMachine.Provisioning.MarkAsVM",
    "VirtualMachine.Inventory.Create",
    "VirtualMachine.Inventory.CreateFromExisting",
    "VirtualMachine.Config.AddNewDisk",
    "VirtualMachine.Config.AddExistingDisk",
    "VirtualMachine.Config.RawDevice",
    "VirtualMachine.Interact.PowerOff",
    "VirtualMachine.Interact.PowerOn",
    "VirtualMachine.State.CreateSnapshot",
    "VirtualMachine.State.RemoveSnapshot",
    # --- In case vMotion/svMotion is needed
    "Resource.HotMigrate",
    "Resource.ColdMigrate",
    # --- Additional permissions
    "VirtualMachine.Config.AddRemoveDevice",
    "VirtualMachine.Config.AdvancedConfig",
    "VirtualMachine.Config.Annotation",
    "VirtualMachine.Config.CPUCount",
    "VirtualMachine.Config.DiskExtend",
    "VirtualMachine.Config.DiskLease",
    "VirtualMachine.Config.EditDevice",
    "VirtualMachine.Config.ManagedBy",
    "VirtualMachine.Config.Memory",
    "VirtualMachine.Config.RemoveDisk",
    "VirtualMachine.Config.ResetGuestInfo",
    "VirtualMachine.Config.Resource",
    "VirtualMachine.Config.Rename",
    "VirtualMachine.Config.Settings",
    "VirtualMachine.Provisioning.Customize",
    # Deletion
    "VirtualMachine.Inventory.Delete"
    
  ])
}

data "vsphere_folder" "demo_workloads" {
  path = "/Datacenter/vm/demo workloads"
}

resource "vsphere_entity_permissions" "folder_demo_workloads" {
  entity_id   = data.vsphere_folder.demo_workloads.id
  entity_type = "Folder"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = true
    is_group      = true
    role_id       = vsphere_role.create_vm_folder_permissions.id
  }
}

# --- Cluster permissions
resource "vsphere_role" "create_vm_cluster_permissions" {
  name = "create_vm_cluster_permissions"
  role_privileges = [
    "Resource.AssignVMToPool",
  ]
}

data "vsphere_compute_cluster" "this" {
  name = "cluster"
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_entity_permissions" "cluster_demo_workloads" {
  entity_id   = data.vsphere_compute_cluster.this.id
  entity_type = "ClusterComputeResource"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = true
    is_group      = true
    role_id       = vsphere_role.create_vm_cluster_permissions.id
  }
}

# --- Datastore
resource "vsphere_role" "create_vm_datastore_permissions" {
  name = "create_vm_datastore_permissions"
  role_privileges = [
    "Datastore.AllocateSpace"
  ]
}

data "vsphere_datastore" "this" {
  name = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_entity_permissions" "datastore" {
  entity_id   = data.vsphere_datastore.this.id
  entity_type = "Datastore"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = true
    is_group      = true
    role_id       = vsphere_role.create_vm_datastore_permissions.id
  }
}

# --- Network
resource "vsphere_role" "create_vm_network_permissions" {
  name = "create_vm_network_permissions"
  role_privileges = [
    "Network.Assign"
  ]
}

data "vsphere_network" "this" {
  name = "seg-general"
  datacenter_id = data.vsphere_datacenter.this.id
}

resource "vsphere_entity_permissions" "network" {
  entity_id   = data.vsphere_network.this.id
  entity_type = "Network"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = true
    is_group      = true
    role_id       = vsphere_role.create_vm_network_permissions.id
  }
}

# --- vCenter Level Permissions
resource "vsphere_role" "create_vm_storage_profile_permissions" {
  name = "create_vm_storage_profile_permissions"
  role_privileges = sort([
    "StorageProfile.View",
  ])
}

resource "vsphere_entity_permissions" "vcenter" {
  entity_id   = "group-d1"
  entity_type = "Folder"
  permissions {
    user_or_group = "HASHICORP\\g_vsphere_access"
    propagate     = true
    is_group      = true
    role_id       = vsphere_role.create_vm_storage_profile_permissions.id
  }
  lifecycle {
    ignore_changes = [ permissions ]
  }
}
