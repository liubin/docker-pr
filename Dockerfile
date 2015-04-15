FROM ruby:2.2.1-wheezy
RUN gem sources --remove https://rubygems.org/
RUN gem sources -a https://ruby.taobao.org/

RUN gem install octokit

ADD docker_pr.rb /docker_pr.rb

CMD ["ruby", "/docker_pr.rb"]