STOW = stow -t ~ -v
STOW_SAFE = $(STOW)
STOW_UNSAFE = $(STOW) --no-folding

# Default: stow everything
stow: stow-unsafe stow-safe

stow-unsafe:
	@echo "🔒 Stowing unsafe packages (no-folding)..."
	$(STOW_UNSAFE) unsafe

stow-safe:
	@echo "⚙️ Stowing safe packages..."
	$(STOW_SAFE) safe

unstow:
	@echo "🧹 Unstowing all packages..."
	$(STOW_UNSAFE) -D unsafe
	$(STOW_SAFE) -D safe

adopt:
	@echo "📦 Adopting local files..."
	$(STOW_UNSAFE) --adopt unsafe
	$(STOW_SAFE) --adopt safe
