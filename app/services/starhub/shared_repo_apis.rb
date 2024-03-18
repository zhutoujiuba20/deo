module Starhub
  module SharedRepoApis
    def get_repo_detail_data_in_parallel(repo_type, namespace, repo_name, options = {})
      options[:path] ||= '/'
      options[:ref] ||= 'main'
      paths = [
        "/#{repo_type}/#{namespace}/#{repo_name}?current_user=#{options[:current_user]}",
        "/#{repo_type}/#{namespace}/#{repo_name}/branches"
      ]
      @client.get_in_parallel(paths, options)
    end

    def get_repo_detail_files_data_in_parallel(repo_type, namespace, repo_name, options = {})
      options[:path] ||= '/'
      options[:ref] ||= 'main'
      paths = [
        "/#{repo_type}/#{namespace}/#{repo_name}/last_commit?ref=#{options[:ref]}",
        "/#{repo_type}/#{namespace}/#{repo_name}/tree?#{options[:path]}&ref=#{options[:ref]}"
      ]
      @client.get_in_parallel(paths, options)
    end

    def get_repo_detail_blob_data_in_parallel(repo_type, namespace, repo_name, options = {})
      options[:path] ||= '/'
      options[:ref] ||= 'main'
      paths = [
        "/#{repo_type}/#{namespace}/#{repo_name}?current_user=#{options[:current_user]}",
        "/#{repo_type}/#{namespace}/#{repo_name}/last_commit?ref=#{options[:ref]}",
        "/#{repo_type}/#{namespace}/#{repo_name}/branches",
        "/#{repo_type}/#{namespace}/#{repo_name}/blob/#{options[:path]}?ref=#{options[:ref]}"
      ]
      @client.get_in_parallel(paths, options)
    end

    def get_repos(repo_type, current_user, keyword, sort_by, task_tag, framework_tag, license_tag, page = 1, per = 16)
      url = "/#{repo_type}?per=#{per}&page=#{page}"
      url += "&current_user=#{current_user}" if current_user.present?
      url += "&search=#{keyword}" if keyword.present?
      url += "&sort=#{sort_by}" if sort_by.present?
      url += "&task_tag=#{task_tag}" if task_tag.present?
      url += "&framework_tag=#{framework_tag}" if framework_tag.present?
      url += "&license_tag=#{license_tag}" if license_tag.present?
      res = @client.get(url)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_repo_detail(repo_type, namespace, repo_name, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}?current_user=#{options[:current_user]}")
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_repo_files(repo_type, namespace, repo_name, options = {})
      options[:path] ||= '/'
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/tree?path=#{options[:path]}&ref=#{options[:ref]}")
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_repo_last_commit(repo_type, namespace, repo_name, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/last_commit?ref=#{options[:ref]}")
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_repo_branches(repo_type, namespace, repo_name, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/branches")
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def get_repo_file_content(repo_type, namespace, repo_name, path, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/raw/#{path}?ref=#{options[:ref]}")
      raise StarhubError, res.body unless res.success?
      res.body.force_encoding('UTF-8')
    end

    def create_repo(repo_type, username, repo_name, namespace, nickname, desc, options = {})
      options[:username] = username
      options[:name] = repo_name
      options[:namespace] = namespace
      options[:nickname] = nickname
      options[:description] = desc
      @client.post("/#{repo_type}", options)
    end

    def delete_repo(repo_type, namespace, repo_name, params = {})
      @client.delete("/#{repo_type}/#{namespace}/#{repo_name}?current_user=#{params[:current_user]}")
    end

    def update_repo(repo_type, username, repo_name, namespace, nickname, desc, options = {})
      options[:username] = username
      options[:name] = repo_name
      options[:nickname] = nickname
      options[:description] = desc
      res = @client.put("/#{repo_type}/#{namespace}/#{repo_name}", options)
    end

    def get_repo_tags(repo_type, namespace, repo_name, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/tags")
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def download_repo_file(repo_type, namespace, repo_name, path, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/download/#{path}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def download_repo_resolve_file(repo_type, namespace, repo_name, path, options = {})
      res = @client.get("/#{repo_type}/#{namespace}/#{repo_name}/resolve/#{path}", options)
      raise StarhubError, res.body unless res.success?
      res.body
    end

    def create_repo_file(repo_type, namespace, repo_name, path, options = {})
      @client.post("/#{repo_type}/#{namespace}/#{repo_name}/raw/#{path}", options)
    end

    def update_repo_file(repo_type, username, repo_name, path, options = {})
      @client.put("/#{repo_type}/#{username}/#{repo_name}/raw/#{path}", options)
    end

    def upload_repo_file(repo_type, namespace, repo_name, options = {})
      @client.upload("/#{repo_type}/#{namespace}/#{repo_name}/upload_file", options)
    end
  end
end
