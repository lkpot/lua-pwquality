group "default" {
  targets = ["test", "luarocks-test"]
}

target "test" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "test"
  output     = ["type=cacheonly"]
}

target "luarocks-test" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "luarocks-test"
  output     = ["type=cacheonly"]
}
