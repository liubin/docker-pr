FROM ruby:2.2.1-wheezy

RUN gem install octokit

ADD docker_pr.rb /docker_pr.rb

EXEC ["ruby", "/docker_pr.rb"]