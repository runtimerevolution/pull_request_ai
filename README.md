# PullRequestAi
This Rails Engine offers a way to request Pull Request descriptions from OpenAI chatGPT and optionally allows direct creation or updating of Pull Requests on GitHub or Bitbucket.

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

To configure this Rails Engine you can **just** set some specific Environment Variables or you can use the Rails Engine initializer class.

The minimum requirement that allows this Rails Engine to ask chatGPT Pull Request descriptions based on Git respository changes is the [OpenAI Key](https://platform.openai.com/account/usage).

Using **only** Environment Variable you need to set:
- [OPENAI_API_KEY](https://platform.openai.com/account/usage)

OR, if you choose to use the initializer:
```ruby
PullRequestAi.configure do |config|
    config.openai_api_key = 'YOUR_OPENAI_API_KEY'
end
```

## Integrations

To enable direct creation or updating of Pull Requests this Rails Engine can integrate with GitHub or Bitbucket.

For GitHub you need to provide a [GitHub Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
And for Bitbucket you need to provide a [Bitbucket App Password](https://bitbucket.org/account/settings/app-passwords/) and your Bitbucket Username.

### GitHub Configuration

Using **only** Environment Variable you need to set:
- [GITHUB_ACCESS_TOKEN](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

OR, if you choose to use the initializer:
```ruby
PullRequestAi.configure do |config|
    config.github_access_token = 'YOUR_GITHUB_ACCESS_TOKEN'
end
```

### Bitbucket Configuration

Using **only** Environment Variable you need to set:
- [BITBUCKET_APP_PASSWORD](https://bitbucket.org/account/settings/app-passwords/)
- [BITBUCKET_USERNAME](https://bitbucket.org/account/settings/)

OR, if you choose to use the initializer:
```ruby
PullRequestAi.configure do |config|
    config.bitbucket_app_password = 'YOUR_BITBUCKET_APP_PASSWORD'
    config.bitbucket_username = 'YOUR_BITBUCKET_USERNAME'
end
```

## Usage

To use the Rails Engine interface on the browser you need to mount the engine route into your project routes. To do that include on your `routes.rb` file the following:

```ruby
mount PullRequestAi::Engine => ''
```

Then you navigate to:

```
http://127.0.0.1:3000/rrtools/pull_request_ai
```

Another way to use this Rails Engine is through code, to do that create an instance of the main client object.

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

## Extra Configurations

If you need you have access to some aditional configurations which are:
- openai_api_endpoint - The OpenAI API endpoint.
- github_api_endpoint - The GitHub API endpoint.
- bitbucket_api_endpoint - The Bitbucket API endpoint.
- model - The [`model`](https://platform.openai.com/docs/models/model-endpoint-compatibility) parameter allows the user to select which OpenAI model to use for Pull Request suggestions. The default model used by this Gem is `gpt-3.5-turbo`, which is the most accessible. However, if you have access to version 4, we recommend using the `gpt-4` model.
- temperature - The [`temperature`](https://platform.openai.com/docs/api-reference/completions/create#completions/create-temperature) parameter is an OpenAI API configuration that affects the randomness of the output. Higher values produce more random results, while lower values like 0.2 produce more focused and deterministic output.

The only way to configure these parameters is using the initializer, above it is listing as well their default values:

```ruby
PullRequestAi.configure do |config|
  ...
  config.openai_api_endpoint = 'https://api.openai.com'
  config.github_api_endpoint = 'https://api.github.com'
  config.model = 'gpt-3.5-turbo'
  config.temperature = 0.8
end
```