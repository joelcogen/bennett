class SuperGit
  def self.branches_for_url(url)
    return ["deploy", "master", "new-builder", "public-projects"]
    tmpdir = Dir.mktmpdir
    system "git clone --no-checkout #{url} #{tmpdir}" # This cannot be done using Git :(
    branches = Git.open(tmpdir).branches.remote.collect do |branch|
      branch.to_s.gsub /.*remotes\/origin\//, ""
    end.reject do |branch|
      branch.match "HEAD ->"
    end
    system "rm -rf #{tmpdir}" # FIXME: Replace with call to File or Dir
    branches
  end

  def self.clone_commit(url, branch, commit, dir = Dir.mktmpdir)
    system "git clone --branch #{branch} --single-branch --depth 100 #{url} #{dir}"
    Git.open(dir).checkout(commit)
    dir
  end
end
