#!/bin/sh
touch ../WORKSPACE
echo """Please create BUILD with full path to gdrive and banal installation.

load(\":gdrive.bzl\", \"gdrive\")

package(
    default_visibility = [\"//visibility:public\"],
)

gdrive(
    name = \"gdrive\",
    gdrive_cmd = \"<full path>/gopath/bin/gdrive\",
    gdrive_config = \"<full path>/.gdrive\",
)

banal(
    name = \"banal\",
    banal_cmd = \"<full path>/bin/banal\",
    banal_pdftohtml = \"<fullpath>/pdftohtml\",
)
"""
