# What to test

In this example you use the depends on between modules and a data resource. 

It will show what happens with an update on a module and the triggering of the data resource in the other module

```
  # module.module2.data.mock_simple_resource.example will be read during apply
```

# How to

- clone this repo to your local machine

```
git clone https://github.com/munnep/terraform_mock_provider.git
```
- Go into directory `depends_on_with_data_resources`
```
cd depends_on_with_data_resources
```
- terraform init
```
terraform init
```
- terraform apply
```
terraform apply
```
```
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```
- We now change the value of the string in module 1

```
resource "tfcoremock_simple_resource" "example" {
  string  = "resource_module1_change1"
}
```
- terraform apply  - which is one change

```
Terraform will perform the following actions:

  # module.module1.tfcoremock_simple_resource.example will be updated in-place
  ~ resource "tfcoremock_simple_resource" "example" {
        id     = "99225d06-2daf-774b-014e-3622caba42a1"
      ~ string = "resource_module1" -> "resource_module1_change1"
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```
- we add a depends on module2

```
module "module2" {
  source = "./module2"
  depends_on = [
    module.module1
  ]
}
```
- If we now change something on module1 the data resource on module2 should want to change something as well
- make another change on module1/main.tf

```
resource "tfcoremock_simple_resource" "example" {
  string  = "resource_module1_change2"
}

```
- terraform apply

you would expect a single change, but because of the depends on the data resource is triggered and it doesn't know the string value for the resource

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place
 <= read (data resources)

Terraform will perform the following actions:

  # module.module1.tfcoremock_simple_resource.example will be updated in-place
  ~ resource "tfcoremock_simple_resource" "example" {
        id     = "df9f8705-6752-16c1-03ef-7e5faec508eb"
      ~ string = "resource_module1_change" -> "resource_module1_change2"
    }

  # module.module2.data.tfcoremock_simple_resource.example will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "tfcoremock_simple_resource" "example" {
      + id = "lotte"
    }

  # module.module2.tfcoremock_simple_resource.example will be updated in-place
  ~ resource "tfcoremock_simple_resource" "example" {
        id     = "840fba55-64b8-7622-2af4-aacb7e367cda"
      - string = "data from module 2" -> null
    }

Plan: 0 to add, 2 to change, 0 to destroy.
```

- you get an error instead of the only a single change. This is something the developers of the provider are looking at. 

```
╷
│ Error: Provider produced inconsistent final plan
│ 
│ When expanding the plan for module.module2.tfcoremock_simple_resource.example to include new values learned so far during apply, provider
│ "registry.terraform.io/hashicorp/tfcoremock" produced an invalid new value for .string: was null, but now cty.StringVal("data from module
│ 2").
│ 
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
╵
```