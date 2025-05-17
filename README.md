# Bukola's Network Peering exercise

The aim for this exercise is to build a Terraform setup for three distinct Virtual Networks on a public cloud of your choice.
The networks should be peered as below:

Network A -- Network B -- Network C

Therefore, Netoworks A and C should be accessible from Network B, but not from each other.

Do not use automatically generated networks and routing tables: Create those using Terraform.

Also make sure that the network address spaces don't overlap. You can choose the size of the spaces.

Remember to add appropriate firewall rules, so that you can both ping (ICMP) and SSH (Port 22) between the peered networks.

To each network, add a small virtual machine so that you can manually test the routing by SSHing into the VMs and pinging each VM from each other.

Feel free to add own enhancements as you wish: Documenting your actions is strongly encourange and you can also add features like flow logs if you want to. The vms could also be based on a template and serve a simple website that you could retrieve by cUrling.

## Inventory

3 x Networks.

3 x Routing tables, 1 for each network.

At least 2 x 3 Firewall Rules.

3 x VMs, one for each network.

## Resources

### Terraform
- [Routing tables](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table)
- [Networks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [Firewall rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)
- [VMs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine)

### External Documentation

- [Peering docs](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
