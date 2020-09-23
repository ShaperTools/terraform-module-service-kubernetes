# Change Log

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

# [0.8.0](https://github.com/ShaperTools/terraform-module-service-kubernetes/compare/v0.7.0...v0.8.0) (2020-09-23)


### Bug Fixes

* Change cloudflare provider namespace ([ba954cc](https://github.com/ShaperTools/terraform-module-service-kubernetes/commit/ba954cc))


### Features

* Update terraform minimum supported version to 0.13 ([7d6fd51](https://github.com/ShaperTools/terraform-module-service-kubernetes/commit/7d6fd51))



# [0.7.0](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.6.0...v0.7.0) (2020-06-17)


### Features

* Change passive host names from passive.* to *-passive.* ([cf55e44](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/cf55e44))



# [0.6.0](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.5.2...v0.6.0) (2020-05-29)


### Features

* Move configuration for TLS certificates to separate module ([f3aec0d](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/f3aec0d))



## [0.5.2](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.5.1...v0.5.2) (2020-04-27)


### Bug Fixes

* Add suffix to ingress names when there are multiple ingresses ([784b0d7](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/784b0d7))



## [0.5.1](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.5.0...v0.5.1) (2020-04-27)


### Bug Fixes

* Correct resource reference when there are multiple ingresses ([07a99b7](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/07a99b7))



# [0.5.0](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.4.0...v0.5.0) (2020-04-22)


### Bug Fixes

* Concatenate certificate and issuer chain in Kubernetes TLS secret ([ed52652](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/ed52652))
* Fix creation of passive environment ingresses ([f9aafdc](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/f9aafdc))


### Features

* Combine ingress rules and annotations into single variable ([5f9bd99](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/5f9bd99))



# [0.4.0](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.3.1...v0.4.0) (2020-04-08)


### Features

* Use zone_id attribute instead of domain in cloudflare_record resources ([c8f35ab](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/c8f35ab))



## [0.3.1](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.3.0...v0.3.1) (2020-02-28)


### Bug Fixes

* Use default tls_certificate_name when certificate doesn't exist ([8689728](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/8689728))



# [0.3.0](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.2.1...v0.3.0) (2020-02-19)


### Features

* Use wildcard if common name is longer than SSL cert upper bound ([4d30476](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/4d30476))



## [0.2.1](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.2.0...v0.2.1) (2020-02-17)


### Bug Fixes

* Set volume_mounts and volumes defaults to the empty list ([a0c8ce7](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/a0c8ce7))



# [0.2.0](https://github.com/edahlseng/terraform-module-service-kubernetes/compare/v0.1.0...v0.2.0) (2020-02-17)


### Features

* Add args variable ([f511b20](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/f511b20))
* Add ingress_annotations variable ([4084841](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/4084841))
* Add namespace variable ([ba49c6d](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/ba49c6d))
* Add volume_mounts and volumes variable ([e137739](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/e137739))
* Handle TLS certificates in Terraform ([99d6a71](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/99d6a71))



# 0.1.0 (2020-01-08)


### Features

* Add service-kubernetes module + submodules ([c46fb50](https://github.com/edahlseng/terraform-module-service-kubernetes/commit/c46fb50))
