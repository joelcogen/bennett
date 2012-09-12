class SuperGit
  def self.branches_for_url(url)
    tmpdir = "tmp/builds/#{SecureRandom.hex(10)}"
    Dir.mkdir(tmpdir)
    system "git clone --no-checkout #{url} #{tmpdir}" # This cannot be done using Git :(
    branches = Git.open(tmpdir).branches.remote.collect do |branch|
      branch.to_s.gsub /.*remotes\/origin\//, ""
    end.reject do |branch|
      branch.match "HEAD ->"
    end
    system "rm -rf #{tmpdir}" # FIXME: Replace with call to File or Dir
    branches
  end

  def self.clone(url, branch, commit = nil, dir = "tmp/builds/#{SecureRandom.hex(10)}")
    Dir.mkdir(dir)
    system "git clone --branch #{branch} --single-branch --depth #{commit.nil? ? 100 : 1} #{url} #{dir}"
    Git.open(dir).checkout(commit) if commit.present?
    dir
  end
end
