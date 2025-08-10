# Chromium Release Tracker

This repository provides up-to-date download links (as "releases") for official recent Chromium browser builds. 

These are not stable releases, but the latest **development snapshots** directly from the Chromium build infrastructure.

Note that the check for a newer version occurs **30 minutes past each hour** (UTC time).

## Overview

An automated pipeline fetches the newest Chromium browser snapshots for Windows, macOS and Linux for supported architectures (from https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html).

If a new Chromium snapshot is detected, the pipeline automatically creates a new release with updated download links.

The download links are collected and made available in a structured JSON file for an easy integration into automated tools or for a manual download.
