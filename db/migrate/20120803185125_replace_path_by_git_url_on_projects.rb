class ReplacePathByGitUrlOnProjects < ActiveRecord::Migration
  def change
    remove_column "projects", "folder_path"
    add_column "projects", "git_url", :string
  end
end
