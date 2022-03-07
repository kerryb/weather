.PHONY: all assets burn clean deps firmware help setup
all: deps assets firmware # Help: Fetch dependencies and build firmware
assets: # Help: Build web assets for UI app
	cd weather_ui && mix assets.deploy
burn: # Help: Burn the generated firmware to an SD card
	cd weather_firmware && MIX_TARGET=rpi0 mix firmware.burn
clean: # Help: Clean firmware and UI projects
	cd weather_ui && mix clean
	cd weather_firmware && mix clean
deps: # Help: Fetch dependencies for firmware (RPI0) and UI
	cd weather_ui && mix deps.get
	cd weather_firmware && MIX_TARGET=rpi0 mix deps.get
firmware: # Help: Build the firmware image
	cd weather_firmware && MIX_TARGET=rpi0 mix firmware
help: # Help: Show this help message
	@echo 'The following make targets are available.'
	@sed -n 's/^\([^:]*:\).*# [H]elp: \(.*\)/"%-20s %s\\n" "\1" "\2"/p' Makefile | xargs -n 3 printf | sort	
setup: # Help: Install required Erlang and Elixir versions, and Nerves bootstrap
	asdf install
	mix archive.install hex nerves_bootstrap
