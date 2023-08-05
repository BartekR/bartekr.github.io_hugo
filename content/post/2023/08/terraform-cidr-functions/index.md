---
title: "Terraform CIDR Functions" # Title of the blog post.
date: 2023-08-05 # Date of post creation.
draft: false # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
images:
  - src: "2023/08/05/terraform-cidr-functions/images/terraform-cidr.png"
    alt: ""
    stretch: ""
tags: ['terraform', 'cidr']
categories: ['IaC']
---

Recently, when I was using Terraform to provision virtual network structure, I had to find a solution to create 4 predefined subnets within a given network range. Initially - as PoC - I used string manipulation to obtain the ranges, but I haven't liked it. Then I found two built-in terraform functions, that are a great help when working with network aspect: `cidrsubnet` and `cidrsubnets`.

## CIDR notation 101

[Wikipedia](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) states, that

> Classless Inter-Domain Routing (CIDR /ˈsaɪdər, ˈsɪ-/) is a method for allocating IP addresses and for IP routing

and

> CIDR notation is a compact representation of an IP address and its associated network mask.

An example would be `10.0.0.0/16`. This is all nice, but I struggle to remember the CIDR notation stuff, so I always have a short cheatsheet for it:

```txt
/16 == 65 536 addresses, ex. 10.0.0.0 - 10.0.255.255
/17 == 32 768 addresses
/18 == 16 384 addresses
...
/23 ==    512 addresses
/24 ==    256 addresses, ex. 10.0.0.0 - 10.0.0.255
/25 ==    128 addresses
/26 ==     64 addresses
/27 ==     32 addresses
...
/32 ==      1 address
```

I work with Azure and I usually see or use `/16`, `/23`, `/24`, `/26`, and `/27` networks and subnets. And when I divide a VNet into subnets, I have them of the same size.

An example: `/24` address space (256 addresses) divided into four equal `/26` ranges, 64 addresses each:

```txt
vnet:    10.0.0.0/24   -> 256 addresses, 10.0.0.0   - 10.0.0.255

subnet0: 10.0.0.0/26   -> 64 addresses,  10.0.0.0   - 10.0.0.63
subnet1: 10.0.0.64/26  -> 64 addresses,  10.0.0.64  - 10.0.0.127
subnet2: 10.0.0.128/26 -> 64 addresses,  10.0.0.128 - 10.0.0.191
subnet3: 10.0.0.192/26 -> 64 addresses,  10.0.0.192 - 10.0.0.255
```

## CIDR notation handling in Terraform

To avoid mundane string manipulation, and to ease working with CIDR notation Terraform has four functions: `cidrhost`, `cidrnetmask`, `cidrsubnet`, and `cidrsubnets`. For my purpose, I will use the last two:

`cidrsubnet(prefix, newbits, netnum)` - calculates subnet at `netnum` position for a given prefix
`cidrsubnets(prefix, newbits...)` - calculates subsequent subnets for a given prefix

Let's stick to the `/24 -> 4 x /26` example above. To split the `/24` VNet into four subnets I can write four `cidrsubnet` functions:

```cmd
D:\temp\_terraform> terraform console

> cidrsubnet("10.244.200.0/24", 2, 0)
"10.244.200.0/26"
> cidrsubnet("10.244.200.0/24", 2, 1)
"10.244.200.64/26"
> cidrsubnet("10.244.200.0/24", 2, 2)
"10.244.200.128/26"
> cidrsubnet("10.244.200.0/24", 2, 3)
"10.244.200.192/26"
> cidrsubnet("10.244.200.0/24", 2, 4)
╷
│ Error: Error in function call
│
│   on <console-input> line 1:
│   (source code not available)
│
│ Call to function "cidrsubnet" failed: prefix extension of 2 does not accommodate a subnet numbered 4.
```

I'll explain the above example step by step.

The definition of `cidrsubnet` is `cidrsubnet(prefix, newbits, netnum)`. **prefix** is the VNet address space, specified in the CIDR format. In my case: `10.244.200.0/24`. I want `/26` subnets, so as **newbits** I pass the value 2, which means *dear Terraform, please add 2 to the `/24` space, to obtain a few `/26` address ranges*. In the background, Terraform splits the `/24` range into four equal `/26` subranges, and enumerates them starting from 0. I imagine this as Terraform keeping internally an array of four subnets, like in the example above. If I want the first range, I set **netnum** as `0`, if I want the third, I set **netnum** as `2`, etc. And since the `/24` range is split equally into four `/26` ranges, I can't assign **newnum == 4**, as the range does not exist.

