# fetch

## Why fetch

Lib curl is huge and clunky, wget is too. On embeded devices we often don't have enough space to install the entire libcurl stack. Fetch offers a little of the basics in a staticly compiled binary. At around 3.2MB it's small enough with most features one would need to fetch an https url.

Things it lacks can be easily added in this single file/function application.

### Currently supported build targets

#### Linux

##### mipssf (Atheros chipsets)

This was my target platform running dd-wrt so should be supported

##### Linux x86_64

Typical dev platform, so should support for testing

## Building

This build relies on musl toolchains as we are targeting an optimized static linked binary as an http/s client.

## Description

Command-line utility used to trigger GitlabCI pipelines

Currently requires `git` to be installed and available in PATH

## Usage

```bash
Fetches an http/https url

Usage:
   [options] url

Arguments:
  url              The API endpoint for Gitlab. Defaults to the origin

Options:
  -h, --help
  -k, --insecure             Allow insecure server connections when using SSL

Missing argument(s): url
```
