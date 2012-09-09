class CreateBranches < ActiveRecord::Migration
  def change
    create_table "branches" do |t|
      t.references :project
      t.string "name"
      t.boolean "active"
    end
    remove_column "projects", "branch"
    add_column "projects", "test_all_branches", :boolean
  end
end
