# Forwarding Makefile for Convenience
# Proxies root make commands directly into the generated build system

# The single default target 
all: check_build
	$(MAKE) -C build

# Force everything to proxy via a double-colon pattern matcher
# Phony declaration is purposely not used so it always triggers.
%:: check_build
	$(MAKE) -C build $@

check_build:
	@if [ ! -d "build" ] || [ ! -f "build/Makefile" ]; then \
		echo "ERROR: Please run ./configure first."; \
		exit 1; \
	fi


