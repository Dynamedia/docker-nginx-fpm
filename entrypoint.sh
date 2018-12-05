#!/bin/bash

# Run the entrypoint script that comes with php to set up the environment
fpm-entrypoint.sh

# Run the entrypoint script that comes with nginx to set up the environment
/usr/local/bin/nginx-entrypoint.sh

# Do stuff specific to the joint container

exec "$@"
