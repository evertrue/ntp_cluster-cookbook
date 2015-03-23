# et_ntp-cookbook

[![Build Status](https://travis-ci.com/evertrue/et_ntp-cookbook.svg)](https://travis-ci.com/evertrue/et_ntp-cookbook)

Provides automated discovery and configuration of a private ntp pool via chef.

## Supported Platforms

* Ubuntu 12.04
* Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['et_ntp']['discovery']</tt></td>
    <td>String</td>
    <td>The Chef Search query to find ntp servers</td>
    <td><tt>role:ntp_server</tt></td>
  </tr>
</table>

## Usage

### et_ntp::default

Include `et_ntp` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[et_ntp::default]"
  ]
}
```

## License and Authors

Author:: EverTrue, Inc. (<devops@evertrue.com>)
