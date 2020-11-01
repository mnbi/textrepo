# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
Nothing to record here.

## [0.5.0] - 2020-11-01
### Added
- Add a new API `Repository#search`.
- Add a new API `Repository#exist?`. (0.4.3)

## [0.4.0] - 2020-10-14
### Added
- Released to rubygems.org.

### Changed
- Rename the method, `Repository#notes` to `entries`.
- Modify the instruction to install

## [0.3.0] - 2020-10-11
### Added
- Go public onto GitHub.
- Add an example (`rbnotes`) to demonstrate how to use `textrepo`.

### Changed
- Modify not to handle fraction of time in Timestamp.
- Instead, Timestamp can have a suffix to distinguish 2 stamps those
  represent the same time.

## [0.2.0] - 2020-09-28
### Changed
- Modify to handle millisecond in Timestamp

## [0.1.0] - 2020-09-23
### Added
- Add some target in Rakefile to run test easily.
- Add error classes
- Add Timestamp class, it will be an identifier of each text in the repo.
- Add Repository class (an abstract base class for concrete repository
  implementations)
- Implement API for FileSystemRepository class (create/read/update/delete).
- Add tests.
