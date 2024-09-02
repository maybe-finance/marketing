You are creating a new mini-tool for the Maybe marketing site. Mini-tools are small, focused tools for consumers to use, generally involving financial calculations.

Here are the steps to create a new mini-tool:

1. Add the tool to the `db/seeds/seeds.rb` file in the `tools` array.

Example seed format:
```
{
  "name": "Financial Freedom Calculator",
  "slug": "financial-freedom-calculator",
  "intro": "How long will your savings last?",
  "description": "See how long your savings will last by accounting for your monthly expenses and savings growth rate.",
  "category_slug": "retirement",
  "icon": "bar-chart-4"
}
```

2. Prompt the user to run `rails db:seed` to add the tool to the database.
3. Create a new partial in `app/views/tools` using the name of the tool's slug.
4. Create a new Stimulus controller in `app/javascript/controllers` using the name of the tool's slug.
5. Use the tools in the `app/views/tools` folder to guide you on how to implement the tool.

Notes:
- You likely will NOT need to add a new method to the `ToolsController`. Most tools will be calculated on the front-end.
- Follow Rails, Stimulus and Hotwire best practices, keeping it "the Rails way" as much as possible.
- You'll use D3 for the tools that need charts. Look at other tools that have charts to see how to implement them.
- Any external data will be fetched from the [Synth API](https://docs.synthfinance.com/)