STOW = stow -t ~ -v
STOW_SAFE = $(STOW)
STOW_UNSAFE = $(STOW) --no-folding
STOW_SCRIPTS = $(STOW) 

# Default: stow everything
stow: stow-unsafe stow-safe stow-scripts

stow-unsafe:
	@echo "🔒 Stowing unsafe packages (no-folding)..."
	$(STOW_UNSAFE) unsafe

stow-safe:
	@echo "⚙️ Stowing safe packages..."
	$(STOW_SAFE) safe

stow-scripts:
	@echo "💻 Stowing user scripts..."
	# Ensure target directory exists
	mkdir -p ~/bin
	# Stow the bin directory into ~/bin
	$(STOW_SCRIPTS) scripts
	# Make all stowed scripts executable
	@find scripts/bin -type f -exec chmod +x {} \;

unstow:
	@echo "🧹 Unstowing all packages..."
	$(STOW_UNSAFE) -D unsafe
	$(STOW_SAFE) -D safe
	$(STOW_SCRIPTS) -D scripts

adopt:
	@echo "📦 Adopting local files..."
	$(STOW_UNSAFE) --adopt unsafe
	$(STOW_SAFE) --adopt safe
	$(STOW_SCRIPTS) --adopt scripts
