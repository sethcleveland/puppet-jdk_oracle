# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0] - 2016-07-27
### Added
- This CHANGELOG file to hopefully serve as an evolving example of a standardized open source project CHANGELOG.
- More badges to get some bling @030

### Changed
- BREAKING The JDK version has been transformed from string to integer @030
- BREAKING Changed default lookup of arguments to not call hiera directly leaning on default puppet 4 behaviour. Not sure if puppet 3 users will be affected. Please report back and we'll try to revert this behaviour.
- Updating default JDK8 to update 101