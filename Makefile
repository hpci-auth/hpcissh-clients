# Makefile for hpcissh
# Time-stamp: <2024-07-01 18:06:10 sakane>

all:
	$(MAKE) -C script

install:
	$(MAKE) install -C script

clean:
	$(MAKE) clean -C script
