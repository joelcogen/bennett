class BuildReferencesBranch < ActiveRecord::Migration
  def change
    Build.delete_all
    remove_column "builds", "project_id"
    add_column "builds", "branch_id", :integer
  end
end
