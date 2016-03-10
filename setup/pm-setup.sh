#!/bin/bash
set -e
pm publish webapp.json
pm define app.json
pm import -d data.json -a app.json