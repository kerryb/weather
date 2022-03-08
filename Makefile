.PHONY: all asdf assets bootstrap burn check-formatted clean credo deps firmware format help setup test update-deps
all: check-formatted credo test assets firmware # Help: Run tests and build firmware
asdf: # Help: Install correct Erlang/OTP and Elixir versions using asdf
	asdf install
assets: # Help: Build web assets for UI app
	cd weather_ui && mix assets.deploy
bootstrap: # Help: Install the nerves bootstrap archive
	mix archive.install hex nerves_bootstrap
burn: # Help: Burn the generated firmware to an SD card
	cd weather_firmware && MIX_TARGET=rpi0 mix firmware.burn
check-formatted: # Help: Check all Elixir source files are correctly formatted
	cd weather_ui && mix format --check-formatted
	cd weather_firmware && mix format --check-formatted
clean: # Help: Clean firmware and UI projects
	cd weather_ui && mix clean
	cd weather_firmware && mix clean
credo: # Help: Run credo style checker on firmware and UI projects
	cd weather_ui && mix credo --strict
	cd weather_firmware && mix credo --strict
deps: # Help: Download dependencies for firmware and UI projects
	cd weather_ui && mix deps.get
	cd weather_firmware && mix deps.get
firmware: # Help: Build the firmware image
	cd weather_firmware && MIX_TARGET=rpi0 mix firmware
format: # Help: Format all Elixir source files
	cd weather_ui && mix format
	cd weather_firmware && mix format
help: # Help: Show this help message
	@echo 'The following make targets are available.'
	@sed -n 's/^\([^:]*:\).*# [H]elp: \(.*\)/"%-20s %s\\n" "\1" "\2"/p' Makefile | xargs -n 3 printf | sort	
test: # Help: Run tests in firmware and UI projects
	cd weather_ui && mix test
	cd weather_firmware && mix test
update-deps: # Help: Update dependencies for firmware and UI projects
	cd weather_ui && mix deps.update --all
	cd weather_firmware && MIX_TARGET=rpi0 mix deps.update --all
