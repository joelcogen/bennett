#encoding: utf-8

require 'faker'

FactoryGirl.define do
  factory :user do
    email                 { "#{SecureRandom.uuid}-#{Faker::Internet.email}" }
    password              'secret'
    password_confirmation 'secret'

    factory :global_admin do
      admin true
    end

    factory :admin do
      rights {|rights| [rights.association(:right, role: 'admin')] }
    end
    factory :developer do
      rights {|rights| [rights.association(:right, role: 'developer')] }
    end
    factory :auditor do
      rights {|rights| [rights.association(:right, role: 'auditor')] }
    end
  end

  factory :right do
    project
    user
    role { ['auditor', 'developer', 'admin'].sample }
  end

  factory :project do
    name              { Faker::Company.name }
    branches          { |branches| [branches.association(:branch)] }
    git_url           { "git@github.com:belighted/#{SecureRandom.uuid}.git" }
    recentizer        false
    test_all_branches true
    public            false
    build_nightly     false
  end

  factory :branch do
    name   { Faker::Lorem.words(1)[0] }
    active true
  end

  factory :build do
    project
  end

  factory :command do
    project
    name { %w(bundle dbmigrate rspec cucumber units controllers).sample }
  end

  factory :invitation do
    project
    association :issuer, factory: :user
    role  { ['auditor', 'developer', 'admin'].sample }
    email { "#{SecureRandom.uuid}-#{Faker::Internet.email}" }
  end

  factory :result do
    build
    command
  end
end
