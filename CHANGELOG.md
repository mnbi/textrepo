# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.5.8] - 2021-03-23
### Add
- Add a section to describe about **text** into `README.md`.

### Fixed
- Fix issue #49: Timestamp.parse_s will cause a crash.

## [0.5.7] - 2020-11-16
### Fixed
- Fix issue #47: mmdd pattern matches incorrectly (`#entries`).

## [0.5.6] - 2020-11-11
### Add
- Change `Repository` to enumerable.
  - add `#each` method to `Repository`, then include `Enumerable`.
- Add "-H" option to some searcher default options.

## [0.5.5] - 2020-11-10
### Add
- Add more methods for `Timestamp` class.
  - most of them are delegated to Time class
  - some of them are useful to manipulate `Timestamp` object as
    `String`.

## [0.5.4] - 2020-11-05
### Add
- Add a feature for `Repository#update` to keep timestamp unchanged
  - add the third argument as:
    - `Repository#update(timestamp, text, keep_stamp = false)`

## [0.5.3] - 2020-11-03
### Fixed
- Fix issue #38: fix typo in code for FileSystemRepository.

## [0.5.2] - 2020-11-03
### Fixed
- Fix issue #34:
  - fix FileSystemRepository#entries to accept "yyyymo" pattern as a
    Timestamp pattern.
- Fix issue #33: fix typo in the doc for FileSystemRepository.new.
- Fix issue #31: unfriendly error message of Timestamp.parse_s.

## [0.5.1] - 2020-11-02
### Fixed
- Fix issue #28.
  - Modify `Repository#update` to do nothing when the given text is
    identical to the one in the repository.

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
