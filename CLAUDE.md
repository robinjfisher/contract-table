# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Development (runs Rails server + Tailwind watcher)
bin/dev

# Rails server only
bin/rails server

# Run all tests
bin/rails test

# Run a single test file
bin/rails test test/models/contract_test.rb

# Run a single test by line number
bin/rails test test/models/contract_test.rb:42

# Run system tests
bin/rails test:system

# Linting
bin/rubocop

# Security audit
bin/brakeman
bin/bundler-audit

# Database
bin/rails db:migrate
bin/rails db:seed
```

## Stack

- **Rails 8.1** with SQLite (via `solid_cache`, `solid_queue`, `solid_cable` for background jobs/caching)
- **Hotwire** (Turbo + Stimulus) for frontend interactivity — no separate JS framework
- **Tailwind CSS** via `tailwindcss-rails` (asset pipeline: Propshaft + importmap, no Node/webpack)
- **Testing**: Minitest with fixtures, parallelized by default; Capybara + Selenium for system tests
- **Linting**: RuboCop with `rubocop-rails-omakase` (Rails' default opinionated style)

## Architecture

This is an early-stage Rails app (no models, controllers, or routes defined yet beyond the Rails defaults). The application layout (`app/views/layouts/application.html.erb`) uses Tailwind's container/flex layout as the base. The app title is "Contract Table".

When adding features, follow standard Rails conventions: resourceful routes, thin controllers, fat models, ERB views with Turbo frames/streams for interactivity.
