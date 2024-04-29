# Maybe Marketing Site

This is the marketing site for Maybe, an OS for your personal finances.

## Local Development Setup

### Requirements

- Ruby >3 (see `Gemfile`)
- PostgreSQL >9.3 (ideally, latest stable version)

After cloning the repo, the basic setup commands are:

```sh
cd marketing
cp .env.example .env
bin/setup
bin/dev
```

Then visit http://localhost:3000 to see the app.

## Copyright & license

Maybe is distributed under an [AGPLv3 license](https://github.com/maybe-finance/maybe/blob/main/LICENSE). "Maybe" and the stacked "M" logo are trademarks of Maybe Finance, Inc.
