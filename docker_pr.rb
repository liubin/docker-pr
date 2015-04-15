# gem install octokit

require 'octokit'

# 缓存用户数据，避免重复发起API请求
$user_cache = Hash.new
# 中国用户登录名列表
$chinese_user_login_list = ['xiaods', 'hukeping']
# 中国公司邮箱后缀
$chinese_user_email_domain_list = ['@huawei.com']

# 通过判断用户名和email后缀（能取到email的话）判断是否为中国用户
def is_chinese?(user)
    # 先判断是否在用户列表
    return true if $chinese_user_login_list.include?(user.login.downcase )
    # 否则看是否能取到邮件地址
    return false if user.email.nil?
    # 邮箱后缀判断
    return $chinese_user_email_domain_list.include?("@#{user.email.split('@')[1]}")
    false
end

# 通过API取得用户信息并缓存
def get_ser_by_api(login)

  begin
    user = Octokit.user login
    $user_cache[login] = user
    user[:is_chinese] = is_chinese? user
    user
  rescue Exception => e
    puts "got an Exception: #{e}"
    nil
  end

end

# 取得用户信息
def get_user_info(login)
  if $user_cache.key? login
    # puts "get from cach #{login} #{$user_cache[login].email}"
    $user_cache[login]
  else
    # puts "http get new #{login}"
    get_ser_by_api login
  end
end


# 入口函数
def pr(repo)
  puts "Get PRs for Repo #{repo}"
  # 暂时不做分页
  # has_more = true
  prs = Octokit.pull_requests(repo, :state => 'closed', :per_page => 300)
  today = Time.now.utc.strftime("%Y%m%d")
  yesterday = (Time.now.utc - 86400).strftime("%Y%m%d")
  # while(has_more)
    prs.each do |pr|
      next if pr.merged_at.nil?
      break if pr.merged_at.strftime("%Y%m%d") != today && pr.merged_at.strftime("%Y%m%d") != yesterday
      user = get_user_info pr.user.login
      if user[:is_chinese] then
        print "[*] "
      else
        print "[ ] "
      end
      puts "<#{user.login}> #{user.email} ##{pr.number} #{ pr.title} #{ pr.merged_at}"
    end # prs.each
  # end # while has_more
end

# call main method
pr 'docker/docker'
pr 'docker/compose'
pr 'docker/libcontainer'
pr 'docker/swarm'
pr 'docker/machine'
pr 'docker/libchan'
