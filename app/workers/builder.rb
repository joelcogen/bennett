class Builder
  @queue = "builds"

  def self.perform(build_id)
    build = Build.find(build_id)
    if build.should_build?
      build!(build)
    else
      build.skip!
    end
  end

  private

  def self.build!(build)
    dir = SuperGit.clone(build.git_url, build.branch_name, build.commit_hash)
    update_commit_info!(build, dir)
    build.results.each do |result|
      result.start_now
      if build.status == :failed
        result.skipped
      else
        result.busy
        commands = [ 'unset RAILS_ENV RUBYOPT BUNDLE_GEMFILE BUNDLE_BIN_PATH GEM_HOME RBENV_DIR GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE',
                     '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"',
                     '[[ -s "$HOME/.rbenv/bin/rbenv" || -s "/usr/local/bin/rbenv" ]] && export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:/usr/local/bin:$PATH" && eval "$(rbenv init -)"',
                     "cd #{dir}",
                     "#{result.command.command}" ]
        res = system "#{commands.join(';')} > #{result.log_path} 2>&1"
        if res
          result.passed
        else
          result.failed
        end
      end
      result.end_now
    end
    CiMailer.build_result(build).deliver
  end

  def self.update_commit_info!(build, dir)
    git = Git.open(dir)
    branch = git.branches[build.branch_name]
    commit = branch.gcommit.log(1).first
    build.commit_hash = commit.sha
    build.commit_message = commit.message
    build.commit_author = commit.author.name
    build.commit_author_email = commit.author.email
    build.commit_date = commit.date
    build.save!
  end
end
