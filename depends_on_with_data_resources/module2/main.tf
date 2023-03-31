
data "tfcoremock_simple_resource" "example" {
  id = "lotte"
}

resource "tfcoremock_simple_resource" "example" {
  string  = data.tfcoremock_simple_resource.example.string
}




