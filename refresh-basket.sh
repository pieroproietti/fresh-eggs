#!/bin/bash
# Wrapper di compatibilità: la logica è in refresh.sh
exec "$(dirname "$0")/refresh.sh" basket