I can either write four separate `cidrsubnet()` expressions to get four subnets, or I can ask Terraform to do it for me in one command using `cidrsubnets()`. Again as a reminder:

> `cidrsubnets(prefix, newbits...)`

```cmd
D:\temp\_terraform> terraform console

> cidrsubnets("10.244.200.0/24", 2, 2, 2, 2)
tolist([
  "10.244.200.0/26",
  "10.244.200.64/26",
  "10.244.200.128/26",
  "10.244.200.192/26",
])
```

The above means: *dear Terraform, take this `/24` space, then split it for me into ranges; first take 64 addresses, then again take 64 addresses, then again take 64 addresses, then again take 64 addresses*. Terraform knows I want 64 addresses, as he creates subsequent ranges by adding the **newbits** value to the given `/24` space. This way, he obtains `/26` range, that contains 64 addresses. Each **newbits** value adds a range to the previously created ones.

It's still unclear, so let's go again with an example:

```txt
                 cidrsubnets("10.244.200.0/24", 2, 2, 2, 2)
                                           |    |  |  |  |
                        /24 address space -+    |  |  |  |
     /26 address space (/24 + 2), 64 addresses -+  |  |  | 10.244.200.0   .. 10.244.200.63
     /26 address space (/24 + 2), 64 addresses ----+  |  | 10.244.200.64  .. 10.244.200.127
     /26 address space (/24 + 2), 64 addresses -------+  | 10.244.200.128 .. 10.244.200.191
     /26 address space (/24 + 2), 64 addresses ----------+ 10.244.200.192 .. 10.244.200.255
```

Using these techniques, I can split my address range in multiple ways, and I do not have to stick to the one **newbits** value. Both examples below are equivalent:

```cmd
D:\temp\_terraform> terraform console

> cidrsubnets("10.244.200.0/24", 2, 2, 3, 3, 2)
tolist([  
"10.244.200.0/26",  
"10.244.200.64/26",  
"10.244.200.128/27",  
"10.244.200.160/27",  
"10.244.200.192/26",  
])

> cidrsubnet("10.244.200.0/24", 2, 0)
"10.244.200.0/26"
> cidrsubnet("10.244.200.0/24", 2, 1)
"10.244.200.64/26"
> cidrsubnet("10.244.200.0/24", 3, 4)
"10.244.200.128/27"
> cidrsubnet("10.244.200.0/24", 3, 5)
"10.244.200.160/27"
> cidrsubnet("10.244.200.0/24", 2, 3)
"10.244.200.192/26"
```

One thing to remember when using `cidrsubnet()` - it splits the initial range into an equal number of subranges. So in the example above I want `/26` and `/27` subnets, so Terraform creates these arrays in the background:

```cmd
tolist([
  "10.244.200.0/26",
  "10.244.200.64/26",
  "10.244.200.128/26",
  "10.244.200.192/26",
])

tolist([
  "10.244.200.0/27",
  "10.244.200.32/27",
  "10.244.200.64/27",
  "10.244.200.96/27",
  "10.244.200.128/27",
  "10.244.200.160/27",
  "10.244.200.192/27",
  "10.244.200.224/27",
])
```

As the first `/26` range encompasses the first two `/27` ranges, and the second `/26` range encompasses the third and fourth `/27` ranges, I need to use **netnum == 4** (fifth range) for the third subnet.

For completness the `cidrsubnets("10.244.200.0/24", 2, 2, 3, 3, 2)` diagram

```txt
                 cidrsubnets("10.244.200.0/24", 2, 2, 3, 3, 2)
                                           |    |  |  |  |  |
                        /24 address space -+    |  |  |  |  |
     /26 address space (/24 + 2), 64 addresses -+  |  |  |  | 10.244.200.0   .. 10.244.200.63
     /26 address space (/24 + 2), 64 addresses ----+  |  |  | 10.244.200.64  .. 10.244.200.127
     /27 address space (/24 + 3), 32 addresses -------+  |  | 10.244.200.128 .. 10.244.200.159
     /27 address space (/24 + 3), 32 addresses ----------+  | 10.244.200.160 .. 10.244.200.191
     /26 address space (/24 + 2), 64 addresses -------------+ 10.244.200.192 .. 10.244.200.255
```

