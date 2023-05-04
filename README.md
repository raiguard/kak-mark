# kak-mark

A [kakoune](https://kakoune.org) plugin to easily save/restore selections from
the default mark register, and visualize the contents of the register.
Originally created by [Taupiqueur](https://github.com/alexherbo2).

## Installation

Source `mark.kak` in your `kakrc` or use a plugin manager.

## Usage

- `z` ⇒ Restore register.
- `Z` ⇒ Consume register.

- `D` ⇒ Clear register.

- `Y` ⇒ Add selections.
- `<a-Y>` ⇒ Consume selections.

- `<c-n>` ⇒ Iterate next selection.
- `<c-p>` ⇒ Iterate previous selection.

## Faces

- `MarkedPrimaryCursor`
- `MarkedPrimarySelection`

- `MarkedSecondaryCursor`
- `MarkedSecondarySelection`
