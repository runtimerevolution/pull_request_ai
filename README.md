# PullRequestAi
This Rails Engine enables requesting Pull Request descriptions from OpenAI chatGPT and optionally allows direct creation or updating of Pull Requests on GitHub.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "pull_request_ai"
```

And then execute:
```bash
$ bundle
```

OR, install it yourself as:
```bash
$ gem install pull_request_ai
```

## Contributing
Contribution directions go here.

## License
This Rails Engine is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Configuration

To use and configure this Rails Engine you have two options. The first one "Basic Config" using only Environment variables, the other "Advanced Config" using the Rails Engine initializer class with extra configurations.

### Basic Config
The easiest way to configure this Rails Engine is by setting environment variables.

- [OPENAI_API_KEY](https://platform.openai.com/account/usage) Required environment variable to request Pull Requests descriptions on OpenAI chatGPT.

- [GITHUB_ACCESS_TOKEN](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) Optional environment variable that enables direct creation or updating of Pull Requests on GitHub via the Rails Engine interface.

Notice: An access token for GitHub is optional and doesn't affect the Rails Engine's ability to suggest Pull Requests for a git repository.

### Advanced Config

Another way to configure this Rails Engine is through its initializer.
To request Pull Request descriptions from chatGPT, you must provide a [OpenAI Key](https://platform.openai.com/account/usage) on `openai_api_key`.
Additionally, you can enable direct creation or updating of Pull Requests on GitHub by providing an [access token]((https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)) for GitHub on `github_access_token`.

```ruby
PullRequestAi.configure do |config|
    config.openai_api_key = 'YOUR_OPENAI_API_KEY' #Required
    config.github_access_token = 'YOUR_GITHUB_ACCESS_TOKEN' #Optional
end
```

Using the Rails Engine initializer you have access to aditional configurations, which are set by default with the current values:

```ruby
PullRequestAi.configure do |config|
  ...
  config.openai_api_endpoint = 'https://api.openai.com'
  config.github_api_endpoint = 'https://api.github.com'
  config.model = 'gpt-3.5-turbo'
  config.temperature = 0.8
end
```

The [`model`](https://platform.openai.com/docs/models/model-endpoint-compatibility) parameter allows the user to select which OpenAI model to use for Pull Request suggestions. The default model used by this Gem is `gpt-3.5-turbo`, which is the most accessible. However, if you have access to version 4, we recommend using the `gpt-4` model.

The [`temperature`](https://platform.openai.com/docs/api-reference/completions/create#completions/create-temperature) parameter is an OpenAI API configuration that affects the randomness of the output. Higher values produce more random results, while lower values like 0.2 produce more focused and deterministic output.

## Usage

To use the Rails Engine interface on the browser you need to mount the engine route into your project routes. To do that include on your `routes.rb` file the following:

```ruby
mount PullRequestAi::Engine => ''
```

To access it navigate to:

```
http://127.0.0.1:3000/rrtools/pull_request_ai
```

OR, if you want to use this Rails Engine on code you can create an instance of the main client object.

```ruby
client = PullRequestAi::Client.new
```

This object offers the following actions:
- current_opened_pull_requests(base) - method that receives a base branch and based on the current branch will return any existing open pull request from GitHub.
- destination_branches - method without arguments that will return a list of all available remote branches.
- open_pull_request(base, title, description) - method that will communicate with the GitHub API to open a new pull request with the given parameters.
- update_pull_request(number, base, title, description) - method to update an existing pull request base, title, and description.
- flatten_current_changes(branch) - method that returns changes between the current branch and the given branch in a single string.

Notes about the return of these methods, all methods take advantage of [dry-monads](https://dry-rb.org/gems/dry-monads/1.3/).