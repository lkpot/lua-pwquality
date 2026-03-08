group "default" {
  targets = ["test"]
}

target "test" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "test"
  output     = ["type=cacheonly"]
}
