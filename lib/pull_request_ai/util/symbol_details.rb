# frozen_string_literal: true

module PullRequestAi
  SYMBOL_DETAILS = {
    project_not_configured: 'Your project doesn\'t have a GitHub repository configured.',
    invalid_repository_url: 'Couldn\'t read the remote URL from the repository.',
    current_branch_not_pushed: 'The current branch has not yet been pushed into the remote.',
    connection_timeout: 'Connection timeout.',
    failed_on_openai_api_endpoint: 'Failed to communicate with openAI API.',
    failed_on_github_api_endpoint: 'Failed to communicate with GitHub API.',
    no_changes_btween_branches: 'No changes between branches. Please check the destination branch.'
  }
end