## Assign ranges to subnets

Once I know how to use `cidrsubnet()` and `cidrsubnets()` functions, I can assing ranges to the subnets. Let's say, I have this kind of network segmentation:

- **subnetA** range 10.x.y.0 .. 10.x.y.63
- **subnetB** range 10.x.y.64 .. 10.x.y.127
- **subnetC** range 10.x.y.128 .. 10.x.y.191
- **subnetD** range 10.x.y.192 .. 10.x.y.255

With this terraform code I can create subnets for a given virtual network:

```terraform
provider "azurerm" {
  features {}
}

locals {
  vnet1_address_space = "10.244.200.0/24"
  vnet2_address_space = "10.244.204.0/24"
  
  subnets       = {
    "subnetA" = 0
    "subnetB" = 1
    "subnetC" = 2
    "subnetD" = 3
  }

  # for cidrsubnets() approach
  subnet_ranges = cidrsubnets(local.vnet2_address_space, 2, 2, 2, 2)
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-shared-networking"
  location = "West Europe"
}

# using cidrsubnet()
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-shared1"
  address_space       = [local.vnet1_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet1" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  for_each             = local.subnets
  name                 = "snet-${each.key}"
  address_prefixes     = [cidrsubnet(local.vnet1_address_space, 2, each.value)]
}

# using cidrsubnets()
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet-shared2"
  address_space       = [local.vnet2_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet2" {
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  for_each             = local.subnets
  name                 = "snet-${each.key}"
  address_prefixes     = [local.subnet_ranges[each.value]]
}
```

When run with `terraform plan`, the code above produces this output:

```txt
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "rg-shared-networking"
    }

  # azurerm_subnet.snet1["subnetA"] will be created
  + resource "azurerm_subnet" "snet1" {
      + address_prefixes                               = [
          + "10.244.200.0/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetA"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared1"
    }

  # azurerm_subnet.snet1["subnetB"] will be created
  + resource "azurerm_subnet" "snet1" {
      + address_prefixes                               = [
          + "10.244.200.64/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetB"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared1"
    }

  # azurerm_subnet.snet1["subnetC"] will be created
  + resource "azurerm_subnet" "snet1" {
      + address_prefixes                               = [
          + "10.244.200.128/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetC"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared1"
    }

  # azurerm_subnet.snet1["subnetD"] will be created
  + resource "azurerm_subnet" "snet1" {
      + address_prefixes                               = [
          + "10.244.200.192/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetD"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared1"
    }

  # azurerm_subnet.snet2["subnetA"] will be created
  + resource "azurerm_subnet" "snet2" {
      + address_prefixes                               = [
          + "10.244.204.0/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetA"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared2"
    }

  # azurerm_subnet.snet2["subnetB"] will be created
  + resource "azurerm_subnet" "snet2" {
      + address_prefixes                               = [
          + "10.244.204.64/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetB"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared2"
    }

  # azurerm_subnet.snet2["subnetC"] will be created
  + resource "azurerm_subnet" "snet2" {
      + address_prefixes                               = [
          + "10.244.204.128/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetC"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared2"
    }

  # azurerm_subnet.snet2["subnetD"] will be created
  + resource "azurerm_subnet" "snet2" {
      + address_prefixes                               = [
          + "10.244.204.192/26",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "snet-subnetD"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-shared-networking"
      + virtual_network_name                           = "vnet-shared2"
    }

  # azurerm_virtual_network.vnet1 will be created
  + resource "azurerm_virtual_network" "vnet1" {
      + address_space       = [
          + "10.244.200.0/24",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "westeurope"
      + name                = "vnet-shared1"
      + resource_group_name = "rg-shared-networking"
      + subnet              = (known after apply)
    }

  # azurerm_virtual_network.vnet2 will be created
  + resource "azurerm_virtual_network" "vnet2" {
      + address_space       = [
          + "10.244.204.0/24",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "westeurope"
      + name                = "vnet-shared2"
      + resource_group_name = "rg-shared-networking"
      + subnet              = (known after apply)
    }

Plan: 11 to add, 0 to change, 0 to destroy.
```
