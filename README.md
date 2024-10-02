# Maybe Marketing Site

This is the marketing site for [Maybe](https://maybe.co), an OS for your personal finances.

## Local Development Setup

### Requirements

- Ruby >3 (see `Gemfile`)
- PostgreSQL >9.3 (ideally, latest stable version)

After cloning the repo, the basic setup commands are:

```sh
cd marketing
cp .env.example .env
bin/setup
bin/rails db:seed
bin/dev
```

### Stock data

We use [Synth](https://synthfinance.com) for financial data. You can sign up for a free account and add your API key to your `.env` file.

Then, run `rails data:load_stocks` to seed the database with stock data.

### AI-assisted development

We fully support AI-assisted development. As a team, we typically use [Cursor](https://cursor.com) for that. As such, we've included an `.ai` directory with some rules for Cursor, along with prompts for certain tasks.

## Copyright & license

Maybe is distributed under an [AGPLv3 license](https://github.com/maybe-finance/maybe/blob/main/LICENSE). "Maybe" and the stacked "M" logo are trademarks of Maybe Finance, Inc.
